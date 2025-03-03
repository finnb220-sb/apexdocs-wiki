@IsTest
private with sharing class VCC_ProgressNote_UserLocalTriageDateTest {
    private static final String UNEXPECTED_EXCEPTION_FAIL_TEMPLATE = 'Expected no exception but found:\n{0}: {1}\n{2}';

    /**
     * @description Given an exception, this method Assert.fail's with a nicely formatted message including exception details.
     * @param thrownException
     */
    static void failUnexpectedException(Exception thrownException) {
        Assert.fail(
            String.format(
                UNEXPECTED_EXCEPTION_FAIL_TEMPLATE,
                new List<String>{
                    thrownException.getTypeName(),
                    thrownException.getMessage(),
                    thrownException.getStackTraceString()
                }
            )
        );
    }

    @IsTest
    static void unitBeforeUpdateFirstArgNullNegative() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c oldProgressNoteClone = oldProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .beforeUpdate(null, new List<VCC_Progress_Note__c>{ oldProgressNote });
            Assert.isTrue(oldProgressNote == oldProgressNoteClone, 'Expected no change to the SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitBeforeUpdateFirstArgEmptyNegative() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c oldProgressNoteClone = oldProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .beforeUpdate(new List<VCC_Progress_Note__c>(), new List<VCC_Progress_Note__c>{ oldProgressNote });
            Assert.isTrue(oldProgressNote == oldProgressNoteClone, 'Expected no change to the SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitBeforeUpdateSecondArgNullNegative() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c newProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .beforeUpdate(new List<VCC_Progress_Note__c>{ newProgressNote }, null);
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected no change to the SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitBeforeUpdateSecondArgEmptyNegative() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c newProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .beforeUpdate(new List<VCC_Progress_Note__c>{ newProgressNote }, new List<VCC_Progress_Note__c>());
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected no change to the SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitBeforeUpdatePositive() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c newProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(Id = dummyProgressNoteId);
        VCC_Progress_Note__c oldProgressNoteClone = oldProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .beforeUpdate(
                    new List<VCC_Progress_Note__c>{ newProgressNote },
                    new List<VCC_Progress_Note__c>{ oldProgressNote }
                );
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected no change to the SObject');
            Assert.isTrue(oldProgressNote == oldProgressNoteClone, 'Expected no change to the SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedSingleWithTriageDatePositive() {
        Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = null,
            VCC_Triage_Date_User_Timezone_Adjusted__c = null
        );
        VCC_Progress_Note__c newProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = dummyTriageDate,
            VCC_Triage_Date_User_Timezone_Adjusted__c = null
        );
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.isTrue(newProgressNote != newProgressNoteClone, 'Expected SObject to have been changed');
            Assert.areEqual(
                dummyTriageDate.format(
                    VCC_ProgressNote_UserLocalTriageDate_BU.TRIAGE_DATE_FORMAT_STRING,
                    UserInfo.getTimeZone().toString()
                ),
                newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                'Expected to find Datetime formatted and in the running users timezone'
            );
            newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c = null;
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected only one field to have been modified');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedSingleWithoutTriageDatePositive() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = null,
            VCC_Triage_Date_User_Timezone_Adjusted__c = null
        );
        VCC_Progress_Note__c newProgressNote = oldProgressNote.clone(true, true, true, true);
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected no change to the SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedSingleRemovingTriageDatePositive() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = dummyTriageDate,
            VCC_Triage_Date_User_Timezone_Adjusted__c = 'test'
        );
        VCC_Progress_Note__c newProgressNote = oldProgressNote.clone(true, true, true, true);
        newProgressNote.VCC_Triage_Date__c = null;
        Test.startTest();
        try {
            Assert.isNotNull(
                newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                'Expected initial field value to be non-null for test conditions.'
            );
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.isNull(
                newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                'Expected field value to be cleared.'
            );
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedSingleChangingTriageDatePositive() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = dummyTriageDate,
            VCC_Triage_Date_User_Timezone_Adjusted__c = 'test'
        );
        VCC_Progress_Note__c newProgressNote = oldProgressNote.clone(true, true, true, true);
        newProgressNote.VCC_Triage_Date__c = newProgressNote.VCC_Triage_Date__c.addDays(1);
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            Assert.areEqual(
                'test',
                newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                'Expected initial value to be \'test\''
            );
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.areNotEqual(
                'test',
                newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                'Expected value to have changed from \'test\''
            );
            Assert.areEqual(
                dummyTriageDate.addDays(1)
                    .format(
                        VCC_ProgressNote_UserLocalTriageDate_BU.TRIAGE_DATE_FORMAT_STRING,
                        UserInfo.getTimeZone().toString()
                    ),
                newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                'Expected to find Datetime formatted and in the running users timezone.'
            );
            newProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c = oldProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c;
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected only one field change on SObject');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedSingleNoChangePositive() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = dummyTriageDate,
            VCC_Triage_Date_User_Timezone_Adjusted__c = 'test'
        );
        VCC_Progress_Note__c newProgressNote = oldProgressNote.clone(true, true, true, true);
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected no change to SObject.');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedNullNewProgressNoteNegative() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
        VCC_Progress_Note__c oldProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = dummyTriageDate,
            VCC_Triage_Date_User_Timezone_Adjusted__c = 'test'
        );
        VCC_Progress_Note__c oldProgressNoteClone = oldProgressNote.clone(true, true, true, true);
        VCC_Progress_Note__c newProgressNote = null;
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.isTrue(oldProgressNote == oldProgressNoteClone, 'Expected no change to SObject.');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSetTriageDateUserTimezoneAdjustedNullOldProgressNoteNegative() {
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
        VCC_Progress_Note__c oldProgressNote = null;
        VCC_Progress_Note__c newProgressNote = new VCC_Progress_Note__c(
            Id = dummyProgressNoteId,
            VCC_Triage_Date__c = dummyTriageDate,
            VCC_Triage_Date_User_Timezone_Adjusted__c = 'test'
        );
        VCC_Progress_Note__c newProgressNoteClone = newProgressNote.clone(true, true, true, true);
        Test.startTest();
        try {
            (new VCC_ProgressNote_UserLocalTriageDate_BU())
                .setTriageDateUserTimezoneAdjusted(newProgressNote, oldProgressNote);
            Assert.isTrue(newProgressNote == newProgressNoteClone, 'Expected no change to SObject.');
        } catch (Exception thrownException) {
            failUnexpectedException(thrownException);
        }
        Test.stopTest();
    }

    @IsTest
    static void funcBeforeUpdateUserTriageDateSetValuePositive() {
        System.runAs((new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VAHC_Read_Progress_Notes')
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
            VCR_ProgressNoteRepo progressNoteRepo = new VCR_ProgressNoteRepo();
            progressNoteRepo.doCreate(clinicalTriageProgressNote);
            Datetime dummyTriageDate = Datetime.newInstance(2024, 3, 19, 9, 37, 0);
            Test.startTest();
            try {
                progressNoteRepo.doUpdate(
                    new VCC_Progress_Note__c(Id = clinicalTriageProgressNote.Id, VCC_Triage_Date__c = dummyTriageDate)
                );
                VCC_Progress_Note__c updatedProgressNote = (VCC_Progress_Note__c) progressNoteRepo.fetchById(
                    clinicalTriageProgressNote.Id,
                    new Set<String>(new List<String>{ 'VCC_Triage_Date_User_Timezone_Adjusted__c' })
                );
                Assert.isNotNull(
                    updatedProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                    'Expected non-null value'
                );
                Assert.areEqual(
                    dummyTriageDate.format(
                        VCC_ProgressNote_UserLocalTriageDate_BU.TRIAGE_DATE_FORMAT_STRING,
                        UserInfo.getTimeZone().toString()
                    ),
                    updatedProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                    'Expected to find VCC_Triage_Date__c value to be formatted correctly into VCC_Triage_Date_User_Timezone_Adjusted__c'
                );
            } catch (Exception thrownException) {
                failUnexpectedException(thrownException);
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void funcBeforeUpdateUserTriageDateUpdateValuePositive() {
        System.runAs((new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VAHC_Read_Progress_Notes')
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
                VCC_Triage_Date__c = Datetime.newInstance(2024, 3, 19, 9, 37, 0),
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            );
            VCR_ProgressNoteRepo progressNoteRepo = new VCR_ProgressNoteRepo();
            progressNoteRepo.doCreate(clinicalTriageProgressNote);
            Test.startTest();
            try {
                progressNoteRepo.doUpdate(
                    new VCC_Progress_Note__c(
                        Id = clinicalTriageProgressNote.Id,
                        VCC_Triage_Date__c = clinicalTriageProgressNote.VCC_Triage_Date__c.addDays(1)
                    )
                );
                VCC_Progress_Note__c updatedProgressNote = (VCC_Progress_Note__c) progressNoteRepo.fetchById(
                    clinicalTriageProgressNote.Id,
                    new Set<String>(
                        new List<String>{ 'VCC_Triage_Date_User_Timezone_Adjusted__c', 'VCC_Triage_Date__c' }
                    )
                );
                Assert.isNotNull(
                    updatedProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                    'Expected non-null value'
                );
                Assert.areEqual(
                    updatedProgressNote.VCC_Triage_Date__c.format(
                        VCC_ProgressNote_UserLocalTriageDate_BU.TRIAGE_DATE_FORMAT_STRING,
                        UserInfo.getTimeZone().toString()
                    ),
                    updatedProgressNote.VCC_Triage_Date_User_Timezone_Adjusted__c,
                    'Expected vaulue in VCC_Triage_Date_User_Timezone_Adjusted__c to change with the updated value in VCC_Triage_Date__c'
                );
            } catch (Exception thrownException) {
                failUnexpectedException(thrownException);
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void funcBeforeUpdateUserTriageDateClearValuePositive() {
        System.runAs((new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VAHC_Read_Progress_Notes')
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
            VCR_ProgressNoteRepo progressNoteRepo = new VCR_ProgressNoteRepo();
            progressNoteRepo.doCreate(clinicalTriageProgressNote);
            progressNoteRepo.doUpdate(
                new VCC_Progress_Note__c(
                    Id = clinicalTriageProgressNote.Id,
                    VCC_Triage_Date__c = Datetime.newInstance(2024, 3, 19, 9, 37, 0)
                )
            );
            Test.startTest();
            try {
                Assert.isNotNull(
                    ((VCC_Progress_Note__c) progressNoteRepo.fetchById(
                            clinicalTriageProgressNote.Id,
                            new Set<String>(new List<String>{ 'VCC_Triage_Date_User_Timezone_Adjusted__c' })
                        ))
                        .VCC_Triage_Date_User_Timezone_Adjusted__c,
                    'Expected initial value to be non-null so this test can clear it'
                );
                progressNoteRepo.doUpdate(
                    new VCC_Progress_Note__c(Id = clinicalTriageProgressNote.Id, VCC_Triage_Date__c = null)
                );
                Assert.isNull(
                    ((VCC_Progress_Note__c) progressNoteRepo.fetchById(
                            clinicalTriageProgressNote.Id,
                            new Set<String>(new List<String>{ 'VCC_Triage_Date_User_Timezone_Adjusted__c' })
                        ))
                        .VCC_Triage_Date_User_Timezone_Adjusted__c,
                    'Expected value to have been cleared by the trigger'
                );
            } catch (Exception thrownException) {
                failUnexpectedException(thrownException);
            }
            Test.stopTest();
        }
    }
}
