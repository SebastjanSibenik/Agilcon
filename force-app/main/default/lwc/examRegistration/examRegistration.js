import { LightningElement, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getExamDates from '@salesforce/apex/ExamRegistrationController.getExamDates';
import getSubjects from '@salesforce/apex/ExamRegistrationController.getSubjects';
import saveRegistration from '@salesforce/apex/ExamRegistrationController.saveRegistration';
import getStudents from '@salesforce/apex/StudentController.getStudents';

export default class ExamRegistration extends LightningElement {
    // --- State ---
    examDates = [];
    selectedExamDateId = '';
    selectedStudentId = '';
    selectedSubjectId = '';
    students = [];
    subjects = [];

    // --- Wire ---
    @wire(getStudents)
    getStudents({ data, error }) {
        if (data) {
            this.students = data.map(s => ({ label: s.Name, value: s.Id }));
        } else if (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    @wire(getSubjects)
    getSubjects({ data, error }) {
        if (data) {
            this.subjects = data.map(s => ({ label: s.Name, value: s.Id }));
        } else if (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    @wire(getExamDates)
    getExamDates({ data, error }) {
        if (data) {
            this.examDates = data.map(e => ({ label: e.Name, value: e.Id }));
        } else if (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
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
        if (!this.selectedStudentId || !this.selectedSubjectId || !this.selectedExamDateId) {
            this.showToast('Error', 'Please select a student, subject, and exam date', 'error');
            return;
        }

        try {
            const result = await saveRegistration({
                studentId: this.selectedStudentId,
                subjectId: this.selectedSubjectId,
                examDateId: this.selectedExamDateId
            });

            this.showToast('Success', 'Registration created! ID: ' + result, 'success');
            this.resetForm();
        } catch (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
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
