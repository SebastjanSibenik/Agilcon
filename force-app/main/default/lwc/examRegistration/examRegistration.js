import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExamDatesApex from '@salesforce/apex/ExamRegistrationController.getExamDates';
import saveRegistrationApex from '@salesforce/apex/ExamRegistrationController.saveRegistration';
import getStudentsApex from '@salesforce/apex/StudentController.getStudents';


// Optional can be deleted - ToDo
export default class ExamRegistration extends LightningElement {
    // --- State ---
    examDates = [];
    selectedExamDateId = '';
    selectedStudentId = '';
    students = [];

    // --- Wire Services ---
    @wire(getStudentsApex)
    wiredStudents({ data, error }) {
        if (data) {
            this.students = data.map(s => ({ label: s.Name, value: s.Id }));
        } else if (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    @wire(getExamDatesApex)
    wiredExamDates({ data, error }) {
        if (data) {
            this.examDates = data.map(e => ({ label: e.Name, value: e.Id }));
        } else if (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    // --- Getters ---
    get isFormComplete() {
        return this.selectedStudentId && this.selectedExamDateId;
    }

    // --- Event Handlers ---
    handleStudentChange(event) {
        this.selectedStudentId = event.detail.value;
    }

    handleSubjectChange(event) {
        this.selectedSubjectId = event.detail.value;
    }

    handleExamDateChange(event) {
        this.selectedExamDateId = event.detail.value;
    }

    async handleRegister() {
        if (!this.isFormComplete) {
            this.showToast('Napaka', 'Izberite študenta, predmet in izpitni rok', 'error');
            return;
        }

        try {
            await saveRegistrationApex({
                studentId: this.selectedStudentId,
                examDateId: this.selectedExamDateId
            });

            this.showToast('Uspeh', 'Prijava uspešno ustvarjena!', 'success');
            this.resetForm();
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    // --- Helpers ---
    resetForm() {
        this.selectedStudentId = '';
        this.selectedSubjectId = '';
        this.selectedExamDateId = '';
        this.template.querySelectorAll('lightning-combobox').forEach(cb => (cb.value = ''));
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
