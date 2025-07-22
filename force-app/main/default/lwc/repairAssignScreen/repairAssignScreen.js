import { LightningElement, api, track } from 'lwc';
import getAssignableUsers from '@salesforce/apex/RepairAssignmentService.getAssignableUsers';
import createRepair from '@salesforce/apex/RepairAssignmentService.createRepair';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RepairAssignScreen extends LightningElement {
    @api contactId;
    @api accountId;
    @api assetId;
    @api caseId;

    @track users = [];
    @track loading = true;
    @track repairAssigned = false;
    maxCount = 4;

    connectedCallback() {
        this.fetchUsers();
    }

    async fetchUsers() {
        this.loading = true;
        try {
            const result = await getAssignableUsers();
            this.users = result.map(user => {
                const percentage = Math.floor((user.currentCount / this.maxCount) * 100);
                let fillClass = 'fill-0';
                if (percentage >= 100) fillClass = 'fill-100';
                else if (percentage >= 75) fillClass = 'fill-75';
                else if (percentage >= 50) fillClass = 'fill-50';
                else if (percentage >= 25) fillClass = 'fill-25';

                return {
                    ...user,
                    isDisabled: user.currentCount >= this.maxCount,
                    barClass: `bar-fill ${fillClass}`
                };
            });
        } catch (error) {
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: '유저 목록 불러오기 실패',
                variant: 'error'
            }));
            console.error(error);
        } finally {
            this.loading = false;
        }
    }

    async handleAssign(event) {
        const userId = event.target.dataset.userid;
        console.log('🧾 배정 파라미터', {
    userId,
    caseId: this.caseId,
    assetId: this.assetId
});
        try {
            const repairId = await createRepair({
                userId,
                caseId: this.caseId,
                assetId: this.assetId
            });

            this.dispatchEvent(new ShowToastEvent({
                title: '✅ 배정 완료',
                message: `수리 ID: ${repairId}`,
                variant: 'success'
            }));

            this.repairAssigned = true;

        } catch (error) {
            console.error('❌ 배정 실패:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: '❗ 수리 배정 실패',
                message: error.body?.message || error.message,
                variant: 'error'
            }));
        }
    }
}
