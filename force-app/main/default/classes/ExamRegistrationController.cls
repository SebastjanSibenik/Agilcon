// Optional can be deleted - ToDo
public with sharing class ExamRegistrationController {

    /**
     * Cancels (deletes) an Exam Registration by Id.
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
                LIMIT 1
            ];
        } catch (DmlException e) {
            throw new AuraHandledException('Napaka pri odjavi od izpitnega roka: ' + e.getMessage());
        }
    }

    /**
     * Retrieves all Exam Dates, ordered alphabetically by Name.
     * Cacheable for Lightning performance optimization.
     *
     * @return List of Exam_Date__c
     */
    @AuraEnabled(cacheable=true)
    public static List<Exam_Date__c> getExamDates() {
        return [
            SELECT Id, Name
            FROM Exam_Date__c
            ORDER BY Name
        ];
    }

    /**
     * Retrieves all Exam Registrations for a given Exam Date.
     * Orders students alphabetically by Name.
     *
     * @param examDateId Id of the Exam Date
     * @return List of Exam_Registration__c with Student reference
     */
    @AuraEnabled(cacheable=true)
    public static List<Exam_Registration__c> getExamRegistrations(Id examDateId) {
        return [
            SELECT Id, Student__c, Student__r.Name
            FROM Exam_Registration__c
            WHERE Exam_Date__c = :examDateId
            ORDER BY Student__r.Name
        ];
    }

    /**
     * Checks if a student is already registered for a specific exam date.
     *
     * @param studentId Id of the student
     * @param examDateId Id of the exam date
     * @return Boolean true if duplicate exists, false otherwise
     */
    public static Boolean isDuplicateRegistration(Id studentId, Id examDateId) {
        List<Exam_Registration__c> existingList = [
            SELECT Id
            FROM Exam_Registration__c
            WHERE Student__c = :studentId
              AND Exam_Date__c = :examDateId
            LIMIT 1
        ];
        return !existingList.isEmpty();
    }

    /**
     * Retrieves all subjects, ordered alphabetically by Name.
     * Cacheable for Lightning performance optimization.
     *
     * @return List of Subject__c
     */
    @AuraEnabled(cacheable=true)
    public static List<Subject__c> getSubjects() {
        return [
            SELECT Id, Name
            FROM Subject__c
            ORDER BY Name
        ];
    }

    /**
     * Creates a new Exam Registration for a student and exam date.
     * Prevents duplicate registrations.
     *
     * @param studentId Id of the student
     * @param examDateId Id of the exam date
     * @return Id of the newly created Exam_Registration__c record
     * @throws AuraHandledException if a registration already exists or DML fails
     */
    @AuraEnabled
    public static void saveRegistration(Id studentId, Id examDateId) {
        try {
            // Step 1: Check if the exam date is open
            List<Exam_Date__c> examDates = ExamDateController.getById(examDateId);
            if (examDates.isEmpty() || examDates[0].Status__c != 'Open') {
                throw new AuraHandledException('Prijave za izpitni rok niso odprte.');
            }

            // Step 2: Check for duplicate registration
            if (isDuplicateRegistration(studentId, examDateId)) {
                throw new AuraHandledException('Študent je že prijavljen na izpitni rok.');
            }
        } catch (QueryException e) {
            System.debug('Student does not exist in the DB, continuing...');
        }

        // Step 3: Get Subject from Exam Date
        Id subjectId = ExamDateController.getSubjectFromExamDate(examDateId);

        // Step 4: Insert new registration
        try {
            Exam_Registration__c er = new Exam_Registration__c(
                Student__c   = studentId,
                Subject__c   = subjectId,
                Exam_Date__c = examDateId,
                Name         = 'Registration - ' + studentId + ' - ' + subjectId + ' - ' + examDateId
            );
            insert er;
        } catch (DmlException e) {
            throw new AuraHandledException('Napaka pri prijavi na izpitni rok: ' + e.getMessage());
        }
    }
}
