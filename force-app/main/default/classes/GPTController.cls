public with sharing class GPTController {
    private static final String OPENAI_API_KEY = '';
    private static String lastCaseNumber;
    private static Boolean isWaitingForName = false;

    @AuraEnabled(cacheable=false)
    public static String sendToGPT(String userInput) {
        if (String.isBlank(userInput)) {
            isWaitingForName = false;
            return '안녕하세요! 저는 OlymBot 🤖 입니다.\n진행 중인 케이스 번호가 있으신가요?\n없으시면 이름으로 찾아드릴게요.';
        }

        if (userInput.contains('모르겠') || userInput.contains('몰라') || userInput.contains('번호 없어') || userInput.contains('없')) {
            isWaitingForName = true;
            return '괜찮습니다! OlymBot 🤖이(가) 도와드릴게요.\n성함을 알려주시면 등록된 케이스를 찾아드리겠습니다.';
        }

        // GPT에게 이름 추출 요청
        String extractPrompt = '다음 문장에서 한국식 이름을 추출해서 JSON으로 반환해줘. ' +
            '이름이 붙어 있으면 띄어쓰기로 성과 이름을 분리해줘. 예: "강예지" → {"name": "예지 강"}, "강 예지" → {"name": "예지 강"} ' +
            '이름이 없으면 빈 JSON 반환. 입력: ' + userInput;

        String gptResponse = askGPT(extractPrompt);
        Map<String, Object> parsed;
        try {
            parsed = (Map<String, Object>) JSON.deserializeUntyped(gptResponse);
        } catch (Exception e) {
            return '이해하지 못했어요. 다시 입력해주시겠어요?';
        }

        if (parsed.containsKey('name')) {
            String name = (String) parsed.get('name');
            isWaitingForName = false;
            List<Case> cases = [
                SELECT CaseNumber, Subject, Status, LastModifiedDate
                FROM Case
                WHERE Contact.Name LIKE :('%' + name + '%')
                ORDER BY LastModifiedDate DESC
                LIMIT 1
            ];

            if (cases.isEmpty()) {
                return '죄송해요. "' + name + '" 님으로 등록된 케이스가 없어요. 다시 입력해주시겠어요?';
            }

            lastCaseNumber = cases[0].CaseNumber;
            return summarizeCase(cases[0]);
        }

        if (parsed.containsKey('caseNumber')) {
            lastCaseNumber = (String) parsed.get('caseNumber');
            return respondWithCaseSummary(lastCaseNumber);
        }

        if (isWaitingForName) {
            return '성함을 인식하지 못했어요. 다시 입력해주시겠어요?';
        }

        return '진행 중인 케이스 번호를 알고 계신가요? 모르신다면 성함으로도 찾아드릴 수 있습니다.';
    }

    private static String respondWithCaseSummary(String caseNumber) {
        List<Case> cases = [
            SELECT CaseNumber, Subject, Status, LastModifiedDate
            FROM Case
            WHERE CaseNumber = :caseNumber
            LIMIT 1
        ];

        if (cases.isEmpty()) {
            return '해당 케이스를 찾지 못했습니다.';
        }

        return summarizeCase(cases[0]);
    }

    private static String summarizeCase(Case c) {
        String prompt = '다음은 고객 지원 케이스에 대한 정보입니다. 이를 참고하여 고객에게 정중하고 이해하기 쉬운 안내 메시지를 한국어로 작성해주세요.\n\n' +
        '- 케이스 번호: ' + c.CaseNumber + '\n' +
        '- 케이스 제목: "' + (String.isBlank(c.Subject) ? '제목 없음' : c.Subject) + '"\n' +
        '- 현재 상태: "' + c.Status + '"\n' +
        '- 마지막 업데이트 일시: ' + String.valueOf(c.LastModifiedDate) + '\n\n' +
        '응답은 고객이 이해하기 쉽도록 문단 형식으로 작성해주세요.';
    

        return askGPT(prompt);
    }

    private static String askGPT(String prompt) {
        HttpRequest req = new HttpRequest();
        req.setEndpoint('https://api.openai.com/v1/chat/completions');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', OPENAI_API_KEY);

        Map<String, Object> payload = new Map<String, Object>{
            'model' => 'gpt-3.5-turbo',
            'messages' => new List<Map<String, String>>{
                new Map<String, String>{ 'role' => 'user', 'content' => prompt }
            }
        };

        req.setBody(JSON.serialize(payload));
        Http http = new Http();
        HttpResponse res = http.send(req);

        if (res.getStatusCode() != 200) {
            return 'GPT 호출 실패: ' + res.getBody();
        }

        Map<String, Object> result = (Map<String, Object>) JSON.deserializeUntyped(res.getBody());
        Map<String, Object> choice = (Map<String, Object>)((List<Object>)result.get('choices'))[0];
        Map<String, Object> message = (Map<String, Object>)choice.get('message');
        return (String) message.get('content');
    }
}