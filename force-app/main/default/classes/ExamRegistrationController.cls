public with sharing class ExamRegistrationController {
@AuraEnabled
public static Id saveRegistration(Id studentId, Id examDateId, Id subjectId) {
    try {
        // Check if registration already exists
        Exam_Registration__c existing = [
            SELECT Id 
            FROM Exam_Registration__c 
            WHERE Student__c = :studentId 
              AND Exam_Date__c = :examDateId 
              AND Subject__c = :subjectId
            LIMIT 1
        ];

        if (existing != null) {
            throw new AuraHandledException('Ta študent je že prijavljen na ta izpitni rok.');
        }
    } catch (QueryException e) {
        // no existing record → safe to insert
    }

    try {
        Exam_Registration__c er = new Exam_Registration__c();
        er.Student__c = studentId;
        er.Subject__c = subjectId;
        er.Exam_Date__c = examDateId;
        er.Name = 'Registration - ' + studentId + ' - ' + subjectId + ' - ' + examDateId;
        insert er;
        return er.Id;
    } catch (DmlException e) {
        throw new AuraHandledException('Error creating Exam Registration: ' + e.getMessage());
    }
}

  @AuraEnabled(cacheable=true)
  public static List<Exam_Date__c> getExamDates() {
    return [SELECT Id, Name FROM Exam_Date__c ORDER BY Name];
  }

  @AuraEnabled(cacheable=true)
  public static List<Exam_Registration__c> getExamRegistrations(Id examDateId) {
    return [
      SELECT Id, Student__c, Student__r.Name
      FROM Exam_Registration__c
      WHERE Exam_Date__c = :examDateId
      ORDER BY Student__r.Name
    ];
  }

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
      throw new AuraHandledException('Napaka pri odjavi: ' + e.getMessage());
    }
  }

  @AuraEnabled(cacheable=true)
  public static List<Subject__c> getSubjects() {
    return [SELECT Id, Name FROM Subject__c ORDER BY Name];
  }
}
