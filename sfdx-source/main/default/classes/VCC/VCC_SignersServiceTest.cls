@isTest
public with sharing class VCC_SignersServiceTest {
    @TestVisible
    private static VATEST_MockedMethod getMockedMethodGetSignerDuzListForCallout() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature('getSignerDuzListForCallout', new List<System.Type>{ Id.class })
        );
    }

    @TestVisible
    private static VATEST_Stub stubSignersService(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub signersServiceStub = new VATEST_Stub(VCC_SignersService.class, mockedMethods);
        VCC_SignersService.privateInstance = (VCC_SignersService) signersServiceStub.createStub();
        return signersServiceStub;
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub signersServiceStub = VCC_SignersService.stub();
        System.assert(signersServiceStub.instance === VCC_SignersService.instance, 'Expected strict equality.');
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestStubbedAddendum() {
        Case testCase = new Case(
            RecordTypeId = Case.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
            VCC_Case__c = testCase.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage_Note_Progress_Note')
                .getRecordTypeId()
        );
        insert testProgressNote;
        VCC_Addendum__c addendum = new VCC_Addendum__c(
            VCC_Related_Note__c = testProgressNote.Id,
            VCC_Addendum__c = 'Hello World'
        );
        insert addendum;

        VCC_Stub signersSelectorStub = new VCC_Stub(VCC_SignersSelector.class);
        VCC_SignersSelector signersSelector = (VCC_SignersSelector) signersSelectorStub.instance;
        signersSelectorStub.setReturnValue(
            'selectSignersByAddendumId',
            new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_DUZ__c = 'test') }
        );

        Test.startTest();
        System.assert(
            VCC_SignersService.instance.getSignersForRecord(addendum.Id, signersSelector)[0].VCC_DUZ__c == 'test',
            'Expected duz to match stubbed value'
        );
        signersSelectorStub.assertInvoked('selectSignersByAddendumId');
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestStubbedPn() {
        Case testCase = new Case(
            RecordTypeId = Case.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
            VCC_Case__c = testCase.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage_Note_Progress_Note')
                .getRecordTypeId()
        );
        insert testProgressNote;

        VCC_Stub signersSelectorStub = new VCC_Stub(VCC_SignersSelector.class);
        VCC_SignersSelector signersSelector = (VCC_SignersSelector) signersSelectorStub.instance;
        signersSelectorStub.setReturnValue(
            'selectSignersByProgressNoteId',
            new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_DUZ__c = 'test') }
        );

        Test.startTest();
        System.assert(
            VCC_SignersService.instance.getSignersForRecord(testProgressNote.Id, signersSelector)[0].VCC_DUZ__c ==
            'test',
            'Expected duz to match stubbed value'
        );
        signersSelectorStub.assertInvoked('selectSignersByProgressNoteId');
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestStubbedOther() {
        Case testCase = new Case(
            RecordTypeId = Case.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;

        VCC_Stub signersSelectorStub = new VCC_Stub(VCC_SignersSelector.class);
        VCC_SignersSelector signersSelector = (VCC_SignersSelector) signersSelectorStub.instance;

        Test.startTest();
        List<VCC_Signers__c> resultingSignersList = VCC_SignersService.instance.getSignersForRecord(
            testCase.Id,
            signersSelector
        );
        Assert.isNotNull(resultingSignersList, 'Expected non-null result from getSignersForRecord');
        Assert.isTrue(resultingSignersList.isEmpty(), 'Expected empty list from getSignersForRecord');
        signersSelectorStub.assertNotInvoked('selectSignersByProgressNoteId');
        signersSelectorStub.assertNotInvoked('selectSignersByAddendumId');
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestStubbedNull() {
        VCC_Stub signersSelectorStub = new VCC_Stub(VCC_SignersSelector.class);
        VCC_SignersSelector signersSelector = (VCC_SignersSelector) signersSelectorStub.instance;

        Test.startTest();
        List<VCC_Signers__c> resultingSignersList = VCC_SignersService.instance.getSignersForRecord(
            null,
            signersSelector
        );
        Assert.isNotNull(resultingSignersList, 'Expected resulting signers list to be non-null');
        Assert.isTrue(resultingSignersList.isEmpty(), 'Expected resulting signers list to be empty');
        signersSelectorStub.assertNotInvoked('selectSignersByProgressNoteId');
        signersSelectorStub.assertNotInvoked('selectSignersByAddendumId');
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestAddendum() {
        Case testCase = new Case(
            RecordTypeId = Case.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
            VCC_Case__c = testCase.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage_Note_Progress_Note')
                .getRecordTypeId()
        );
        insert testProgressNote;
        VCC_Addendum__c addendum = new VCC_Addendum__c(
            VCC_Related_Note__c = testProgressNote.Id,
            VCC_Addendum__c = 'Hello World'
        );
        insert addendum;
        insert new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_Addendum__c = addendum.Id) };

        Test.startTest();
        System.assert(VCC_SignersService.instance.getSignersForRecord(addendum.Id).size() == 1, 'Expected one signers');
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestProgressNote() {
        Case testCase = new Case(
            RecordTypeId = Case.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
            VCC_Case__c = testCase.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage_Note_Progress_Note')
                .getRecordTypeId()
        );
        insert testProgressNote;
        insert new List<VCC_Signers__c>{ new VCC_Signers__c(VCC_Progress_Note__c = testProgressNote.Id) };

        Test.startTest();
        Assert.isTrue(
            VCC_SignersService.instance.getSignersForRecord(testProgressNote.Id).size() == 1,
            'Expected one signers'
        );
        Test.stopTest();
    }

    @IsTest
    static void getSignersForRecordTestNull() {
        Test.startTest();
        System.assert(VCC_SignersService.instance.getSignersForRecord(null).size() == 0, 'Expected no signers');
        Test.stopTest();
    }

    @IsTest
    static void getSignerDuzListForCalloutTest() {
        Case testCase = new Case(
            RecordTypeId = Case.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage')
                .getRecordTypeId()
        );
        insert testCase;
        VCC_Progress_Note__c testProgressNote = new VCC_Progress_Note__c(
            VCC_Case__c = testCase.Id,
            RecordTypeId = VCC_Progress_Note__c.getSObjectType()
                .getDescribe()
                .getRecordTypeInfosByDeveloperName()
                .get('VCC_Clinical_Triage_Note_Progress_Note')
                .getRecordTypeId()
        );
        insert testProgressNote;
        insert new List<VCC_Signers__c>{
            new VCC_Signers__c(VCC_Progress_Note__c = testProgressNote.Id, VCC_DUZ__c = '123')
        };

        Test.startTest();
        System.assert(
            VCC_SignersService.instance.getSignerDuzListForCallout(testProgressNote.Id) == new List<String>{ '123' },
            'Expected to find a list with one value matching that of test VCC_Signers__c record'
        );
        Test.stopTest();
    }
}
