import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createStudent from '@salesforce/apex/StudentController.createStudent';
import validateEmso from '@salesforce/apex/StudentController.validateEmso';

export default class StudentForm extends LightningElement {

    name = '';
    surname = '';
    emso = '';
    studyType = '';
    payer = false;

    get studyOptions() {
        return [
            { label: 'Redni', value: 'redni' },
            { label: 'Izredni', value: 'izredni' }
        ];
    }

    get showPayerCheckbox() {
        return this.studyType === 'izredni';
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.type === 'checkbox' ? event.target.checked : event.target.value;
    }

    handleStudyTypeChange(event) {
        this.studyType = event.detail.value;
    }

    async validateEMSO() {
        try {
            const result = await validateEmso({ emso: this.emso });
            if (!result) {
                throw new Error('EMSO is invalid.');
            }
            this.showToast('OK', 'EMSO is correct!', 'success');
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
            throw error;
        }
    }

    async createStudent() {
        try {
            await createStudent({
                name: this.name,
                surname: this.surname,
                emso: this.emso,
                studyType: this.studyType,
                payer: this.payer
            });
            this.showToast('Uspeh', 'Študent je bil uspešno vpisan', 'success');
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
            throw error;
        }
    }

    async handleSave() {
        try {
            await this.validateEMSO();
            await this.createStudent();
            this.resetInputFields();
        } catch (error) {
        }
    }

    resetInputFields() {
        this.name = '';
        this.surname = '';
        this.emso = '';
        this.studyType = '';
        this.payer = false;
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
