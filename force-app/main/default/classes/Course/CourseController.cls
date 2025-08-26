public with sharing class CourseController {
  @AuraEnabled
  public static void createCourse(
    String name,
    String ownerId,
    String description,
    String code
  ) {
    try {
      Course__c c = new Course__c();
      c.Name = name;
      c.Owner__c = ownerId; 
      c.Desctiption__c = description;
      c.Code__c = code;
      insert c;
    } catch (DmlException e) {
      throw new AuraHandledException(
        'Error creating course: ' + e.getMessage()
      );
    }
  }
}
