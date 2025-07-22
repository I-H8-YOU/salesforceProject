import { LightningElement, api, wire, track } from 'lwc';
import getRecord from '@salesforce/apex/CaseDetailService.getCaseDetail';

export default class FullCaseView extends LightningElement {
    @api caseId;
    @track record;
    @track error;

    @wire(getRecord, { caseId: '$caseId' })
    wiredCase({ error, data }) {
        if (data) {
            this.record = data;
            this.error = null;
        } else if (error) {
            this.record = null;
            this.error = error.body.message || '데이터를 불러오는 중 오류 발생';
        }
    }
}
