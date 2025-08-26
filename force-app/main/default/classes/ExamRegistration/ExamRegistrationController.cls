public with sharing class ExamRegistrationController {
    
    @AuraEnabled
    public static Id createExamRegistration(String studentId, String examPeriodId) {
        try {
            Exam_Registration__c er = new Exam_Registration__c();
            er.Student__c = studentId;
            er.Exam_Period__c = examPeriodId;
            insert er;
            return er.Id;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating Exam Registration: ' + e.getMessage());
        }
    }

    @AuraEnabled(cacheable=true)
    public static List<Student__c> getAllRegistrations() {
        return [SELECT Id, Name FROM Student__c ORDER BY Name];
    }

    @AuraEnabled(cacheable=true)
    public static List<Exam_Registration__c> getRegistrations(Id examPeriodId) {
        return [
            SELECT Id, Name, Student__r.Name
            FROM Exam_Registration__c
            WHERE Exam_Period__c = :examPeriodId
            ORDER BY Student__r.Name
        ];
    }

    @AuraEnabled
    public static void cancelRegistration(Id registrationId) {
        try {
            delete [SELECT Id FROM Exam_Registration__c WHERE Id = :registrationId];
        } catch (DmlException e) {
            throw new AuraHandledException('Napaka pri odjavi: ' + e.getMessage());
        }
    }
}
