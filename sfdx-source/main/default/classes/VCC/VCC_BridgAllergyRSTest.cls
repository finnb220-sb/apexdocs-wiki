/**
 * @description       :
 * @author            : Ronald Stewart
 * @group             :
 * @last modified on  : 01-16-2024
 * @last modified by  : Ronald Stewart
 **/
@isTest
public with sharing class VCC_BridgAllergyRSTest {
    @isTest
    public static void instantiationTest() {
        Id profileId = DTCTestUtil.getProfileId('VAVET Base Profile');
        User vahcUser = DTCTestUtil.createUserWithProfile(profileId);
        List<String> permissionSets = new List<String>{ 'VAHC Registered Nurse', 'VCC Integration Test Utility User' };
        DTCTestUtil.addPermSetsToUser(vahcUser, permissionSets);
        System.runAs(vahcUser) {
            Boolean errorThrown = false;
            HttpResponse response = new HttpResponse();
            response.setBody('{"exception":"Exceeded Max","case":"123455"}');
            response.setStatus('200');

            VCC_BaseClient.BaseResponse baseResp = new VCC_BaseClient.BaseResponse(response, null, null);

            Test.startTest();
            try {
                VCC_BridgAllergyRS bridgeARS = new VCC_BridgAllergyRS(baseResp);
                System.assert(bridgeARS.isMaxRecordsError == true, 'isMaxRecordsError should equal to true.');
            } catch (Exception errorException) {
                errorThrown = true;
            }
            System.assert(errorThrown == false, 'Error was thrown during isMaxRecordsError test.');
            System.assert(new VCC_BridgAllergyRS() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.ClinicalData() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.ClinicalDataPatient() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.PractitionerParticipationLite() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.DrugIngredient() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.DrugClass() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.ReactionObservationEvent() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.AllergyCommentEvent() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.IntoleranceCondition() != null, 'Instantiation failed.');
            System.assert(new VCC_BridgAllergyRS.AllergyAssessment() != null, 'Instantiation failed.');
            Test.stopTest();
        }
    }
}
