public with sharing class OwnerController {
    public OwnerController() {}

    @AuraEnabled(cacheable=true)
    public static List<Owner__c> getOwners() {
        return [SELECT Id, name, Surname__c, Email__c FROM Owner__c ORDER BY Name];
    }
}