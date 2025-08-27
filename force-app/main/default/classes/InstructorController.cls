public with sharing class InstructorController {
    /**
     * Retrieves all Instructor__c records from Salesforce.
     * This method is cacheable, meaning Lightning components can cache results
     * for improved performance and fewer server calls.
     *
     * @return List of Instructor__c containing Id, Name, and Email__c
     */
    @AuraEnabled(cacheable=true)
    public static List<Instructor__c> getInstructors() {
        return [
            SELECT Id, Name, Email__c
            FROM Instructor__c
            ORDER BY Name
        ];
    }
}
