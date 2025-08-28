public with sharing class ExamDateController {
    /**
     * Retrieves a single Exam_Date__c record by Id.
     * Cacheable for Lightning performance optimization.
     *
     * @param examDateId Id of the exam date
     * @return The Exam_Date__c record with fields Id, Status__c, and Subject__r.Name
     * @throws AuraHandledException if query fails
     */
    @AuraEnabled(cacheable=true)
    public static Exam_Date__c getById(Id examDateId) {
        try {
            return [
                SELECT Id, Status__c, Subject__r.Name  
                FROM Exam_Date__c 
                WHERE Id = :examDateId
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Napaka pri pridobivanju izpitnega roka: ' + e.getMessage());
        }
    }

    /**
     * Retrieves all Exam_Date__c records ordered by Name ascending.
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
            throw new AuraHandledException('Napaka pri pridobivanju izpitnih rokov: ' + e.getMessage());
        }
    }

    /**
     * Retrieves the Subject Id associated with a given Exam_Date__c record.
     *
     * @param examDateId Id of the Exam Date
     * @return Id of the Subject__c associated with the Exam Date
     * @throws AuraHandledException if Exam Date is not found or has no Subject
     */
    @AuraEnabled(cacheable=true)
    public static Id getSubjectIdFromExamDate(Id examDateId) {
        try {

            Exam_Date__c examDate = getById(examDateId);
            if (examDate.Subject__c == null) {
                throw new AuraHandledException('Izpitni rok nima povezanega predmeta.');
            }
            
            return examDate.Subject__c;
        } catch (QueryException e) {
            throw new AuraHandledException('Napaka pri pridobivanju predmeta od izpitnega roka: ' + e.getMessage());
        }
    }
}
