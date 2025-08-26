public with sharing class ExamPeriodController {
    @AuraEnabled
    public static void createExamPeriod(
        String name,
        String ownerId,   // <-- actually Owner__c
        Datetime examDate,
        String courseId,
        Integer maxRegistrations,
        String status
    ) {
        try {
            Exam_Period__c ep = new Exam_Period__c();
            ep.Name = name;
            ep.Owner__c = ownerId;       // ✅ custom lookup, not OwnerId
            ep.Exam_Date__c = examDate;
            ep.Course__c = courseId;
            ep.Max_Registrations__c = maxRegistrations;
            ep.Status__c = status;
            insert ep;
        } catch (DmlException e) {
            throw new AuraHandledException('Error creating Exam Period: ' + e.getMessage());
        }
    }

  @AuraEnabled(cacheable=true)
  public static List<Course__c> getCourses() {
    return [SELECT Id, Name FROM Course__c ORDER BY Name LIMIT 50];
  }

    @AuraEnabled(cacheable=true)
  public static List<Exam_Period__c> getExamPeriods() {
    return [SELECT Id, Name FROM Exam_Period__c ORDER BY Name];
  }

}
