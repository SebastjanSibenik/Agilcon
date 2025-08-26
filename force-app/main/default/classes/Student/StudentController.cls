public with sharing class StudentController {

    // Save student to Salesforce DB
    @AuraEnabled
    public static void createStudent(
        String name,
        String surname,
        String emso,
        String studyType,
        Boolean payer
    ) {
        try {
            // Validate EMSO numeric conversion
            Decimal emsoDecimal;
            try {
                emsoDecimal = Decimal.valueOf(emso);
            } catch (Exception e) {
                throw new AuraHandledException('EMSO must be numeric.');
            }

            Student__c s = new Student__c();
            s.Name = name;
            s.Surname__c = surname;
            s.EMSO__c = emsoDecimal;
            s.Study_Type__c = studyType;
            s.Payer__c = payer;

            insert s;

        } catch (DmlException e) {
            throw new AuraHandledException('Error saving student: ' + e.getMessage());
        }
    }

    // Validate EMSO - API method
    @AuraEnabled(cacheable=true)
    public static String validateEmso(String emso) {
        if (String.isBlank(emso)) {
            throw new AuraHandledException('EMSO cannot be empty.');
        }

        String encodedEmso = EncodingUtil.urlEncode(emso, 'UTF-8');
        String endpoint = 'https://app.agilcon.com/job/emso.php?emso=' + encodedEmso;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        HttpResponse response = new Http().send(request);
        if (response.getStatusCode() == 200) {
            return response.getBody();
        } else {
            throw new AuraHandledException(
                'EMSO validation failed. HTTP ' + response.getStatusCode() + ': ' + response.getBody()
            );
        }
    }
}
