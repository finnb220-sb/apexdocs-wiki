@IsTest
public with sharing class VCC_PatientLabServiceTest {
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    private static User createTestAdminUser() {
        // needed for mixed DML exception
        User testUser;
        System.runAs(new User(Id = UserInfo.getUserId())) {
            testUser = new VATEST_UserBuilder()
                .withStandardData()
                .withUserProfile('System Administrator')
                .withPermissionSets(new Set<String>(new List<String>{ 'VAHC_RN_User', 'VAHC_Read_Progress_Notes' }))
                .build(true);
        }
        return testUser;
    }

    @IsTest
    static void intgnUpdateRecentSudLabsFieldWithSudLabs() {
        //NOPMD

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_LabMockWithSUD');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        RecordType caseRecordType = VCC_TestDataFactory.getRecordType('Case', 'VCC_Pharmacy');
        Account account = VCC_TestDataFactory.generateVccPersonAccounts(1)[0];

        VCC_TestDataFactory.CallTaskWrapper callWrapper = new VCC_TestDataFactory.CallTaskWrapper();
        callWrapper.acct = account;
        callWrapper.callerName = 'Test';
        callWrapper.callerRelationType = 'Self';
        callWrapper.ownerId = UserInfo.getUserId();

        VCC_TestDataFactory.createCallTask(callWrapper);
        Case cse = VCC_TestDataFactory.createCase('VCC_PatientLabServiceTest', caseRecordType.Id, account.Id);
        VCC_Progress_Note__c progressNote = VCC_TestDataFactory.createProgressNote(cse.Id);
        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                VCC_PatientLabService.updateProgressNoteWithSUDInformation(progressNote.Id);
            } catch (DmlException dmlException) {
                for (Integer idx = 0; idx < dmlException.getNumDml(); idx++) {
                    Logger.debug(dmlException.getDmlMessage(idx) + ' ' + dmlException.getDmlFields(idx));
                }
            } catch (Exception exc) {
                System.Assert.fail('Unexpected exception ' + exc.getMessage() + '\n' + exc.getStackTraceString());
            }
            Test.stopTest();

            VCC_Progress_Note__c progressNoteAfterUpdate = [
                SELECT VCC_Recent_SUD_Labs__c
                FROM VCC_Progress_Note__c
                WHERE Id = :progressNote.Id
                LIMIT 1
            ];
            System.Assert.areNotEqual(
                VCC_PatientLabService.RECENT_SUD_LABS_NONE,
                progressNoteAfterUpdate.VCC_Recent_SUD_Labs__c,
                'Did not expect label for no results.'
            );
            System.Assert.areNotEqual(
                VCC_PatientLabService.RECENT_SUD_LABS_ERROR,
                progressNoteAfterUpdate.VCC_Recent_SUD_Labs__c,
                'Did not expect label for error.'
            );
            System.Assert.isFalse(
                String.isBlank(progressNoteAfterUpdate.VCC_Recent_SUD_Labs__c),
                'Expected non-blank value.'
            );
        }
    }

    @IsTest
    static void intgnItUpdatesRecentSudLabsFieldWithLabelWhenNoSudLabsFound() {
        //NOPMD

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_LabJsonExample');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);

        RecordType caseRecordType = VCC_TestDataFactory.getRecordType('Case', 'VCC_Pharmacy');
        Account account = VCC_TestDataFactory.generateVccPersonAccounts(1)[0];
        VCC_TestDataFactory.CallTaskWrapper callWrapper = new VCC_TestDataFactory.CallTaskWrapper();
        callWrapper.acct = account;
        callWrapper.callerName = 'Test';
        callWrapper.callerRelationType = 'Self';
        callWrapper.ownerId = UserInfo.getUserId();

        VCC_TestDataFactory.createCallTask(callWrapper);
        Case cse = VCC_TestDataFactory.createCase('VCC_PatientLabServiceTest', caseRecordType.Id, account.Id);
        VCC_Progress_Note__c progressNote = VCC_TestDataFactory.createProgressNote(cse.Id);

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                VCC_PatientLabService.updateProgressNoteWithSUDInformation(progressNote.Id);
            } catch (DmlException dmlException) {
                for (Integer idx = 0; idx < dmlException.getNumDml(); idx++) {
                    Logger.debug(dmlException.getDmlMessage(idx) + ' ' + dmlException.getDmlFields(idx));
                }
            } catch (Exception exc) {
                System.Assert.fail('Unexpected exception ' + exc.getMessage() + '\n' + exc.getStackTraceString());
            }
            Test.stopTest();

            VCC_Progress_Note__c progressNoteAfterUpdate = [
                SELECT VCC_Recent_SUD_Labs__c
                FROM VCC_Progress_Note__c
                WHERE Id = :progressNote.Id
                LIMIT 1
            ];
            System.Assert.areEqual(
                VCC_PatientLabService.RECENT_SUD_LABS_NONE,
                progressNoteAfterUpdate.VCC_Recent_SUD_Labs__c,
                'Expected to find label value for no labs in field.'
            );
        }
    }

    @IsTest
    static void intgnItUpdatesRecentSudLabsFieldWithLabelWhenError() {
        //NOPMD

        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_LabJsonExample');
        mock.setStatusCode(504);
        Test.setMock(HttpCalloutMock.class, mock);

        RecordType caseRecordType = VCC_TestDataFactory.getRecordType('Case', 'VCC_Pharmacy');
        Account account = VCC_TestDataFactory.generateVccPersonAccounts(1)[0];
        VCC_TestDataFactory.CallTaskWrapper callWrapper = new VCC_TestDataFactory.CallTaskWrapper();
        callWrapper.acct = account;
        callWrapper.callerName = 'Test';
        callWrapper.callerRelationType = 'Self';
        callWrapper.ownerId = UserInfo.getUserId();

        VCC_TestDataFactory.createCallTask(callWrapper);
        Case cse = VCC_TestDataFactory.createCase('VCC_PatientLabServiceTest', caseRecordType.Id, account.Id);
        VCC_Progress_Note__c progressNote = VCC_TestDataFactory.createProgressNote(cse.Id);

        System.runAs(createTestAdminUser()) {
            Test.startTest();
            try {
                VCC_PatientLabService.updateProgressNoteWithSUDInformation(progressNote.Id);
            } catch (DmlException dmlException) {
                for (Integer idx = 0; idx < dmlException.getNumDml(); idx++) {
                    Logger.debug(dmlException.getDmlMessage(idx) + ' ' + dmlException.getDmlFields(idx));
                }
            } catch (Exception e) {
                System.Assert.fail('Unexpected exception ' + e.getMessage() + '\n' + e.getStackTraceString());
            }
            Test.stopTest();

            VCC_Progress_Note__c progressNoteAfterUpdate = [
                SELECT VCC_Recent_SUD_Labs__c
                FROM VCC_Progress_Note__c
                WHERE Id = :progressNote.Id
                LIMIT 1
            ];
            System.Assert.areEqual(
                VCC_PatientLabService.RECENT_SUD_LABS_ERROR,
                progressNoteAfterUpdate.VCC_Recent_SUD_Labs__c,
                'Expected to find label error message in field.'
            );
        }
    }

    private static void updateProgressNoteWithSUDInformation() {
        System.runAs(createTestAdminUser()) {
            Exception thrownException;

            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_LabJsonExample');
            mock.setStatusCode(200);
            Test.setMock(HttpCalloutMock.class, mock);

            RecordType caseRecordType = VCC_TestDataFactory.getRecordType('Case', 'VCC_Pharmacy');
            Account account = VCC_TestDataFactory.generateVccPersonAccounts(1)[0];
            Case cse = VCC_TestDataFactory.createCase('VCC_PatientLabServiceTest', caseRecordType.Id, account.Id);
            VCC_Progress_Note__c progressNote = VCC_TestDataFactory.createProgressNote(cse.Id);

            Test.startTest();
            try {
                VCC_PatientLabService.updateProgressNoteWithSUDInformation(progressNote.Id);
            } catch (Exception e) {
                thrownException = e;
            }
            System.assertEquals(thrownException, null, 'Expected mock callout to succeed without expection');

            Test.stopTest();
        }
    }
}
