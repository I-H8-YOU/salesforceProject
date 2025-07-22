import { LightningElement, api, wire } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';

const ASSET_FIELDS = ['Asset.Product2Id'];
const PRODUCT_FIELDS = [
    'Product2.Name',
    'Product2.Description',
    'Product2.Image_File_Name__c'
];

const STATIC_RESOURCE_FOLDER = 'ProductImages';

export default class AssetProductInfo extends LightningElement {
    @api assetId;

    productId;
    product;

    @wire(getRecord, { recordId: '$assetId', fields: ASSET_FIELDS })
    wiredAsset({ data }) {
        if (data) {
            this.productId = data.fields.Product2Id?.value;
        }
    }

    @wire(getRecord, { recordId: '$productId', fields: PRODUCT_FIELDS })
    wiredProduct({ data }) {
        if (data) {
            const fileName = data.fields.Image_File_Name__c?.value;
            const imageUrl = fileName ? `/resource/${STATIC_RESOURCE_FOLDER}/${fileName}` : null;

            this.product = {
                name: data.fields.Name.value,
                description: data.fields.Description.value,
                imageUrl
            };
        }
    }

    handleImageError(event) {
        event.target.style.display = 'none';
    }
}
