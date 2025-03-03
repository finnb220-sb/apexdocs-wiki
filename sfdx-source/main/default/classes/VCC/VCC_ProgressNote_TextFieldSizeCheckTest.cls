@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
private with sharing class VCC_ProgressNote_TextFieldSizeCheckTest {
    /**
     * @description Get mocked method for VCC_ProgressNoteDomain.charLimitError
     * @return `VATEST_MockedMethod` for VCC_ProgressNoteDomain.charLimitError
     */
    private static VATEST_MockedMethod getCharLimitErrorMockedMethod() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'charLimitError',
                new List<System.Type>{ List<VCC_Progress_Note__c>.class, Map<Id, SObject>.class }
            )
        );
    }

    @IsTest
    static void unitBeforeUpdateNullArgsNegative() {
        // stub setup
        VATEST_MockedMethod charLimitMockedMethod = getCharLimitErrorMockedMethod()
            .withParameterValues(new List<Object>{})
            .returning((Object) null);
        VATEST_Stub progressNoteDomainStub = new VATEST_Stub(
            VCC_ProgressNoteDomain.class,
            new List<VATEST_MockedMethod>{ charLimitMockedMethod }
        );
        VCC_ProgressNote_TextFieldSizeCheck_BU textFieldSizeCheck = new VCC_ProgressNote_TextFieldSizeCheck_BU();
        textFieldSizeCheck.progressNoteDomain = (VCC_ProgressNoteDomain) progressNoteDomainStub.createStub();

        Test.startTest();
        textFieldSizeCheck.beforeUpdate(null, null);
        try {
            charLimitMockedMethod.assertMockedMethodWasCalled();
            Assert.fail('Expected an exception, stubbed method should not have been called');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VATEST_Stub.VATEST_StubException.class,
                'Expected VATEST_StubException because the stubbed method was not called'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitBeforeUpdateEmptyListArgsNegative() {
        // stub setup
        VATEST_MockedMethod charLimitMockedMethod = getCharLimitErrorMockedMethod()
            .withParameterValues(new List<Object>{})
            .returning((Object) null);
        VATEST_Stub progressNoteDomainStub = new VATEST_Stub(
            VCC_ProgressNoteDomain.class,
            new List<VATEST_MockedMethod>{ charLimitMockedMethod }
        );
        VCC_ProgressNote_TextFieldSizeCheck_BU textFieldSizeCheck = new VCC_ProgressNote_TextFieldSizeCheck_BU();
        textFieldSizeCheck.progressNoteDomain = (VCC_ProgressNoteDomain) progressNoteDomainStub.createStub();

        Test.startTest();
        textFieldSizeCheck.beforeUpdate(new List<VCC_Progress_Note__c>(), new List<VCC_Progress_Note__c>());
        try {
            charLimitMockedMethod.assertMockedMethodWasCalled();
            Assert.fail('Expected an exception, stubbed method should not have been called');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VATEST_Stub.VATEST_StubException.class,
                'Expected VATEST_StubException because the stubbed method was not called'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitBeforeUpdatePositive() {
        // newList/oldList setup
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c newProgressNote = oldProgressNote.clone(true, true, true, true);
        List<VCC_Progress_Note__c> oldList = new List<VCC_Progress_Note__c>{ oldProgressNote };
        List<VCC_Progress_Note__c> newList = new List<VCC_Progress_Note__c>{ newProgressNote };

        // stub setup
        VATEST_MockedMethod charLimitMockedMethod = getCharLimitErrorMockedMethod()
            .withParameterValues(new List<Object>{ newList, new Map<Id, SObject>(oldList) })
            .returning((Object) null);
        VATEST_Stub progressNoteDomainStub = new VATEST_Stub(
            VCC_ProgressNoteDomain.class,
            new List<VATEST_MockedMethod>{ charLimitMockedMethod }
        );
        VCC_ProgressNote_TextFieldSizeCheck_BU textFieldSizeCheck = new VCC_ProgressNote_TextFieldSizeCheck_BU();
        textFieldSizeCheck.progressNoteDomain = (VCC_ProgressNoteDomain) progressNoteDomainStub.createStub();

        Test.startTest();
        try {
            textFieldSizeCheck.beforeUpdate(
                new List<VCC_Progress_Note__c>{ newProgressNote },
                new List<VCC_Progress_Note__c>{ oldProgressNote }
            );
            charLimitMockedMethod.assertMockedMethodWasCalled();
        } catch (Exception thrownException) {
            Assert.fail('Expected no exception, but ' + thrownException.getTypeName() + ' was thrown');
        }
        Test.stopTest();
    }

    @IsTest
    static void funcBeforeUpdateMaxLengthPositive() {
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
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            VCR_ProgressNoteRepo progressNoteRepository = new VCR_ProgressNoteRepo();
            progressNoteRepository.doCreate(clinicalTriageProgressNote);
            Test.startTest();
            try {
                progressNoteRepository.doUpdate(
                    new VCC_Progress_Note__c(
                        VCC_Caller_Name_Text__c = ''
                            .leftpad(VCC_Progress_Note__c.VCC_Caller_Name_Text__c.getDescribe().getLength(), 'x'),
                        Id = clinicalTriageProgressNote.Id
                    )
                );
                Assert.fail(
                    'Expected an exception upon update of progress note because it has reached its maximum length'
                );
            } catch (Exception thrownException) {
                Assert.areEqual(
                    'VCC_Caller_Name_Text__c',
                    thrownException.getDmlFieldNames(0)[0],
                    'Expected VCC_Caller_Name_Text__c to the the field at issue in the exception.'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void funcBeforeUpdateMaxLengthMinusOneNegative() {
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
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            VCR_ProgressNoteRepo progressNoteRepository = new VCR_ProgressNoteRepo();
            progressNoteRepository.doCreate(clinicalTriageProgressNote);
            Test.startTest();
            try {
                progressNoteRepository.doUpdate(
                    new VCC_Progress_Note__c(
                        VCC_Caller_Name_Text__c = ''
                            .leftpad(VCC_Progress_Note__c.VCC_Caller_Name_Text__c.getDescribe().getLength() - 1, 'x'),
                        Id = clinicalTriageProgressNote.Id
                    )
                );
            } catch (Exception thrownException) {
                Assert.fail(
                    'Expected progress note to update successfully. Instead received: ' + thrownException.getTypeName()
                );
            }
            Test.stopTest();
        }
    }
}
