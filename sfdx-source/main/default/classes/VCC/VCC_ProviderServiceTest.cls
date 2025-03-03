/**
 * Deprecated 9/15/2022 see VCC_ProviderServiceV2Test
 */
@IsTest
private with sharing class VCC_ProviderServiceTest {
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

    /**
     * @description Creates an admin test user
     * @return      `User`
     */
    private static User createTestAdminUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(
                new Set<String>(
                    new List<String>{
                        'VAHC_RN_User',
                        'VAHC_Write_Clinical_Triage_Progress_Note',
                        'VAHC_Read_Progress_Notes',
                        'VAHC_Write_Virtual_Clinic_Visit_Progress_Note',
                        'VAHC_MP_User'
                    }
                )
            )
            .build(true);
    }

    @IsTest
    private static void getProviderDuzTest() {
        IAM_SSOi_Vista_Instance_to_User_DUZ__c vtud = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            User_Id__c = UserInfo.getUserId(),
            DUZ__c = '12345',
            VistA_Instance__c = '983',
            Name = 'mockSSO.' + UserInfo.getUserId()
        );

        insert vtud;

        String duz;
        Test.startTest();
        duz = VCC_ProviderService.getProviderDuz(UserInfo.getUserId(), '983');
        Test.stopTest();

        System.assert(duz == '12345', 'Expected duz of 12345.');
    }

    @IsTest
    private static void unitValidateEsigPositive() {
        System.runAs(createTestAdminUser()) {
            StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
            mock.setStaticResource('VCC_vdifIsValidEsigMockResponse');
            mock.setStatusCode(200);

            Boolean result;
            Test.setMock(HttpCalloutMock.class, mock);
            Test.startTest();
            result = VCC_ProviderService.validateEsig(
                UserInfo.getUserId(),
                'test',
                'test',
                'test',
                createProgressNoteId()
            );
            Test.stopTest();

            Assert.isTrue(result, 'Expected true.');
        }
    }

    @IsTest
    private static void getVistaInstanceSettings() {
        Test.startTest();
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> vistaInstanceSettings = VCC_ProviderService.getVistaInstanceSettings(
            UserInfo.getUserId()
        );
        Test.stopTest();
        Assert.isNotNull(vistaInstanceSettings, 'Expected list to be not be null.');
    }

    @IsTest
    private static void unitGetVistaInstanceSettingsNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            Id testId;
            Assert.isNull(
                VCC_ProviderService.getVistaInstanceSettings(testId),
                'Expected getVistaInstanceSettings method to return null'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitGetProviderDuzNegative() {
        System.runAs(createTestAdminUser()) {
            Id testId;
            Test.startTest();
            Assert.isNull(VCC_ProviderService.getProviderDuz(testId, '983'), 'Expected method to return null.');
            Test.stopTest();
        }
    }
}
