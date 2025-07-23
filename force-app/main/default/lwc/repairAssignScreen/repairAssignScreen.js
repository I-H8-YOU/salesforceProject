\import { LightningElement, api, track } from 'lwc';
import getAssignableUsers from '@salesforce/apex/RepairAssignmentHandler.getAssignableUsers';
import createRepair from '@salesforce/apex/RepairAssignmentHandler.createRepair';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class RepairAssignScreen extends LightningElement {
    @api contactId;
    @api accountId;
    @api assetId;

    _caseId;
    @track users = [];
    @track loading = false;
    @track repairAssigned = false;
    maxCount = 4;

    // caseId가 세팅되면 바로 fetchUsers 실행
    @api
    set caseId(value) {
        this._caseId = value;
        console.log('📥 [set caseId]:', value);
        if (value) {
            this.fetchUsers();
        }
    }
    get caseId() {
        return this._caseId;
    }

    async fetchUsers() {
        this.loading = true;
        console.log(' [fetchUsers] 시작');

        try {
            const result = await getAssignableUsers();
            console.log(' [Apex 결과]:', result);

            if (!Array.isArray(result)) {
                throw new Error(' Apex 응답이 배열이 아님');
            }

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

            console.log(' [users 최종]:', this.users);
        } catch (error) {
            console.error(' [fetchUsers 실패]:', error);
            this.dispatchEvent(new ShowToastEvent({
                title: 'Error',
                message: '유저 목록 불러오기 실패',
                variant: 'error'
            }));
        } finally {
            this.loading = false;
            console.log(' [fetchUsers 종료]');
        }
    }

    async handleAssign(event) {
        const userId = event.target.dataset.userid;
        console.log(' [배정 요청]:', {
            userId,
            caseId: this.caseId,
            assetId: this.assetId
        });

        try {
            const repairId = await createRepair({
                userId: userId,
                caseId: this.caseId
            });

            this.dispatchEvent(new ShowToastEvent({
                title: ' 배정 완료',
                message: `수리 ID: ${repairId}`,
                variant: 'success'
            }));

            this.repairAssigned = true;
        } catch (error) {
            console.error(' 배정 실패:', error);
            const message =
                error?.body?.message ||
                error?.message ||
                '알 수 없는 오류가 발생했습니다.';

            this.dispatchEvent(new ShowToastEvent({
                title: '수리 배정 실패',
                message,
                variant: 'error'
            }));
        }
    }
}
