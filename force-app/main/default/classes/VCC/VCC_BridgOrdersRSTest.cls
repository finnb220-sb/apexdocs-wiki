@isTest
public with sharing class VCC_BridgOrdersRSTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();

        VCC_BridgOrdersRS parentInstance = new VCC_BridgOrdersRS();
        VCC_BridgOrdersRS.OrdersSite ordersSiteInstance = new VCC_BridgOrdersRS.OrdersSite();
        VCC_BridgOrdersRS.OrdersResults ordersResultsInstance = new VCC_BridgOrdersRS.OrdersResults();
        VCC_BridgOrdersRS.OrdersOrders ordersOrdersInstance = new VCC_BridgOrdersRS.OrdersOrders();
        VCC_BridgOrdersRS.OrdersOrder ordersOrderInstance = new VCC_BridgOrdersRS.OrdersOrder();
        VCC_BridgOrdersRS.OrdersResultID resultIdInstance = new VCC_BridgOrdersRS.OrdersResultID();
        VCC_BridgOrdersRS.OrdersStart startInstance = new VCC_BridgOrdersRS.OrdersStart();
        VCC_BridgOrdersRS.OrdersSigned signedInstance = new VCC_BridgOrdersRS.OrdersSigned();
        VCC_BridgOrdersRS.OrdersEntered enteredInstance = new VCC_BridgOrdersRS.OrdersEntered();
        VCC_BridgOrdersRS.OrdersType typeInstance = new VCC_BridgOrdersRS.OrdersType();
        VCC_BridgOrdersRS.OrdersContent contentInstance = new VCC_BridgOrdersRS.OrdersContent();
        VCC_BridgOrdersRS.OrdersSignatureStatus signatureStatusInstance = new VCC_BridgOrdersRS.OrdersSignatureStatus();
        VCC_BridgOrdersRS.OrdersProvider providerInstance = new VCC_BridgOrdersRS.OrdersProvider();
        VCC_BridgOrdersRS.OrdersService serviceInstance = new VCC_BridgOrdersRS.OrdersService();
        VCC_BridgOrdersRS.OrdersName nameInstance = new VCC_BridgOrdersRS.OrdersName();
        VCC_BridgOrdersRS.OrdersLocation locationInstance = new VCC_BridgOrdersRS.OrdersLocation();
        VCC_BridgOrdersRS.OrdersCodingSystem codingSystemInstance = new VCC_BridgOrdersRS.OrdersCodingSystem();
        VCC_BridgOrdersRS.OrdersId idInstance = new VCC_BridgOrdersRS.OrdersId();
        VCC_BridgOrdersRS.OrdersFacility facilityInstance = new VCC_BridgOrdersRS.OrdersFacility();
        VCC_BridgOrdersRS.OrdersReleased releasedInstance = new VCC_BridgOrdersRS.OrdersReleased();
        VCC_BridgOrdersRS.OrdersGroup groupInstance = new VCC_BridgOrdersRS.OrdersGroup();
        VCC_BridgOrdersRS.OrdersSigner signerInstance = new VCC_BridgOrdersRS.OrdersSigner();
        VCC_BridgOrdersRS.OrdersStatus statusInstance = new VCC_BridgOrdersRS.OrdersStatus();
        VCC_BridgOrdersRS.OrdersDiscontinued discontinuedInstance = new VCC_BridgOrdersRS.OrdersDiscontinued();
        VCC_BridgOrdersRS.OrdersStop stopInstance = new VCC_BridgOrdersRS.OrdersStop();
        VCC_BridgOrdersRS.OrdersVuid vuidInstance = new VCC_BridgOrdersRS.OrdersVuid();
        VCC_BridgOrdersRS.OrdersAcknowledgements acknowledgementsInstance = new VCC_BridgOrdersRS.OrdersAcknowledgements();
        VCC_BridgOrdersRS.OrdersAcknowledgement acknowledgementInstance = new VCC_BridgOrdersRS.OrdersAcknowledgement();

        // Perform assertions to verify instantiation
        System.assertNotEquals(parentInstance, null, 'Parent instantiation failed.');
        System.assertNotEquals(ordersSiteInstance, null, 'OrdersSite instantiation failed.');
        System.assertNotEquals(ordersResultsInstance, null, 'OrdersResults instantiation failed.');
        System.assertNotEquals(ordersOrdersInstance, null, 'OrdersOrders instantiation failed.');
        System.assertNotEquals(ordersOrderInstance, null, 'OrdersOrder instantiation failed.');
        System.assertNotEquals(resultIdInstance, null, 'OrdersResultID instantiation failed.');
        System.assertNotEquals(startInstance, null, 'OrdersStart instantiation failed.');
        System.assertNotEquals(signedInstance, null, 'OrdersSigned instantiation failed.');
        System.assertNotEquals(enteredInstance, null, 'OrdersEntered instantiation failed.');
        System.assertNotEquals(typeInstance, null, 'OrdersType instantiation failed.');
        System.assertNotEquals(contentInstance, null, 'OrdersContent instantiation failed.');
        System.assertNotEquals(signatureStatusInstance, null, 'OrdersSignatureStatus instantiation failed.');
        System.assertNotEquals(providerInstance, null, 'OrdersProvider instantiation failed.');
        System.assertNotEquals(serviceInstance, null, 'OrdersService instantiation failed.');
        System.assertNotEquals(nameInstance, null, 'OrdersName instantiation failed.');
        System.assertNotEquals(locationInstance, null, 'OrdersLocation instantiation failed.');
        System.assertNotEquals(codingSystemInstance, null, 'OrdersCodingSystem instantiation failed.');
        System.assertNotEquals(idInstance, null, 'OrdersId instantiation failed.');
        System.assertNotEquals(facilityInstance, null, 'OrdersFacility instantiation failed.');
        System.assertNotEquals(releasedInstance, null, 'OrdersReleased instantiation failed.');
        System.assertNotEquals(groupInstance, null, 'OrdersGroup instantiation failed.');
        System.assertNotEquals(signerInstance, null, 'OrdersSigner instantiation failed.');
        System.assertNotEquals(statusInstance, null, 'OrdersStatus instantiation failed.');
        System.assertNotEquals(discontinuedInstance, null, 'OrdersDiscontinued instantiation failed.');
        System.assertNotEquals(stopInstance, null, 'OrdersStop instantiation failed.');
        System.assertNotEquals(vuidInstance, null, 'OrdersVuid instantiation failed.');
        System.assertNotEquals(acknowledgementsInstance, null, 'OrdersAcknowledgements instantiation failed.');
        System.assertNotEquals(acknowledgementInstance, null, 'OrdersAcknowledgement instantiation failed.');

        Test.stopTest();
    }

    @isTest
    public static void parameterizedConstructorTest() {
        VCC_BaseClient.BaseResponse mockBaseResponse = new VCC_BaseClient.BaseResponse();
        VCC_BridgOrdersRS parentInstance = new VCC_BridgOrdersRS(mockBaseResponse);
    }

    @isTest
    public static void baseResponse() {
        VCC_BaseClient.BaseResponse base = new VCC_BaseClient.BaseResponse();
        VCC_BridgOrdersRS bridg = new VCC_BridgOrdersRS();
        bridg.sites.add(new VCC_BridgOrdersRS.OrdersSite());
        bridg.sites[0].results.version = 'Exceeded Max';

        bridg.isMaxRecordsError = false;
        base.httpResponse = new HttpResponse();
        base.httpResponse.setBody(json.serialize(bridg));

        Test.startTest();
        System.assert(bridg.isMaxRecordsError == false, ' Variable isMaxRecordsError  does not exist and is not instantiated');
        VCC_BridgOrdersRS bridg2 = new VCC_BridgOrdersRS(base);
        System.assertEquals(true, bridg2.isMaxRecordsError);
        Test.stopTest();
    }
}
