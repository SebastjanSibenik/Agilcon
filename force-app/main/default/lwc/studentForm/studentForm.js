import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createStudent from '@salesforce/apex/StudentController.createStudent';
import validateEmso from '@salesforce/apex/StudentController.validateEmso';

export default class StudentForm extends LightningElement {
    // --- State ---
    student = {
        firstname: '',
        lastname: '',
        emso: '',
        studyType: '',
        isPayer: false
    };

    // --- Getters ---
    get showPayerCheckbox() {
        return this.student.studyType === 'izredni';
    }

    get studyOptions() {
        return [
            { label: 'Redni', value: 'redni' },
            { label: 'Izredni', value: 'izredni' }
        ];
    }

    // --- Event Handlers ---
    handleChange(event) {
        const { dataset, type, value, checked, detail } = event.target;
        const field = dataset.field || 'studyType';
        this.student = {
            ...this.student,
            [field]: type === 'checkbox' ? checked : (detail?.value ?? value)
        };
    }

    async handleSave() {
        try {
            await validateEmso({ emso: this.student.emso });
            await createStudent({ ...this.student });
            this.showToast('Uspeh', 'Študent je bil uspešno vpisan', 'success');
            this.resetInputFields();
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    // --- Helpers ---
    resetInputFields() {
        this.student = {
            firstname: '',
            lastname: '',
            emso: '',
            studyType: '',
            isPayer: false
        };
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
