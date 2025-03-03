@IsTest
public with sharing class VCC_DASServiceUtilitiesTest {
    @IsTest
    static void getRecordTypeApiNameAddendumTest() {
        VCC_Addendum__c addendum = new VCC_Addendum__c();
        Test.startTest();
        try {
            Assert.areEqual(
                'VCC_Addendum__c',
                VCC_DAS.SERVICES.UTILITIES.getRecordTypeApiName(addendum),
                'Unexpected value.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecordTypeApiNameProgressNoteTestHappy() {
        Case c = new Case();
        insert c;

        Map<String, RecordTypeInfo> recordTypeInfosByDeveloperName = VCC_Progress_Note__c.getSObjectType()
            .getDescribe()
            .getRecordTypeInfosByDeveloperName();
        String recordTypeName = new List<String>(recordTypeInfosByDeveloperName.keySet())[0];
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
            VCC_Case__c = c.Id,
            RecordTypeId = recordTypeInfosByDeveloperName.get(recordTypeName).getRecordTypeId()
        );
        insert progressNote;

        Test.startTest();
        try {
            Assert.areEqual(
                recordTypeName,
                VCC_DAS.SERVICES.UTILITIES.getRecordTypeApiName(progressNote),
                'Unexpected value.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecordTypeApiNameProgressNoteTestHappyNullRecordTypeId() {
        Case c = new Case();
        insert c;

        Map<String, RecordTypeInfo> recordTypeInfosByDeveloperName = VCC_Progress_Note__c.getSObjectType()
            .getDescribe()
            .getRecordTypeInfosByDeveloperName();
        String recordTypeName = new List<String>(recordTypeInfosByDeveloperName.keySet())[0];
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
            VCC_Case__c = c.Id,
            RecordTypeId = recordTypeInfosByDeveloperName.get(recordTypeName).getRecordTypeId()
        );
        insert progressNote;

        Test.startTest();
        try {
            Assert.areEqual(
                recordTypeName,
                VCC_DAS.SERVICES.UTILITIES.getRecordTypeApiName(new VCC_Progress_Note__c(Id = progressNote.Id)),
                'Unexpected value.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecordTypeApiNameProgressNoteTestSadNullAll() {
        Test.startTest();
        try {
            Assert.isNull(
                VCC_DAS.SERVICES.UTILITIES.getRecordTypeApiName(new VCC_Progress_Note__c()),
                'Expected null.'
            );
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getRecordTypeApiNameSadOtherSObject() {
        Case c = new Case();

        Test.startTest();
        try {
            Assert.isNull(VCC_DAS.SERVICES.UTILITIES.getRecordTypeApiName(c), 'Expected null.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage());
        }
        Test.stopTest();
    }

    @IsTest
    static void getProviderDuzTest() {
        Test.startTest();
        Assert.areEqual(
            'test',
            VCC_DAS.SERVICES.UTILITIES.getProviderDuz(null, null),
            'Expected dummy value of \'test\'.'
        );
        Test.stopTest();
    }

    @IsTest
    static void generateTransactionIdTestHappy() {
        Case c = new Case();
        insert c;

        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(VCC_Case__c = c.Id);
        insert progressNote;

        Test.startTest();
        try {
            String txId = VCC_DAS.SERVICES.UTILITIES.generateTransactionId(
                VCC_DAS.Endpoint.CREATE_ADDENDUM,
                progressNote.Id
            );
            Assert.isNotNull(txId, 'Expected non-null value.');
        } catch (Exception e) {
            Assert.fail('Unexpected exception: ' + e.getMessage() + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
