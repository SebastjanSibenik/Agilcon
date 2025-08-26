import { LightningElement, api, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getRegistrations from '@salesforce/apex/ExamRegistrationController.getRegistrations';
import cancelRegistration from '@salesforce/apex/ExamRegistrationController.cancelRegistration';

export default class ExamRegistrationsList extends LightningElement {
    @api recordId; // Salesforce avtomatsko poda Exam_Period__c Id na record page
    @track registrations = [];
    @track isLoading = false;

    @wire(getRegistrations, { examPeriodId: '$recordId' })
    wiredRegs({ data, error }) {
        if (data) {
            this.registrations = data;
        } else if (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    async handleCancel(event) {
        const regId = event.target.dataset.id;
        this.isLoading = true;
        try {
            await cancelRegistration({ registrationId: regId });
            this.showToast('Uspeh', 'Študent je bil uspešno odjavljen!', 'success');
            // Refresh lista
            this.registrations = this.registrations.filter(r => r.Id !== regId);
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        } finally {
            this.isLoading = false;
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
