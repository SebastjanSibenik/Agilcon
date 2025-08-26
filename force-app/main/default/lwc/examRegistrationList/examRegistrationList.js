import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelRegistration from '@salesforce/apex/ExamRegistrationController.cancelRegistration';
import getExamRegistrations from '@salesforce/apex/ExamRegistrationController.getExamRegistrations';
import { refreshApex } from '@salesforce/apex';

const COLUMNS = [
    { label: 'Študent', fieldName: 'studentName', type: 'text' },
    {
        type: 'action',
        typeAttributes: { rowActions: [{ label: 'Odjavi', name: 'cancel' }] }
    }
];

export default class ExamRegistrationsList extends LightningElement {
    // --- Public API ---
    @api recordId;

    // --- State ---
    columns = COLUMNS;
    registrations = [];
    _results;

    // --- Wire ---
    @wire(getExamRegistrations, { examDateId: '$recordId' })
    getExamRegistrations(result) {
        this._results = result;
        const { data, error } = result;
        if (data) {
            this.registrations = data.map(r => ({
                ...r,
                studentName: r.Student__r?.Name || ''
            }));
        } else if (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    // --- Event Handlers ---
    async handleRowAction(event) {
        const { action, row } = event.detail;
        if (action.name === 'cancel') {
            await this.handleCancel(row.Id);
        }
    }

    async handleCancel(registrationId) {
        try {
            await cancelRegistration({ registrationId });
            this.showToast('Uspeh', 'Študent je bil uspešno odjavljen!', 'success');
            await refreshApex(this._results);
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    // --- Helpers ---
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
