@IsTest
private with sharing class VCC_DivaClientTest {
    // Constructor and Properties
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_DivaClient divaClient = new VCC_DivaClient();
        Test.stopTest();

        System.assert(divaClient != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void properties() {
        Test.startTest();
        System.assertEquals('https://divaclient.mock', VCC_DivaClient.NAMED_CREDENTIAL, 'Expected values to match.');
        Test.stopTest();
    }

    // Inner Classes
    @IsTest
    private static void refillMedicationsRQ() {
        Test.startTest();
        VCC_DivaClient.RefillMedicationsRQ refillMedicationsRQ = new VCC_DivaClient.RefillMedicationsRQ();
        System.assert(refillMedicationsRQ != null, 'Expected class to be initialized.');
        System.assert(refillMedicationsRQ.refillRequests != null, 'Expected list to be initialized.');
        Test.stopTest();
    }

    @IsTest
    private static void refillMedicationsRQByListOfRefillRequests() {
        Test.startTest();
        VCC_DivaClient.RefillMedicationsRQ refillMedicationsRQ = new VCC_DivaClient.RefillMedicationsRQ(new List<VCC_DivaClient.RefillRequest>());
        System.assert(refillMedicationsRQ != null, 'Expected class to be initialized.');
        System.assert(refillMedicationsRQ.refillRequests != null, 'Expected list to be initialized.');
        Test.stopTest();
    }

    @IsTest
    private static void refillMedicationsRQByListOfMedRefillRequests() {
        Test.startTest();
        VCC_DivaClient.RefillMedicationsRQ refillMedicationsRQ = new VCC_DivaClient.RefillMedicationsRQ(
            new List<VCC_MedsService.MedRefillRequest>{ new VCC_MedsService.MedRefillRequest() }
        );
        System.assert(refillMedicationsRQ != null, 'Expected class to be initialized.');
        System.assert(refillMedicationsRQ.refillRequests != null, 'Expected list to be initialized.');
        Test.stopTest();
    }

    @IsTest
    private static void refillMedicationsRS() {
        Test.startTest();
        VCC_DivaClient.RefillMedicationsRS refillMedicationsRS = new VCC_DivaClient.RefillMedicationsRS();
        System.assert(refillMedicationsRS != null, 'Expected class to be initialized.');
        System.assert(refillMedicationsRS.responseJSON != null, 'Expected list to be initialized.');
        System.assertEquals(true, refillMedicationsRS.allSuccessful, 'Unexpected different value.');

        VCC_DivaClient.ResponseJSON responseJSON = new VCC_DivaClient.ResponseJSON();
        responseJSON.prescriptionId = 'fakeId';
        responseJSON.success = false;
        responseJSON.message = 'Force unit test failure.';
        refillMedicationsRS.responseJSON.add(responseJSON);
        System.assert(refillMedicationsRS.responseJSON != null, 'Expected list to be initialized.');
        System.assertEquals(false, refillMedicationsRS.allSuccessful, 'Unexpected different value.');

        Test.stopTest();
    }

    // Methods
    @IsTest
    private static void refillMedications() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCC_DivaClient_RefillMedicationsRS');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        VCC_DivaClient.RefillMedicationsRQ refillMedicationsRQ = new VCC_DivaClient.RefillMedicationsRQ();
        refillMedicationsRQ.refillRequests.add(new VCC_DivaClient.RefillRequest('facilityId', 'prescriptionId', 'icn', 'requesterId'));

        Test.startTest();
        VCC_DivaClient.RefillMedicationsRS refillMedicationsRS = new VCC_DivaClient().refillMedications(refillMedicationsRQ);
        Test.stopTest();

        System.assert(refillMedicationsRS != null, 'Expected class to be initialized.');
    }

    @IsTest
    private static void refillMedicationsRequestSizeException() {
        VCC_DivaClient.RefillMedicationsRQ refillMedicationsRQ = new VCC_DivaClient.RefillMedicationsRQ();
        for (Integer x = 0; x < 100; x++) {
            refillMedicationsRQ.refillRequests.add(new VCC_DivaClient.RefillRequest('facilityId', 'prescriptionId', 'icn', 'requesterId'));
        }

        Test.startTest();
        try {
            new VCC_DivaClient().refillMedications(refillMedicationsRQ);
        } catch (VCC_DivaClient.VCC_DivaClientException e) {
            System.assertEquals('Refill request size exceeds limit.', e.getMessage(), 'Expected a different exception message.');
        }
        Test.stopTest();
    }

    @SuppressWarnings('PMD.ApexDoc, PMD.CognitiveComplexity')
    @IsTest
    private static void callDiva() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCActivityLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');

        Test.startTest();

        HttpResponse goodCall = VCC_DivaClient.callDiva(pharmLogRQ, 'vccDivaActivityLog');
        System.assert(goodCall != null, 'Expected good call to not be null');

        // handle 400s
        try {
            staticResourceMock.setStatusCode(404);
            VCC_DIvaClient.callDiva(pharmLogRQ, 'vccDivaActivityLog');
        } catch (Exception ex) {
            system.assert(ex.getTypeName() == 'VCC_DivaClient.VCC_DivaBadRequestException', 'expected DIVA bad request exception');
        }

        // handle 500s
        try {
            staticResourceMock.setStatusCode(500);
            VCC_DivaClient.callDiva(pharmLogRQ, 'vccDivaActivityLog');
        } catch (Exception ex) {
            system.assert(ex.getTypeName() == 'VCC_DivaClient.VCC_DivaRemoteInternalException', 'Expected remote internal exception');
        }

        // handle everything else
        try {
            staticResourceMock.setStatusCode(100);
            VCC_DivaClient.callDiva(pharmLogRQ, 'vccDivaActivityLog');
        } catch (Exception ex) {
            system.assert(ex.getTypeName() == 'VCC_DivaClient.VCC_DivaClientException', 'Expected remote internal exception');
        }

        Test.stopTest();
    }

    @IsTest
    private static void getActivityLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCActivityLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_ActivityLogRS activityLog = new VCC_DivaClient().getActivityLog(pharmLogRQ);

        system.assert(activityLog.success == true, 'Expected success is set to true on activity log object');

        Test.stopTest();
    }

    @isTest
    private static void getRefillLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCRefillLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_RefillLogRS refillLog = new VCC_DivaClient().getRefillLog(pharmLogRQ);

        system.assert(refillLog.success == true, 'Expected success is set to true on refill log object');

        Test.stopTest();
    }

    @isTest
    private static void getPartialLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCPartialLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_PartialsLogRS partialLog = new VCC_DivaClient().getPartialsLog(pharmLogRQ);

        system.assert(partialLog.success == true, 'Expected success is set to true on partial log object');

        Test.stopTest();
    }

    @isTest
    private static void getLabelLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCLabelLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_LabelLogRS labelLog = new VCC_DivaClient().getLabelLog(pharmLogRQ);

        system.assert(labelLog.success == true, 'Expected success is set to true on label log object');

        Test.stopTest();
    }

    @isTest
    private static void getERXLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCErxLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_ErxLogRS eRxLog = new VCC_DivaClient().getERXLog(pharmLogRQ);

        system.assert(eRxLog.success == true, 'Expected success is set to true on eRx log object');

        Test.stopTest();
    }

    @isTest
    private static void getCMOPLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCCMOPLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_CmopLogRS cmopLog = new VCC_DivaClient().getCMOPLog(pharmLogRQ);

        system.assert(cmopLog.success == true, 'Expected success is set to true on cmop log object');

        Test.stopTest();
    }

    @isTest
    private static void getCopayLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCCopayLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_CopayLogRS copayLog = new VCC_DivaClient().getCopayLog(pharmLogRQ);

        system.assert(copayLog.success == true, 'Expected success is set to true on copay log object');

        Test.stopTest();
    }

    @isTest
    private static void getECMELog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCEcmeLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_EcmeLogRS ecmeLog = new VCC_DivaClient().getECMELog(pharmLogRQ);

        system.assert(ecmeLog.success == true, 'Expected success is set to true on ecme log object');

        Test.stopTest();
    }

    @isTest
    private static void getCMOPLotExpLog() {
        StaticResourceCalloutMock staticResourceMock = new StaticResourceCalloutMock();
        staticResourceMock.setStaticResource('VCCLotExpLogMock');
        staticResourceMock.setHeader('Content-Type', 'application/json');
        staticResourceMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, staticResourceMock);

        Test.startTest();
        VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ('12344', '541');
        VCC_CmopLotExpLogRS cmopLotLog = new VCC_DivaClient().getCMOPLotExpLog(pharmLogRQ);

        system.assert(cmopLotLog.success == true, 'Expected success is set to true on cmopLotExp log object');

        Test.stopTest();
    }
}
