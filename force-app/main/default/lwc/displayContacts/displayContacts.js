import { LightningElement, track, api, wire } from 'lwc';
import getContactsByCaseId from '@salesforce/apex/ContactSelectorController.getContactsByCaseId';
import updateContact from '@salesforce/apex/ContactSelectorController.updateContact';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class DisplayContacts extends LightningElement {
    @api recordId; // Case Id
    @track contacts;
    @track error;
    contactId;

    get hasNoContactSelected() {
        return !this.contactId;
    }

    columns = [
        { label: 'Name', fieldName: 'Name' },
        { label: 'Email', fieldName: 'Email' },
        {
            type: 'button',
            typeAttributes: {
                label: '선택',
                name: 'select_contact',
                variant: { fieldName: 'buttonVariant' }
            }
        }
    ];

    @wire(getContactsByCaseId, { caseId: '$recordId' })
    wiredContacts({ error, data }) {
        if (data) {
            this.contacts = data.map(c => ({
                ...c,
                buttonVariant: c.Id === this.contactId ? 'success' : 'brand'
            }));
            this.error = undefined;
        } else if (error) {
            this.error = error.body.message;
            this.contacts = undefined;
        }
    }

    handleRowAction(event) {
        const selectedId = event.detail.row.Id;
        this.contactId = selectedId;

        this.contacts = this.contacts.map(c => ({
            ...c,
            buttonVariant: c.Id === selectedId ? 'success' : 'brand'
        }));
    }

    applySelectedContact() {
        if (!this.contactId) return;

        updateContact({ caseId: this.recordId, contactId: this.contactId })
            .then(() => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: '연락처 적용 완료!',
                        variant: 'success'
                    })
                );
                window.location.reload();
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: '오류',
                        message: error.body.message,
                        variant: 'error'
                    })
                );
            });
    }
}