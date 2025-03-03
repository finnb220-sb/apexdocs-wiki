/**
 *
 * Class Description
 *@description tests for VCC_PatientAdditionalSignersController
 * @author barne
 * @version 1.0.0
 */

@IsTest
private class VCC_PatientAddSignersControllerTest {
    @testSetup
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

    @IsTest
    static void unitPositivetestgetPatientAdditionalSigners() {
        System.runAs(getTestUser()) {
            Map<String, Object> params = new Map<String, Object>{
                'nationalId' => '123456',
                'assigningAuthority' => 'L1GmA',
                'assigningFacility' => '6EN',
                'ien' => '22116644883',
                'documents' => new List<String>{ 'documentaA', 'DocumentB', 'DocumentC' }
            };
            Test.startTest();
            StaticResourceCalloutMock mock = (StaticResourceCalloutMock) VCC_TestDataFactory.generateCalloutMockForTest('VCC_BridgAdditionalSignersMock');
            Test.setMock(HttpCalloutMock.class, mock);
            String returnVal = VCC_PatientAdditionalSignersController.getPatientAdditionalSigners(params);

            Test.stopTest();
            System.assert(returnVal != null, 'Expected value returned by mock');
        }
    }

    @Istest
    static void positiveTestgetAdditionalSigners() {
        System.runAs(getTestUser()) {
            Map<String, Object> params = new Map<String, Object>{
                'nationalId' => '123456',
                'assigningAuthority' => 'L1GmA',
                'assigningFacility' => '6EN',
                'ien' => '22116644883',
                'documents' => new List<String>{ 'documentaA', 'DocumentB', 'DocumentC' }
            };

            Test.startTest();
            StaticResourceCalloutMock mock = (StaticResourceCalloutMock) VCC_TestDataFactory.generateCalloutMockForTest('VCC_BridgAdditionalSignersMock');
            Test.setMock(HttpCalloutMock.class, mock);
            string returnVal = VCC_PatientAdditionalSignersController.getAdditionalSigners(params);
            Test.stopTest();
            System.assert(returnVal != null, 'Expected value returned by mock');
        }
    }

    @Istest
    static void negativeTestgetAdditionalSigners() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_PatientAdditionalSignersController.getAdditionalSigners(new Map<String, Object>());
            } catch (Exception e) {
                System.assertEquals(AuraHandledException.class.getName(), e.getTypeName(), 'Expected AuraHandled Exception thrown on bad params');
            }
            Test.stopTest();
        }
    }
}
