@IsTest
public with sharing class VCC_ProgressNote_PreventSignedDeleteTest {
    @IsTest
    static void unitPreventProgressNoteDeleteNullArgNegative() {
        Test.startTest();
        try {
            (new VCC_ProgressNote_PreventSignedDelete_BD()).beforeDelete(null);
        } catch (Exception thrownException) {
            Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitPreventProgressNoteDeleteEmptyListNegative() {
        Test.startTest();
        try {
            (new VCC_ProgressNote_PreventSignedDelete_BD()).beforeDelete(new List<VCC_Progress_Note__c>());
        } catch (Exception thrownException) {
            Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitPreventProgressNoteDeleteSignedPositive() {
        List<VCC_Progress_Note__c> progressNoteList = new List<VCC_Progress_Note__c>{
            new VCC_Progress_Note__c(VCC_Signed__c = true)
        };
        Test.startTest();
        try {
            (new VCC_ProgressNote_PreventSignedDelete_BD()).beforeDelete(progressNoteList);
            List<Database.Error> triggerErrors = progressNoteList[0].getErrors();
            Assert.areEqual(1, triggerErrors.size(), 'Expected one Database.Error');
            Assert.areEqual(
                VCC_ProgressNote_PreventSignedDelete_BD.PREVENT_DELETE_ERROR_MESSAGE,
                triggerErrors[0].getMessage(),
                'Expected error stored in static property PREVENT_DELETE_ERROR_MESSAGE'
            );
        } catch (Exception thrownException) {
            Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void unitPreventProgressNoteDeleteUnsignedPositive() {
        List<VCC_Progress_Note__c> progressNoteList = new List<VCC_Progress_Note__c>{
            new VCC_Progress_Note__c(VCC_Signed__c = false)
        };
        Test.startTest();
        try {
            (new VCC_ProgressNote_PreventSignedDelete_BD()).beforeDelete(progressNoteList);
            List<Database.Error> triggerErrors = progressNoteList[0].getErrors();
            Assert.areEqual(0, triggerErrors.size(), 'Expected no Database.Error\'s');
        } catch (Exception thrownException) {
            Assert.fail('Expected no exception, instead found ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void funcBeforeDeleteSignedPositive() {
        System.runAs((new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VAHC_RN_User')
            .build(true)) {
            Account testAccount = new Account(
                LastName = 'Test',
                RecordTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PersonAccount')
                    .getRecordTypeId()
            );
            (new VCR_AccountRepo()).doCreate(testAccount);
            Case clinicalTriageCase = new Case(
                AccountId = testAccount.Id,
                RecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage')
                    .getRecordTypeId()
            );
            (new VCR_CaseRepo()).doCreate(clinicalTriageCase);
            VCC_Progress_Note__c clinicalTriageProgressNote = new VCC_Progress_Note__c(
                VCC_Case__c = clinicalTriageCase.Id,
                VCC_Signed__c = true,
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            VCR_ProgressNoteRepo progressNoteRepo = new VCR_ProgressNoteRepo();
            progressNoteRepo.doCreate(clinicalTriageProgressNote);
            Test.startTest();
            try {
                progressNoteRepo.doDelete(new VCC_Progress_Note__c(Id = clinicalTriageProgressNote.Id));
                Assert.fail('Expected an exception to be thrown, preventing delete of the progress note');
            } catch (Exception thrownException) {
                Assert.areEqual(
                    VCC_ProgressNote_PreventSignedDelete_BD.PREVENT_DELETE_ERROR_MESSAGE,
                    thrownException.getDmlMessage(0),
                    'Expected to find the correct error message stored in VCC_ProgressNote_PreventSignedDelete_BD.PREVENT_DELETE_ERROR_MESSAGE'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void funcBeforeDeleteUnsignedNegative() {
        System.runAs((new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VAHC_RN_User')
            .build(true)) {
            Account testAccount = new Account(
                LastName = 'Test',
                RecordTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('PersonAccount')
                    .getRecordTypeId()
            );
            (new VCR_AccountRepo()).doCreate(testAccount);
            Case clinicalTriageCase = new Case(
                AccountId = testAccount.Id,
                RecordTypeId = Case.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage')
                    .getRecordTypeId()
            );
            (new VCR_CaseRepo()).doCreate(clinicalTriageCase);
            VCC_Progress_Note__c clinicalTriageProgressNote = new VCC_Progress_Note__c(
                VCC_Case__c = clinicalTriageCase.Id,
                VCC_Signed__c = false,
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            VCR_ProgressNoteRepo progressNoteRepo = new VCR_ProgressNoteRepo();
            progressNoteRepo.doCreate(clinicalTriageProgressNote);
            Test.startTest();
            try {
                progressNoteRepo.doDelete(new VCC_Progress_Note__c(Id = clinicalTriageProgressNote.Id));
            } catch (Exception thrownException) {
                Assert.fail('Expected the progress note to be deleted');
            }
            Test.stopTest();
        }
    }
}
