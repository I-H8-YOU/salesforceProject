import { LightningElement, track } from 'lwc';

export default class SuperCaseContainer extends LightningElement {
    @track customerName = '';
    @track showC360 = false;

    @track selectedCaseId;
    @track selectedAssetId;

    handleCustomerNameInput(event) {
        const fullName = event.detail;

        if (this.isCompleteHangulName(fullName)) {
            const formattedName = this.reformatName(fullName);

            this.customerName = '';
            this.showC360 = false;
            this.selectedCaseId = null;
            this.selectedAssetId = null;

            setTimeout(() => {
                this.customerName = formattedName;
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
    }

    handleAssetClick(event) {
        this.selectedAssetId = event.detail;
    }

    reformatName(name) {
        if (!name || name.length < 2) return name;

        const lastName = name.charAt(0);
        const firstName = name.slice(1);
        return `${firstName} ${lastName}`;
    }

    isCompleteHangulName(name) {
        if (!name || name.length !== 3) return false;

        return [...name].every(char => {
            const code = char.charCodeAt(0);
            return code >= 0xAC00 && code <= 0xD7A3;
        });
    }
}
