import { LightningElement, api, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import cancelRegistrationApex from '@salesforce/apex/ExamRegistrationController.cancelRegistration';
import getExamRegistrationsApex from '@salesforce/apex/ExamRegistrationController.getExamRegistrations';
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
    _wiredResult;

    // --- Getters ---
    get hasRegistrations() {
        return this.registrations.length > 0;
    }

    // --- Wire Service ---
    @wire(getExamRegistrationsApex, { examDateId: '$recordId' })
    wiredExamRegistrations(result) {
        this._wiredResult = result;
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
    handleRowAction(event) {
        const { action, row } = event.detail;
        if (action.name === 'cancel') {
            this.handleCancel(row.Id);
        }
    }

    async handleCancel(registrationId) {
        try {
            await this.cancelRegistration(registrationId);
            this.showToast('Uspeh', 'Študent je bil uspešno odjavljen!', 'success');
            await refreshApex(this._wiredResult);
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    // --- Apex Calls ---
    async cancelRegistration(registrationId) {
        return cancelRegistrationApex({ registrationId });
    }

    // --- Helpers ---
    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
