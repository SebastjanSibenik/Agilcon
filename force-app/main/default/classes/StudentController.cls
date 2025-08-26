public with sharing class StudentController {
  @AuraEnabled
  public static Id createStudent(
    String firstname,
    String lastname,
    String emso,
    String studyType,
    Boolean payer
  ) {
    try {
      Student__c s = new Student__c();
      s.Name = firstname + ' ' + lastname;
      s.EMSO__c = emso;
      s.Study_Type__c = studyType;
      s.Payer__c = payer;
      insert s;
      return s.Id;
    } catch (DmlException e) {
      throw new AuraHandledException('Error saving student: ' + e.getMessage());
    }
  }

  @AuraEnabled
  public static String validateEmso(String emso) {
    String endpoint =
      'https://app.agilcon.com/job/emso.php?emso=' +
      EncodingUtil.urlEncode(emso, 'UTF-8');

    HttpRequest request = new HttpRequest();
    request.setEndpoint(endpoint);
    request.setMethod('GET');
    request.setHeader('Content-Type', 'application/json');

    Http http = new Http();
    HttpResponse response = http.send(request);

    Map<String, Object> r = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
    if (response.getStatusCode() != 200) {
        throw new AuraHandledException('EMSO validation failed. HTTP ' + response.getStatusCode() + 'Error message: ' + r.get('message'));
    }

    if (!(Boolean) r.get('success')) {
        throw new AuraHandledException((String) r.get('message'));
    }

    return (String) r.get('message');
  }


  @AuraEnabled(cacheable=true)
  public static List<Student__c> getStudents() {
    try {
      return [
        SELECT Id, Name
        FROM Student__c
        ORDER BY Name
      ];
    } catch (Exception e) {
      throw new AuraHandledException(
        'Error fetching students: ' + e.getMessage()
      );
    }
  }
}
