@IsTest
public with sharing class VCC_TrainingModeTestDataFactory {
    public static Account createTrainingModeAccount(String firstName, String lastName) {
        return new Account(
            FirstName = firstName,
            LastName = lastName,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            Is_Training_Account__c = true
        );
    }

    public static Account createMasterTrainingModeAccount(String firstName, String lastName) {
        return new Account(
            FirstName = firstName,
            LastName = lastName,
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId(),
            Is_Training_Account__c = true
        );
    }

    public static VCC_Training_Mode_Data__c createTrainingModeData(String accountId, String name, String typ, String data) {
        return new VCC_Training_Mode_Data__c(Account__c = accountId, Name = name, Type__c = typ, Data__c = data);
    }
}
