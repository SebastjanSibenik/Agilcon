import { LightningElement, wire, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createExamRegistration from '@salesforce/apex/ExamRegistrationController.createExamRegistration';
import getExamPeriods from '@salesforce/apex/ExamPeriodController.getExamPeriods';
import getStudents from '@salesforce/apex/ExamRegistrationController.getAllRegistrations';

export default class ExamRegistrationForm extends LightningElement {
    studentValue = '';
    examPeriodValue = '';

    examPeriodOptions = [];
    studentsOptions = [];

    // Load exam periods
    @wire(getExamPeriods)
    wiredExamPeriods({ data, error }) {
        if (data) {
            this.examPeriodOptions = data.map(ep => ({
                label: ep.Name,
                value: ep.Id
            }));
        } else if (error) {
            console.error('Error loading exam periods', error);
        }
    }

    // Load students
    @wire(getStudents)
    wiredStudents({ data, error }) {
        if (data) {
            this.studentsOptions = data.map(st => ({
                label: st.Name,
                value: st.Id
            }));
        } else if (error) {
            console.error('Error loading students', error);
        }
    }

    handleStudentChange(event) {
        this.studentValue = event.detail.value;
    }

    handleExamPeriodTypeChange(event) {
        this.examPeriodValue = event.detail.value;
    }

    async handleSave() {
        try {
            await createExamRegistration({
                studentId: this.studentValue,
                examPeriodId: this.examPeriodValue
            });

            this.showToast('Uspeh', 'Izpitna prijava je bila uspešno ustvarjena!', 'success');
            this.resetForm();
        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    resetForm() {
        this.studentValue = '';
        this.examPeriodValue = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
