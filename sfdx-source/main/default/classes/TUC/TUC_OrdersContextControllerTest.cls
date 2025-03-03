/**
 * @description Tests for controller that will get the context of the Orders component and query for the patient ID
 * based on which component record page it is starting from.
 */
@IsTest
@SuppressWarnings('PMD.UnusedLocalVariable, PMD.CRUDMustBeInRepo')
private class TUC_OrdersContextControllerTest {
    //static final String TEST_ICN = '1012853802V084487';

    @TestSetup
    static void setupUser() {
        VATEST_UserFactory.create(VATEST_UserPersonaEnum.TeleECOrdersUser, true);
    }

    @IsTest
    static void unitTestFetchICNFromPageParamsWithAccountPositive() {
        //Update this line to use the recordTypes constants when available...
        //Id personAccountRecordType = new VCR_AccountRepo().PersonAccountRecordType;
        Id personAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = personAccountRecordType, VCC_MVI_External_Id__pc = 'asdf')
        );
        // testAccount has a bogus id, and cannot be inserted.

        VCR_AccountRepo stubAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testAccount.Id, new Set<String>{ 'VCC_MVI_External_Id__pc' })
            .returning(testAccount)
            .defineStub();

        VCC_LWCSObjectRepos.memoizedAccountRepo = stubAccountRepo;

        // create the instance of TUC_OrdersContextController
        PageReference pageRef = Page.CCOWConn;
        pageRef.getParameters().put('Id', testAccount.Id);
        Test.setCurrentPage(pageRef);

        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            TUC_OrdersContextController unitUnderTest = new TUC_OrdersContextController();
            Test.stopTest();

            Assert.isNotNull(
                unitUnderTest.icn,
                'Expected the fetchICN method to fetch the ICN from the account record'
            );
            Assert.areEqual(
                testAccount.VCC_MVI_External_Id__pc,
                unitUnderTest.icn,
                'expected the found ICN to match the input account'
            );
        }
    }

    @IsTest
    @SuppressWarnings(
        'PMD.UnusedLocalVariable'
    ) // we don't care about this because just creating to instantiate the controller...
    static void unitTestsFetchICNFromPageParamsWithAccountNegative() {
        Id personAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = personAccountRecordType, VCC_MVI_External_Id__pc = 'asdf')
        );

        AuraHandledException myException = new AuraHandledException('Error Fetching Account');
        myException.setMessage('Error Fetching Account');
        VCR_AccountRepo stubAccountRepo = (VCR_AccountRepo) new VATEST_StubBuilder(VCR_AccountRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testAccount.Id, new Set<String>{ 'VCC_MVI_External_Id__pc' })
            .throwingException(myException) // the error is that you're calling throwing -
            .defineStub();

        PageReference pageRef = Page.CCOWConn;
        pageRef.getParameters().put('Id', testAccount.Id);
        Test.setCurrentPage(pageRef);

        VCC_LWCSObjectRepos.memoizedAccountRepo = stubAccountRepo; // dependency injected a fake implementation of the account repo.
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Boolean didCatchProperException = false;
            try {
                new TUC_OrdersContextController();
            } catch (AuraHandledException ahe) {
                if (ahe.getMessage().containsIgnoreCase('Error Fetching Account')) {
                    didCatchProperException = true;
                }
            }
            Test.stopTest();
            Assert.isTrue(didCatchProperException, 'Expected to have caught an Aura Handled Exception, but did not');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void unitTestsFetchICNFromPageParamsWithCasePositive() {
        Id personAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = personAccountRecordType, VCC_MVI_External_Id__pc = 'asdf')
        );
        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(
            new Contact(Account = testAccount, VCC_MVI_External_Id__c = 'asdf')
        );
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(Account = testAccount, Contact = testContact)
        );

        VCR_CaseRepo stubCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'Contact.VCC_MVI_External_Id__c' })
            .returning(testCase)
            .defineStub();

        // create the instance of TUC_OrdersContextController
        PageReference pageRef = Page.CCOWConn;
        pageRef.getParameters().put('Id', testCase.Id);
        Test.setCurrentPage(pageRef);

        VCC_LWCSObjectRepos.memoizedCaseRepo = stubCaseRepo; // dependency injected a fake implementation of the account repo.

        //Initiate controller in start/stop
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            TUC_OrdersContextController unitUnderTest = new TUC_OrdersContextController();
            Test.stopTest();

            Assert.isNotNull(unitUnderTest.icn, 'Expected the fetchICN method to fetch the ICN from the case record');
            Assert.areEqual(
                testCase.Account.VCC_MVI_External_Id__pc,
                unitUnderTest.icn,
                'expected the found ICN to match the input account'
            );
        }
    }

    @IsTest
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void unitTestsFetchICNFromPageParamsWithCaseNegative() {
        Id personAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = personAccountRecordType, VCC_MVI_External_Id__pc = 'asdf')
        );

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(new Case(Account = testAccount));

        AuraHandledException myException = new AuraHandledException('Error Fetching Case');
        myException.setMessage('Error Fetching Case');
        VCR_CaseRepo stubCaseRepo = (VCR_CaseRepo) new VATEST_StubBuilder(VCR_CaseRepo.class)
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testCase.Id, new Set<String>{ 'Contact.VCC_MVI_External_Id__c' })
            .throwingException(myException)
            .defineStub();

        // create the instance of TUC_OrdersContextController
        PageReference pageRef = Page.CCOWConn;
        pageRef.getParameters().put('Id', testCase.Id);
        Test.setCurrentPage(pageRef);

        VCC_LWCSObjectRepos.memoizedCaseRepo = stubCaseRepo; // dependency injected a fake implementation of the account repo.
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Boolean didCatchProperException = false;
            try {
                new TUC_OrdersContextController();
            } catch (AuraHandledException ahe) {
                if (ahe.getMessage().containsIgnoreCase('Error Fetching Case')) {
                    didCatchProperException = true;
                }
            }
            Test.stopTest();
            Assert.isTrue(didCatchProperException, 'Expected to have caught an Aura Handled Exception, but did not');
        }
    }

    @IsTest
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void unitTestsFetchICNFromPageParamsWithProgressNotePositive() {
        //Update this line to use the recordTypes constants when available...
        //Id personAccountRecordType = new VCR_AccountRepo().PersonAccountRecordType;
        Id personAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = personAccountRecordType, VCC_MVI_External_Id__pc = 'asdf')
        );
        Contact testContact = (Contact) VATEST_SObjectFactory.createSObject(
            new Contact(Account = testAccount, VCC_MVI_External_Id__c = 'asdf')
        );
        Case testCase = (Case) VATEST_SObjectFactory.createSObject(
            new Case(Account = testAccount, Contact = testContact)
        );
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(VCC_Case__r = testCase)
        );

        VCR_ProgressNoteRepo stubProgressNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                VCR_ProgressNoteRepo.class
            )
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testProgressNote.Id, new Set<String>{ 'VCC_Case__r.Contact.VCC_MVI_External_Id__c' })
            .returning(testProgressNote)
            .defineStub();

        PageReference pageRef = Page.CCOWConn;
        pageRef.getParameters().put('Id', testProgressNote.Id);
        Test.setCurrentPage(pageRef);

        //Create instance of controller in start/stop
        VCC_LWCSObjectRepos.memoizedProgressNoteRepo = stubProgressNoteRepo; // dependency injected a fake implementation of the account repo.
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            TUC_OrdersContextController unitUnderTest = new TUC_OrdersContextController();
            Test.stopTest();

            Assert.isNotNull(
                unitUnderTest.icn,
                'Expected the fetchICN method to fetch the ICN from the account record'
            );
            Assert.areEqual(
                testProgressNote.VCC_Case__r.Account.VCC_MVI_External_Id__pc,
                unitUnderTest.icn,
                'expected the found ICN to match the input account'
            );
        }
    }

    @IsTest
    @SuppressWarnings('PMD.UnusedLocalVariable')
    static void unitTestsFetchICNFromPageParamsWithProgressNoteNegative() {
        Id personAccountRecordType = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
        Account testAccount = (Account) VATEST_SObjectFactory.createSObject(
            new Account(RecordTypeId = personAccountRecordType, VCC_MVI_External_Id__pc = 'asdf')
        );

        Case testCase = (Case) VATEST_SObjectFactory.createSObject(new Case(Account = testAccount));
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(VCC_Case__c = testCase.Id)
        );

        AuraHandledException myException = new AuraHandledException('Error Fetching ProgressNote');
        myException.setMessage('Error Fetching ProgressNote');
        VCR_ProgressNoteRepo stubProgressNoteRepo = (VCR_ProgressNoteRepo) new VATEST_StubBuilder(
                VCR_ProgressNoteRepo.class
            )
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(testProgressNote.Id, new Set<String>{ 'VCC_Case__r.Contact.VCC_MVI_External_Id__c' })
            .throwingException(myException)
            .defineStub();

        // create the instance of TUC_OrdersContextController
        PageReference pageRef = Page.CCOWConn;
        pageRef.getParameters().put('Id', testProgressNote.Id);
        Test.setCurrentPage(pageRef);

        VCC_LWCSObjectRepos.memoizedProgressNoteRepo = stubProgressNoteRepo; // dependency injected a fake implementation of the account repo.

        //Create instance of controller in start/stop
        User testUser = [SELECT Id FROM User LIMIT 1];
        System.runAs(testUser) {
            Test.startTest();
            Boolean didCatchProperException = false;
            try {
                new TUC_OrdersContextController();
            } catch (AuraHandledException ahe) {
                if (ahe.getMessage().containsIgnoreCase('Error Fetching ProgressNote')) {
                    didCatchProperException = true;
                }
            }
            Test.stopTest();
            Assert.isTrue(didCatchProperException, 'Expected to have caught an Aura Handled Exception, but did not');
        }
    }
}
