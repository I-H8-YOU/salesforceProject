import { LightningElement, track } from 'lwc';
import sendToGPT from '@salesforce/apex/GPTController.sendToGPT';

export default class GptCaseHelper extends LightningElement {
    @track messages = [];
    @track userInput = '';
    @track isLoading = false;
    messageId = 0;

    connectedCallback() {
        this.messages.push({
            id: ++this.messageId,
            text: '안녕하세요! 진행 중인 케이스 번호가 있으신가요? 없으시면 이름으로 찾아드릴게요.',
            cssClass: 'chat-bubble bot'
        });
    }

    handleInputChange(event) {
        this.userInput = event.detail.value;
    }

    handleKeyPress(event) {
        if (event.key === 'Enter' && !event.shiftKey) {
            event.preventDefault();
            this.sendMessage();
        }
    }

    sendMessage() {
        const trimmed = this.userInput.trim();
        if (!trimmed) return;

        this.messages.push({
            id: ++this.messageId,
            text: trimmed,
            cssClass: 'chat-bubble user'
        });

        this.userInput = '';
        this.isLoading = true;

        sendToGPT({ userInput: trimmed })
            .then(result => {
                this.messages.push({
                    id: ++this.messageId,
                    text: result,
                    cssClass: 'chat-bubble bot'
                });
            })
            .catch(error => {
                this.messages.push({
                    id: ++this.messageId,
                    text: '❌ 오류 발생: ' + (error.body?.message || '알 수 없는 오류'),
                    cssClass: 'chat-bubble bot'
                });
            })
            .finally(() => {
                this.isLoading = false;
            });
    }
}