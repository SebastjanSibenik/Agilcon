public with sharing class InstructorController {
    
  public InstructorController() {}

  @AuraEnabled(cacheable=true)
  public static List<Instructor__c> getInstructors() {
    return [SELECT Id, Name, Email__c FROM Instructor__c ORDER BY Name];
  }
}
