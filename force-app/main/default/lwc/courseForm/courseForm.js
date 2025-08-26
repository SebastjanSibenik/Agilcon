import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createCourse from '@salesforce/apex/CourseController.createCourse';
import getOwners from '@salesforce/apex/OwnerController.getOwners';

export default class CourseForm extends LightningElement {
    name = '';
    description = '';
    code = '';
    ownerValue = '';
    ownerOptions = [];

    connectedCallback() {
        this.loadOwners();
    }

    loadOwners() {
        getOwners()
            .then(result => {
                this.ownerOptions = result.map(record => ({
                    label: record.Name + ' ' + (record.Surname__c || ''),
                    value: record.Id
                }));
            })
            .catch(error => {
                console.error('Error loading owners', error);
            });
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleOwnerChange(event) {
        this.ownerValue = event.detail.value;
    }

    async handleSave() {
        if (!this.name || !this.ownerValue || !this.description || !this.code) {
            this.showToast('Napaka', 'Vsa polja so obvezna.', 'error');
            return;
        }

        try {
            await createCourse({
                name: this.name,
                ownerId: this.ownerValue,  // ✅ sends Owner__c Id
                description: this.description,
                code: this.code
            });

            this.showToast('Uspeh', 'Predmet je bil uspešno ustvarjen!', 'success');
            this.resetForm();

        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    resetForm() {
        this.name = '';
        this.description = '';
        this.code = '';
        this.ownerValue = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
