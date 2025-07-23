import { LightningElement, api, wire, track } from 'lwc';
import getRecord from '@salesforce/apex/CaseDetailService.getCaseDetail';

export default class FullCaseView extends LightningElement {
    @api caseId;
    @track record;
    @track error;
    timer;

    @wire(getRecord, { caseId: '$caseId' })
    wiredCase({ error, data }) {
        if (data) {
            const cloned = { ...data };

            cloned.Milestones = cloned.Milestones?.map(m => ({
                ...m,
                statusText: m.IsCompleted ? '✅ 완료됨' : '⏳ 진행 중',
                hasCompletionDate: !!m.CompletionDate,
                timeLeft: this.getTimeLeft(m.TargetDate, m.IsCompleted)
            }));

            this.record = cloned;
            this.error = null;
            this.startTimer();
        } else if (error) {
            this.record = null;
            this.error = error.body.message || '데이터를 불러오는 중 오류 발생';
        }
    }

    disconnectedCallback() {
        this.stopTimer();
    }

    startTimer() {
        this.stopTimer();
        this.timer = setInterval(() => this.updateTimers(), 1000);
    }

    stopTimer() {
        if (this.timer) clearInterval(this.timer);
    }

    updateTimers() {
        if (!this.record?.Milestones) return;

        const updatedMilestones = this.record.Milestones.map(m => {
            if (m.IsCompleted) return m;

            return {
                ...m,
                timeLeft: this.getTimeLeft(m.TargetDate, false)
            };
        });

        this.record = {
            ...this.record,
            Milestones: updatedMilestones
        };
    }

    getTimeLeft(targetStr, isCompleted) {
        if (!targetStr || isCompleted) return '✅ 완료됨';

        const now = new Date();
        const target = new Date(targetStr);
        const diff = target - now;

        if (diff <= 0) return '⏱ 마감됨';

        const hrs = Math.floor(diff / 3600000);
        const mins = Math.floor((diff % 3600000) / 60000);
        const secs = Math.floor((diff % 60000) / 1000);

        return `${hrs}시간 ${mins}분 ${secs}초 남음`;
    }
}
