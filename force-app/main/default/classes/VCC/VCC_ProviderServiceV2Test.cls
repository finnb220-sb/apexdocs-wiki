@IsTest
private with sharing class VCC_ProviderServiceV2Test {
    @TestSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }

    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    /**
     * @description Creates progress note record
     * @return      `Id` record Id
     */
    private static Id createProgressNoteId() {
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            )
        );
        return testProgressNote.Id;
    }

    @IsTest
    private static void getProviderDuzTest() {
        System.runAs(getTestUser()) {
            IAM_SSOi_Vista_Instance_to_User_DUZ__c vtud = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
                User_Id__c = UserInfo.getUserId(),
                DUZ__c = '12345',
                VistA_Instance__c = '983',
                Name = 'mockSSO.' + UserInfo.getUserId()
            );

            insert vtud;

            String duz;
            Test.startTest();
            duz = VCC_ProviderServiceV2.instance.getProviderDuz(UserInfo.getUserId(), '983');
            Test.stopTest();

            System.assert(duz == '12345', 'Expected duz of 12345.');
        }
    }

    @IsTest
    private static void unitValidateEsigPositive() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
        mock.setStatusCode(200);

        Boolean result;
        Test.setMock(HttpCalloutMock.class, mock);
        System.runAs(getTestUser()) {
            Test.startTest();
            result = VCC_ProviderServiceV2.instance.validateEsig(
                UserInfo.getUserId(),
                'test',
                'test',
                'test',
                createProgressNoteId()
            );
            Test.stopTest();

            System.assert(result == true, 'Expected true.');
        }
    }

    @IsTest
    private static void getVistaInstanceSettings() {
        System.runAs(getTestUser()) {
            Test.startTest();
            List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> vistaInstanceSettings = VCC_ProviderServiceV2.instance.getVistaInstanceSettings(
                UserInfo.getUserId()
            );
            Test.stopTest();
            System.assert(vistaInstanceSettings != null, 'Failed to properly retrieve Vista instance');
        }
    }

    @IsTest
    static void unitStubPositive() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_Stub providerServiceStub = VCC_ProviderServiceV2.stub();

            System.assert(
                VCC_ProviderServiceV2.instance === (VCC_ProviderServiceV2) providerServiceStub.instance,
                'Expected to find stubbed object.s'
            );
        }
        Test.stopTest();
    }
}
