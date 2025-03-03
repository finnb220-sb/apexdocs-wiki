/**
 * @description       :
 * @author            : Ronald Stewart
 * @group             :
 * @last modified on  : 01-11-2024
 * @last modified by  : Ronald Stewart
 **/
@isTest
public with sharing class VCC_BridgRadiologyExamsRSTest {
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
                VCC_BridgRadiologyExamsRS bridgeRERS = new VCC_BridgRadiologyExamsRS(baseResp);
                System.assert(bridgeRERS.isMaxRecordsError == true, 'isMaxRecordsError should equal to true.');
            } catch (Exception errorException) {
                errorThrown = true;
            }
            System.assert(errorThrown == false, 'Error was thrown during isMaxRecordsError test.');
        }

        System.assert(new VCC_BridgRadiologyExamsRS() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.ExamSite() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.ExamSiteResults() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.Exams() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExam() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsDateTime() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsImagingType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsName() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsHasImages() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsLocation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsId() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsCategory() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsFacility() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsCase() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsDocuments() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamDocument() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsType() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsProvider() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsStatus() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsEncounter() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsInterpretation() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsModifiers() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamModifier() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsOrder() != null, 'Instantiation failed.');
        System.assert(new VCC_BridgRadiologyExamsRS.RadiologyExamsUrgency() != null, 'Instantiation failed.');
        Test.stopTest();
    }
}
