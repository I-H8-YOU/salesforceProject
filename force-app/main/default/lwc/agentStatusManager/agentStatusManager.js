import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import updateAgentStatus from '@salesforce/apex/AgentStatusController.updateAgentStatus';
import getCurrentAgentStatus from '@salesforce/apex/AgentStatusController.getCurrentAgentStatus';


export default class AgentStatusManager extends LightningElement {
    @track selectedStatus = '선택 해주세요..';
    @api currentAgentStatus = '상담가능';

    connectedCallback() {
        getCurrentAgentStatus()
            .then(status => {
                this.currentAgentStatus = status;
                this.selectedStatus = status;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '상태 로딩 실패',
                        message: error.body?.message || '상태를 불러오지 못했습니다.',
                        variant: 'error'
                    })
                );
            });
    }
    get statusOptions() {
        return [
            { label: '상담가능', value: '상담가능' },
            { label: '상담불가', value: '상담불가' },
            { label: '자리비움', value: '자리비움' },
            { label: '오프라인', value: '오프라인' },
        ];
    }

    get statusClass() {
        return `status-${this.currentAgentStatus}`;
    }

    get indicatorStyle() {
        const colorMap = {
            '상담가능': '#2ecc71',
            '상담불가': '#e74c3c',
            '자리비움': '#f39c12',
            '오프라인': '#95a5a6'
        };
        const color = colorMap[this.currentAgentStatus] || '#cccccc';
        return `background-color: ${color};`;
    }

    handleStatusChange(event) {
        this.selectedStatus = event.detail.value;
    }

    saveStatus() {
        updateAgentStatus({ status: this.selectedStatus })
            .then(() => {
                this.currentAgentStatus = this.selectedStatus;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '상태 저장 완료',
                        message: `상태가 "${this.selectedStatus}"(으)로 설정되었습니다.`,
                        variant: 'success'
                    })
                );
                this.currentAgentStatus = this.selectedStatus;
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '상태 저장 실패',
                        message: error.body?.message || '알 수 없는 오류가 발생했습니다.',
                        variant: 'error'
                    })
                );
            });
    }
}