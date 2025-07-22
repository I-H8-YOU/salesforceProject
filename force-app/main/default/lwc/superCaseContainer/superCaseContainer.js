import { LightningElement, track } from 'lwc';

export default class SuperCaseContainer extends LightningElement {
    @track customerName = '';
    @track showC360 = false;
    @track selectedCaseId = null;
    @track selectedAssetId = null;
    @track isCaseCreated = false;

    handleCustomerNameInput(event) {
        const fullName = event.detail;

        if (this.isCompleteHangulName(fullName)) {
            const formatted = this.reformatName(fullName);
            this.customerName = '';
            this.showC360 = false;
            this.selectedCaseId = null;
            this.selectedAssetId = null;

            setTimeout(() => {
                this.customerName = formatted;
                this.showC360 = true;
            }, 0);
        } else {
            this.customerName = '';
            this.showC360 = false;
            this.selectedCaseId = null;
            this.selectedAssetId = null;
        }
    }

    handleCaseClick(event) {
        this.selectedCaseId = event.detail;
        this.isCaseCreated = false;
    }

    handleAssetClick(event) {
        this.selectedAssetId = event.detail;
    }

    handleCaseCreated(event) {
        this.selectedCaseId = event.detail.caseId;
        this.selectedAssetId = event.detail.assetId;
        this.isCaseCreated = true;
    }

    reformatName(name) {
        if (!name || name.length < 2) return name;
        return `${name.slice(1)} ${name[0]}`;
    }

    isCompleteHangulName(name) {
        return name.length === 3 && [...name].every(c => {
            const code = c.charCodeAt(0);
            return code >= 0xac00 && code <= 0xd7a3;
        });
    }
}
