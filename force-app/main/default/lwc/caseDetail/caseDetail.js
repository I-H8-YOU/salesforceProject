import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Case.Subject',
    'Case.Description',
    'Case.Status',
    'Case.CreatedDate'
];

export default class CaseDetail extends LightningElement {
    @api caseId;
    record;

    @wire(getRecord, { recordId: '$caseId', fields: FIELDS })
    wired({ data }) {
        if (data) {
            this.record = {
                Subject: data.fields.Subject.value,
                Description: data.fields.Description.value,
                Status: data.fields.Status.value,
                CreatedDate: data.fields.CreatedDate.value
            };
        }
    }
}
