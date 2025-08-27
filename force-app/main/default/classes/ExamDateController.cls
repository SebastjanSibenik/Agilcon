// Optional can be deleted - ToDo
public with sharing class ExamDateController {

    /**
     * Cancels (deletes) an Exam Registration by its Id.
     *
     * @param registrationId Id of the registration to cancel
     * @throws AuraHandledException if deletion fails
     */
    @AuraEnabled
    public static void cancelRegistration(Id registrationId) {
        try {
            delete [
                SELECT Id 
                FROM Exam_Registration__c 
                WHERE Id = :registrationId
            ];
        } catch (DmlException e) {
            throw new AuraHandledException('Napaka pri odjavi od izpita: ' + e.getMessage());
        }
    }

    /**
     * Retrieves a single Exam_Date__c record by Id.
     * Cacheable for Lightning performance optimization.
     *
     * @param examDateId Id of the exam date
     * @return List containing the Exam_Date__c record
     * @throws AuraHandledException if query fails
     */
    @AuraEnabled(cacheable=true)
    public static List<Exam_Date__c> getById(Id examDateId) {
        try {
            return [
                SELECT Id, Status__c 
                FROM Exam_Date__c 
                WHERE Id = :examDateId
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Exam Date: ' + e.getMessage());
        }
    }

    /**
     * Retrieves all Exam_Date__c records ordered by Date_Time__c descending.
     * Cacheable for Lightning performance optimization.
     *
     * @return List of Exam_Date__c with Id, Name, Date_Time__c
     * @throws AuraHandledException if query fails
     */
    @AuraEnabled(cacheable=true)
    public static List<Exam_Date__c> getExamDates() {
        try {
            return [
                SELECT Id, Name, Date_Time__c
                FROM Exam_Date__c
                ORDER BY Name ASC
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching Exam Dates: ' + e.getMessage());
        }
    }

    /**
     * Retrieves the Subject__c associated with a given Exam_Date__c record.
     *
     * @param examDateId Id of the Exam Date
     * @return Id of the Subject__c associated with the Exam Date
     * @throws AuraHandledException if Exam Date is not found or has no Subject
     */
    @AuraEnabled(cacheable=true)
    public static Id getSubjectFromExamDate(Id examDateId) {
        try {
            Exam_Date__c examDate = [
                SELECT Id, Subject__c, Subject__r.Name 
                FROM Exam_Date__c 
                WHERE Id = :examDateId
                LIMIT 1
            ];
            
            if (examDate.Subject__c == null) {
                throw new AuraHandledException('Exam Date does not have a Subject assigned.');
            }
            
            return examDate.Subject__c;
        } catch (QueryException e) {
            throw new AuraHandledException('Could not retrieve Subject for Exam Date: ' + e.getMessage());
        }
    }
}
