import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const FIELDS = [
    'Asset.Name',
    'Asset.SerialNumber',
    'Asset.Status',
    'Asset.InstallDate' // 설치일 또는 다른 중요 필드로 대체 가능
];

export default class AssetDetail extends LightningElement {
    @api assetId;
    record;

    @wire(getRecord, { recordId: '$assetId', fields: FIELDS })
    wired({ data }) {
        if (data) {
            this.record = {
                Name: data.fields.Name.value,
                SerialNumber: data.fields.SerialNumber.value,
                Status: data.fields.Status.value,
                InstallDate: data.fields.InstallDate?.value
            };
        }
    }
}
