import { LightningElement, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import createExamPeriod from '@salesforce/apex/ExamPeriodController.createExamPeriod';
import getCourses from '@salesforce/apex/ExamPeriodController.getCourses';
import getOwners from '@salesforce/apex/OwnerController.getOwners';

export default class ExamPeriodForm extends LightningElement {
    name = '';
    ownerValue = '';   // ✅ match template
    examDate = '';
    course = '';
    maxRegistrations = 0;
    status = '';
    @track courseOptions = [];
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

    @wire(getCourses)
    wiredCourses({ data, error }) {
        if (data) {
            this.courseOptions = data.map(course => ({
                label: course.Name,
                value: course.Id
            }));
        } else if (error) {
            console.error('Error loading courses', error);
        }
    }

    get statusOptions() {
        return [
            { label: 'Open', value: 'Open' },
            { label: 'Closed', value: 'Closed' }
        ];
    }

    handleInputChange(event) {
        const field = event.target.dataset.field;
        this[field] = event.target.value;
    }

    handleOwnerChange(event) {
        this.ownerValue = event.detail.value;  // ✅ store selected owner
    }

    handleCourseTypeChange(event) {
        this.course = event.detail.value;
    }

    handleStatusTypeChange(event) {
        this.status = event.detail.value;
    }

    async handleSave() {
        try {
            await createExamPeriod({
                name: this.name,
                ownerId: this.ownerValue,   // ✅ send correct value
                examDate: this.examDate,
                courseId: this.course,
                maxRegistrations: this.maxRegistrations,
                status: this.status
            });

            this.showToast('Uspeh', 'Izpitni rok je bil uspešno ustvarjen!', 'success');
            this.resetForm();

        } catch (error) {
            this.showToast('Napaka', error.body?.message || error.message, 'error');
        }
    }

    resetForm() {
        this.name = '';
        this.ownerValue = '';
        this.examDate = '';
        this.course = '';
        this.maxRegistrations = 0;
        this.status = '';
    }

    showToast(title, message, variant) {
        this.dispatchEvent(new ShowToastEvent({ title, message, variant }));
    }
}
