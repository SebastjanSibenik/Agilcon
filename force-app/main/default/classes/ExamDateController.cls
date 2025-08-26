public with sharing class ExamDateController {

    @AuraEnabled(cacheable=true)
    public static List<Exam_Date__c> getExamDates() {
        try {
            return [
                SELECT Id, Name, Date_Time__c
                FROM Exam_Date__c
                ORDER BY Date_Time__c ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Exam Dates: ' + e.getMessage());
        }
    }

    @AuraEnabled
    public static void cancelRegistration(Id registrationId) {
        try {
            delete [SELECT Id FROM Exam_Registration__c WHERE Id = :registrationId];
        } catch (DmlException e) {
            throw new AuraHandledException('Could not cancel registration: ' + e.getMessage());
        }
    }
}
