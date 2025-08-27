public with sharing class StudentController {
    /**
     * Creates a new Student record in Salesforce.
     * Validates input fields and checks for duplicate EMSO before inserting.
     *
     * @param firstname First name of the student
     * @param lastname Last name of the student
     * @param emso Unique EMSO identifier
     * @param studyType Type of study (e.g., Bachelor, Master)
     * @param isPayer Boolean indicating if student is a payer
     * @return Id of the newly created Student record
     * @throws AuraHandledException if validation or insert fails
     */
    @AuraEnabled
    public static void createStudent(
        String firstname,
        String lastname,
        String emso,
        String studyType,
        Boolean isPayer
    ) {
        try {
            validateStudentInsertion(firstname, lastname, emso, studyType);

            Student__c s = new Student__c(
                Name = firstname + ' ' + lastname,
                EMSO__c = emso,
                Study_Type__c = studyType,
                Is_Payer__c = isPayer
            );
            
            insert s;

        } catch (DmlException e) {
            throw new AuraHandledException('Napaka pri shranjevanju študenta: ' + e.getMessage());
        }
    }

    /**
     * Retrieves all students from Salesforce.
     * This method is cacheable for improved Lightning performance.
     *
     * @return List of Student__c records
     * @throws AuraHandledException if query fails
     */
    @AuraEnabled(cacheable=true)
    public static List<Student__c> getStudents() {
        try {
            return [
                SELECT Id, Name, EMSO__c, Study_Type__c, Is_Payer__c
                FROM Student__c
                ORDER BY Name
            ];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching students: ' + e.getMessage());
        }
    }

    /**
     * Retrieves a single student record by EMSO.
     * Returns null if no record is found.
     *
     * @param emso EMSO of the student
     * @return Student__c record or null
     * @throws AuraHandledException if query fails
     */
    @AuraEnabled(cacheable=true)
    public static Student__c getByEmso(String emso) {
        try {
            List<Student__c> students = [
                SELECT Id, Name, EMSO__c, Study_Type__c, Is_Payer__c
                FROM Student__c
                WHERE EMSO__c = :emso
                LIMIT 1
            ];
            return students.isEmpty() ? null : students[0];
        } catch (Exception e) {
            throw new AuraHandledException('Error fetching student: ' + e.getMessage());
        }
    }

    /**
     * Validates EMSO via an external API.
     *
     * @param emso EMSO to validate
     * @return String message from API response
     * @throws AuraHandledException if API returns error or validation fails
     */
    @AuraEnabled
    public static String validateEmsoViaApi(String emso) {
        String endpoint = 'https://app.agilcon.com/job/emso.php?emso=' +
            EncodingUtil.urlEncode(emso, 'UTF-8');

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('GET');
        request.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HttpResponse response = http.send(request);

        if (response.getStatusCode() != 200) {
            throw new AuraHandledException('Napaka pri preverjanju EMŠO. HTTP:' + response.getStatusCode());
        }

        Map<String, Object> r = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        if (!(Boolean) r.get('success')) {
            throw new AuraHandledException((String) r.get('message'));
        }

        return (String) r.get('message');
    }

    /**
     * Validates that the EMSO string is correctly formatted and the control digit is correct.
     *
     * @param emso EMSO to validate
     * @return String confirmation if EMSO is valid
     * @throws AuraHandledException if EMSO is invalid
     */
    @AuraEnabled
    public static String validateEmso(String emso) {
        if (String.isBlank(emso) || emso.length() != 13 || !Pattern.matches('\\d{13}', emso)) {
            throw new AuraHandledException('EMŠO mora vsebovati natakno 13 števk.');
        }

        Integer emsoSum = 0;
        for (Integer i = 7; i > 1; i--) {
            emsoSum += i * (
                Integer.valueOf(emso.substring(7 - i, 7 - i + 1)) +
                Integer.valueOf(emso.substring(13 - i, 13 - i + 1))
            );
        }

        Integer remainder = Math.mod(emsoSum, 11);
        Integer controlDigit = (remainder == 0) ? 0 : 11 - remainder;

        if (controlDigit == 10) {
            throw new AuraHandledException('Nepravilne kontrolne števke.');
        }

        Boolean valid = controlDigit == Integer.valueOf(emso.substring(12, 13));
        if (valid) {
            return 'EMšO ni pravilna! Prosim vnesite pravilno EMšO!';
        }
        throw new AuraHandledException('EMšO ni pravilna! Prosim vnesite pravilno EMšO.');
    }

    /**
     * Validates student input fields and checks if a student with the same EMSO already exists.
     * Throws an AuraHandledException if any validation fails.
     *
     * @param firstname First name of the student
     * @param lastname Last name of the student
     * @param emso EMSO of the student
     * @param studyType Type of study
     */
    @AuraEnabled
    public static void validateStudentInsertion(
        String firstname,
        String lastname,
        String emso,
        String studyType
    ) {
        if (String.isBlank(firstname) || String.isBlank(lastname) || 
            String.isBlank(emso) || String.isBlank(studyType)) {
            throw new AuraHandledException('Prosim vnesite vsa potrebna polja.');
        }

        validateEmso(emso);

        Student__c existing = getByEmso(emso);
        if (existing != null) {
            throw new AuraHandledException('Študent z podano EMŠO že obstaja. EMŠO: ' + emso);
        }
    }
}
