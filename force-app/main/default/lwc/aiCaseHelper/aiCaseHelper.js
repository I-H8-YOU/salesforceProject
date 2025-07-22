import { LightningElement, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import generateCaseDetails from '@salesforce/apex/AICaseController.generateCaseDetails';
import getAssetsByAccountId from '@salesforce/apex/AICaseController.getAssetsByAccountId';

export default class AiCaseHelper extends LightningElement {
    @track customerName = '';
    @track issueDescription = '';
    @track isLoading = false;
    @track isSaving = false;
    @track showInput = true;
    @track showResult = false;
    @track error = null;
    @track animatedDescription = '';

    @track caseData = {
        contactId: '',
        accountId: '',
        subject: '',
        description: '',
        assetId: ''
    };

    handleName(event) {
        this.customerName = event.detail.value;
        // 입력만 저장, 이벤트는 버튼에서
    }

    handleDescription(event) {
        this.issueDescription = event.detail.value;
    }

    handleShowCustomerInfo() {
        if (!this.customerName || this.customerName.length !== 3) {
            this.error = '고객 이름은 정확한 3자 한글이어야 합니다.';
            return;
        }
        this.error = null;

        // 이름이 바뀌든 말든 항상 버튼 누를 때 이벤트 발생
        this.dispatchEvent(new CustomEvent('nameentered', {
            detail: this.customerName
        }));
    }

    async handleAnalyze() {
        this.isLoading = true;
        this.error = null;
        try {
            const result = await generateCaseDetails({
                customerName: this.customerName,
                issueDescription: this.issueDescription
            });
            const assets = await getAssetsByAccountId({ accountId: result.accountId });
            const match = assets.find(a => a.name === result.assetName);

            this.caseData = {
                contactId: result.contactId,
                accountId: result.accountId,
                subject: result.subject,
                description: result.description,
                assetId: match ? match.id : null
            };

            this.startTypingEffect(result.description);
            this.showInput = false;
            this.showResult = true;
        } catch (err) {
            console.error(err);
            this.error = '❗ AI 분석 중 문제가 발생했습니다. 관리자에게 문의해주세요.';
        } finally {
            this.isLoading = false;
        }
    }

    startTypingEffect(text) {
        this.animatedDescription = '';
        let i = 0;
        clearInterval(this.typingTimer);
        this.typingTimer = setInterval(() => {
            if (i < text.length) {
                this.animatedDescription += text.charAt(i);
                i++;
            } else {
                clearInterval(this.typingTimer);
            }
        }, 10);
    }

    handleSubmit(event) {
        event.preventDefault();
        this.isSaving = true;
        const fields = event.detail.fields;
        fields.Type = 'Web';
        fields.Description = this.animatedDescription;
        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        this.isSaving = false;
        this.dispatchEvent(new ShowToastEvent({
            title: '✅ 케이스 저장 완료',
            message: `케이스 ID: ${event.detail.id}`,
            variant: 'success'
        }));
        this.resetForm();
    }

    resetForm() {
        this.customerName = '';
        this.issueDescription = '';
        this.caseData = {
            contactId: '',
            accountId: '',
            subject: '',
            description: '',
            assetId: ''
        };
        this.animatedDescription = '';

        const form = this.template.querySelector('lightning-record-edit-form');
        if (form) {
            try {
                form.reset();
            } catch (err) {
                console.error('⚠️ Reset form error: ', err);
            }
        }

        this.showInput = true;
        this.showResult = false;
    }

    handleBack() {
        clearInterval(this.typingTimer);
        this.showResult = false;
        this.showInput = true;
    }

    get submitButtonLabel() {
        return this.isSaving ? '저장 중...' : '💾 케이스 저장';
    }
}
