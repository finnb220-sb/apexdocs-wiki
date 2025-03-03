/**
 * @description       :
 * @author            : Ronald Stewart
 * @group             :
 * @last modified on  : 01-11-2024
 * @last modified by  : Ronald Stewart
 **/
@isTest
public with sharing class VCC_BridgVisitsRSTest {
    @isTest
    public static void instantiationTest() {
        Id profileId = DTCTestUtil.getProfileId('VAVET Base Profile');
        User vahcUser = DTCTestUtil.createUserWithProfile(profileId);
        List<String> permissionSets = new List<String>{ 'VAHC Registered Nurse', 'VCC Integration Test Utility User' };
        DTCTestUtil.addPermSetsToUser(vahcUser, permissionSets);
        Boolean errorThrown = false;
        Test.startTest();
        System.runAs(vahcUser) {
            HttpResponse response = new HttpResponse();
            response.setBody('{"exception":"Exceeded Max","case":"123455"}');
            response.setStatus('200');

            VCC_BaseClient.BaseResponse baseResp = new VCC_BaseClient.BaseResponse(response, null, null);

            try {
                VCC_BridgVisitsRS bridgeVRS = new VCC_BridgVisitsRS(baseResp);
                System.assert(bridgeVRS.isMaxRecordsError == true, 'isMaxRecordsError should equal to true. | method: instantiationTest');
            } catch (Exception errorException) {
                errorThrown = true;
            }
            System.assert(errorThrown == false, 'Error was thrown during isMaxRecordsError test. | method: instantiationTest');
        }

        System.assert(new VCC_BridgVisitsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitParams() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitDataClass() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitItem() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitDocument() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitStay() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgVisitsRS.VisitMovement() != null, 'Instantiation failed.');
        Test.stopTest();
    }
}
