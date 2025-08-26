import { LightningElement, wire, track } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import getExamDates from '@salesforce/apex/ExamDateController.getExamDates';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class ExamDatesList extends NavigationMixin(LightningElement) {
    @track examDates = [];

    columns = [
        {
            label: 'Exam Name',
            fieldName: 'recordLink',
            type: 'url',
            typeAttributes: { label: { fieldName: 'Name' }, target: '_self' }
        },
    ];

    @wire(getExamDates)
    wiredExamDates({ error, data }) {
        if (data) {
            this.examDates = data.map(ed => ({
                ...ed,
                recordLink: `/lightning/r/Exam_Date__c/${ed.Id}/view`
            }));
        } else if (error) {
            this.showToast('Error', error.body?.message || error.message, 'error');
        }
    }

    showToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({ title, message, variant })
        );
    }
}
