/**
 * @description Test class for VCC_DASFlowCreateAddendumAndSign
 * @author Booz Allen Hamilton
 * @since 04/25/2024
 * @see VCC_DASFlowCreateAddendumAndSign
 */
@IsTest
@TestVisible
private with sharing class VCC_DASFlowCreateAddendumAndSignTest {
    @TestVisible
    private static VATEST_Stub stubFlowCreateAddendumAndSignInstance(List<VATEST_MockedMethod> mockedMethodList) {
        VATEST_Stub flowCreateAddendumAndSignInstanceStub = new VATEST_Stub(
            VCC_DASFlowCreateAddendumAndSign.class,
            mockedMethodList
        );
        VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance = (VCC_DASFlowCreateAddendumAndSign) flowCreateAddendumAndSignInstanceStub.createStub();
        return flowCreateAddendumAndSignInstanceStub;
    }

    @TestVisible
    private static VATEST_MockedMethod getMockedMethodHandleFlowCreateAddendumAndSign() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'handleFlowCreateAddendumAndSign',
                new List<System.Type>{ List<VCC_DASFlowCreateAddendumAndSign.Request>.class }
            )
        );
    }

    @IsTest
    private static void unitRequestPropertyReadPositive() {
        Test.startTest();
        try {
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumAndSignFlowRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
            Assert.isNull(createAddendumAndSignFlowRequest.esig, 'Expected default constructed value to be null');
            Assert.isNull(createAddendumAndSignFlowRequest.type, 'Expected default constructed value to be null');
            Assert.isNull(createAddendumAndSignFlowRequest.itemId, 'Expected default constructed value to be null');
            Assert.isNull(
                createAddendumAndSignFlowRequest.providerUserId,
                'Expected default constructed value to be null'
            );
            Assert.isNull(
                createAddendumAndSignFlowRequest.providerName,
                'Expected default constructed value to be null'
            );
            Assert.isNull(createAddendumAndSignFlowRequest.siteCode, 'Expected default constructed value to be null');
            Assert.isNull(createAddendumAndSignFlowRequest.recordId, 'Expected default constructed value to be null');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitRequestPropertyWritePositive() {
        Test.startTest();
        try {
            VCC_DASFlowCreateAddendumAndSign.Request createAddendumAndSignFlowRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
            createAddendumAndSignFlowRequest.esig = 'test esig';
            createAddendumAndSignFlowRequest.type = 'test type';
            createAddendumAndSignFlowRequest.itemId = 'test itemId';
            createAddendumAndSignFlowRequest.providerUserId = 'test providerUserId';
            createAddendumAndSignFlowRequest.providerName = 'test providerName';
            createAddendumAndSignFlowRequest.siteCode = '123';
            createAddendumAndSignFlowRequest.recordId = VATEST_IdFactory.get(VCC_Addendum__c.class);
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitRequestToCreateAddendumAndSignRqPositive() {
        VCC_DASFlowCreateAddendumAndSign.Request dasFlowCreateAddendumAndSignRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
        dasFlowCreateAddendumAndSignRequest.esig = 'test esig';
        dasFlowCreateAddendumAndSignRequest.itemId = 'test itemId';
        dasFlowCreateAddendumAndSignRequest.providerName = 'test providerName';
        dasFlowCreateAddendumAndSignRequest.providerUserId = 'test providerUserId';
        dasFlowCreateAddendumAndSignRequest.recordId = VATEST_IdFactory.get(VCC_Addendum__c.class);
        dasFlowCreateAddendumAndSignRequest.siteCode = '123';
        dasFlowCreateAddendumAndSignRequest.type = 'test type';
        String parserReturnValue = 'test parsed record';
        List<String> signersListReturnValue = new List<String>{ 'some signer' };
        VATEST_Stub parserStub = VCC_DASServicesTest.stubParser(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceParserTest.getMockedMethodParse()
                    .withParameterValues(
                        new List<Object>{ new VCC_Addendum__c(Id = dasFlowCreateAddendumAndSignRequest.recordId) }
                    )
                    .returning(parserReturnValue)
            }
        );
        VATEST_Stub signersServiceStub = VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ dasFlowCreateAddendumAndSignRequest.recordId })
                    .returning((Object) signersListReturnValue)
            }
        );
        Test.startTest();
        try {
            VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq = dasFlowCreateAddendumAndSignRequest.toCreateAddendumAndSignRq();
            Assert.areEqual(
                dasFlowCreateAddendumAndSignRequest.esig,
                createAddendumAndSignRq.esig,
                'Expected esig value from flow request to match RQ class'
            );
            Assert.areEqual(
                dasFlowCreateAddendumAndSignRequest.itemId,
                createAddendumAndSignRq.itemId,
                'Expected itemId value from flow request to match RQ class'
            );
            Assert.areEqual(
                dasFlowCreateAddendumAndSignRequest.providerName,
                createAddendumAndSignRq.providerName,
                'Expected providerName value from flow request to match RQ class'
            );
            Assert.areEqual(
                dasFlowCreateAddendumAndSignRequest.providerUserId,
                createAddendumAndSignRq.providerUserId,
                'Expected providerUserId value from flow request to match RQ class'
            );
            Assert.areEqual(
                dasFlowCreateAddendumAndSignRequest.siteCode,
                createAddendumAndSignRq.providerLoginSiteCode,
                'Expected siteCode value from flow request to match RQ class'
            );
            Assert.areEqual(
                dasFlowCreateAddendumAndSignRequest.type,
                createAddendumAndSignRq.type,
                'Expected type value from flow request to match RQ class'
            );
            Assert.areEqual(
                signersListReturnValue,
                createAddendumAndSignRq.supplementalParameters,
                'Expected to find stubbed signers return value on RQ class'
            );
            Assert.areEqual(
                parserReturnValue,
                createAddendumAndSignRq.criteria,
                'Expected to find stubbed parser return value on RQ class'
            );
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
        parserStub.assertAllMockedMethodsWereCalled();
        signersServiceStub.assertAllMockedMethodsWereCalled();
    }

    @IsTest
    static void unitCreateAddendumAndSignPositive() {
        VCC_DASFlowCreateAddendumAndSign.Request dasFlowCreateAddendumAndSignRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
        dasFlowCreateAddendumAndSignRequest.esig = 'test esig';
        dasFlowCreateAddendumAndSignRequest.itemId = 'test itemId';
        dasFlowCreateAddendumAndSignRequest.providerName = 'test providerName';
        dasFlowCreateAddendumAndSignRequest.providerUserId = 'test providerUserId';
        dasFlowCreateAddendumAndSignRequest.recordId = VATEST_IdFactory.get(VCC_Addendum__c.class);
        dasFlowCreateAddendumAndSignRequest.siteCode = '123';
        dasFlowCreateAddendumAndSignRequest.type = 'test type';
        List<VCC_DASFlowCreateAddendumAndSign.Request> flowRequestList = new List<VCC_DASFlowCreateAddendumAndSign.Request>{
            dasFlowCreateAddendumAndSignRequest
        };
        List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = new List<VCC_DASFlowConsolidatedEndpointResult>();
        stubFlowCreateAddendumAndSignInstance(
            new List<VATEST_MockedMethod>{
                getMockedMethodHandleFlowCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ flowRequestList })
                    .returning(flowResultList)
            }
        );
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowCreateAddendumAndSign.createAddendumAndSign(
                flowRequestList
            );
            Assert.areEqual(flowResultList, resultList, 'Expected an empty result list.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignNullRequestListNegative() {
        List<VCC_DASFlowCreateAddendumAndSign.Request> flowRequestList = null;
        list<VCC_DASFlowConsolidatedEndpointResult> flowresultlist = new List<VCC_DASFlowConsolidatedEndpointResult>();
        stubFlowCreateAddendumAndSignInstance(
            new List<vatest_mockedmethod>{
                getMockedMethodHandleFlowCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ flowRequestList })
                    .returning(flowResultList)
            }
        );
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowCreateAddendumAndSign.createAddendumAndSign(
                flowRequestList
            );
            Assert.areEqual(flowResultList, resultList, 'Expected an empty result list.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignEmptyRequestListNegative() {
        List<VCC_DASFlowCreateAddendumAndSign.Request> flowRequestList = new List<VCC_DASFlowCreateAddendumAndSign.Request>();
        List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = new List<VCC_DASFlowConsolidatedEndpointResult>();
        stubFlowCreateAddendumAndSignInstance(
            new List<VATEST_MockedMethod>{
                getMockedMethodHandleFlowCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ flowRequestList })
                    .returning(flowResultList)
            }
        );
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowCreateAddendumAndSign.createAddendumAndSign(
                flowRequestList
            );
            Assert.areEqual(flowResultList, resultList, 'Expected an empty result list.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitCreateAddendumAndSignNullRequestNegative() {
        List<VCC_DASFlowCreateAddendumAndSign.Request> flowRequestList = new List<VCC_DASFlowCreateAddendumAndSign.Request>{
            null
        };
        List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = new List<VCC_DASFlowConsolidatedEndpointResult>();
        stubFlowCreateAddendumAndSignInstance(
            new List<VATEST_MockedMethod>{
                getMockedMethodHandleFlowCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ flowRequestList })
                    .returning(flowResultList)
            }
        );
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> resultList = VCC_DASFlowCreateAddendumAndSign.createAddendumAndSign(
                flowRequestList
            );
            Assert.areEqual(flowResultList, resultList, 'Expected an empty result list.');
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitHandleFlowCreateAddendumAndSignPositive() {
        VCC_DASFlowCreateAddendumAndSign.Request dasFlowCreateAddendumAndSignRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
        dasFlowCreateAddendumAndSignRequest.esig = 'test esig';
        dasFlowCreateAddendumAndSignRequest.itemId = 'test itemId';
        dasFlowCreateAddendumAndSignRequest.providerName = 'test providerName';
        dasFlowCreateAddendumAndSignRequest.providerUserId = 'test providerUserId';
        dasFlowCreateAddendumAndSignRequest.recordId = VATEST_IdFactory.get(VCC_Addendum__c.class);
        dasFlowCreateAddendumAndSignRequest.siteCode = '123';
        dasFlowCreateAddendumAndSignRequest.type = 'test type';
        String parserReturnValue = 'test parsed record';
        List<String> signersListReturnValue = new List<String>{ 'some signer' };
        VATEST_Stub parserStub = VCC_DASServicesTest.stubParser(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceParserTest.getMockedMethodParse()
                    .withParameterValues(
                        new List<Object>{ new VCC_Addendum__c(Id = dasFlowCreateAddendumAndSignRequest.recordId) }
                    )
                    .returning(parserReturnValue)
            }
        );
        VATEST_Stub signersServiceStub = VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ dasFlowCreateAddendumAndSignRequest.recordId })
                    .returning((Object) signersListReturnValue)
            }
        );
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq = dasFlowCreateAddendumAndSignRequest.toCreateAddendumAndSignRq();
        VCC_DAS.State dasState = new VCC_DAS.State(
            new VCC_SiteId(dasFlowCreateAddendumAndSignRequest?.siteCode),
            'VAHC',
            dasFlowCreateAddendumAndSignRequest?.recordId
        );
        dasState.endpoint = VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN;
        VATEST_Stub dasServiceApiStub = VCC_DASServicesTest.stubApi(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceApiTest.getMockedMethodCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ createAddendumAndSignRq, dasState })
                    .returning(new VCC_DASCreateAddendumAndSignSuccessRS())
            }
        );
        Test.startTest();
        List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance.handleFlowCreateAddendumAndSign(
            new List<VCC_DASFlowCreateAddendumAndSign.Request>{
                dasFlowCreateAddendumAndSignRequest.clone(),
                dasFlowCreateAddendumAndSignRequest.clone()
            }
        );
        Assert.areEqual(2, flowResultList.size(), 'Expected size to be 2 because 2 requests were input');
        //not testing the contents of the flow results because that is tested in VCC_DasFlowConsolidatedEnpointResultTest
        Test.stopTest();

        dasServiceApiStub.assertAllMockedMethodsWereCalled();
        parserStub.assertAllMockedMethodsWereCalled();
        signersServiceStub.assertAllMockedMethodsWereCalled();
    }

    @IsTest
    static void unitHandleFlowCreateAddendumAndSignNullRequestListNegative() {
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance.handleFlowCreateAddendumAndSign(
                null
            );
            Assert.areEqual(0, flowResultList.size(), 'Expected size to be 0 because 0 requests were input');
            //not testing the contents of the flow results because that is tested in VCC_DasFlowConsolidatedEnpointResultTest
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitHandleFlowCreateAddendumAndSignConsolidatedEndpointExceptionNegative() {
        VCC_DASFlowCreateAddendumAndSign.Request dasFlowCreateAddendumAndSignRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
        dasFlowCreateAddendumAndSignRequest.esig = 'test esig';
        dasFlowCreateAddendumAndSignRequest.itemId = 'test itemId';
        dasFlowCreateAddendumAndSignRequest.providerName = 'test providerName';
        dasFlowCreateAddendumAndSignRequest.providerUserId = 'test providerUserId';
        dasFlowCreateAddendumAndSignRequest.recordId = VATEST_IdFactory.get(VCC_Addendum__c.class);
        dasFlowCreateAddendumAndSignRequest.siteCode = '123';
        dasFlowCreateAddendumAndSignRequest.type = 'test type';
        String parserReturnValue = 'test parsed record';
        List<String> signersListReturnValue = new List<String>{ 'some signer' };
        VATEST_Stub parserStub = VCC_DASServicesTest.stubParser(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceParserTest.getMockedMethodParse()
                    .withParameterValues(
                        new List<Object>{ new VCC_Addendum__c(Id = dasFlowCreateAddendumAndSignRequest.recordId) }
                    )
                    .returning(parserReturnValue)
            }
        );
        VATEST_Stub signersServiceStub = VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ dasFlowCreateAddendumAndSignRequest.recordId })
                    .returning((Object) signersListReturnValue)
            }
        );
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq = dasFlowCreateAddendumAndSignRequest.toCreateAddendumAndSignRq();
        VCC_DAS.State dasState = new VCC_DAS.State(
            new VCC_SiteId(dasFlowCreateAddendumAndSignRequest?.siteCode),
            'VAHC',
            dasFlowCreateAddendumAndSignRequest?.recordId
        );
        dasState.endpoint = VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN;
        VATEST_Stub dasServiceApiStub = VCC_DASServicesTest.stubApi(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceApiTest.getMockedMethodCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ createAddendumAndSignRq, dasState })
                    .throwingException(new VCC_DASConsolidatedEndpointException())
            }
        );
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance.handleFlowCreateAddendumAndSign(
                new List<VCC_DASFlowCreateAddendumAndSign.Request>{
                    dasFlowCreateAddendumAndSignRequest.clone(),
                    dasFlowCreateAddendumAndSignRequest.clone()
                }
            );
            Assert.areEqual(2, flowResultList.size(), 'Expected size to be 2 because 2 requests were input');
            //not testing the contents of the flow results because that is tested in VCC_DasFlowConsolidatedEnpointResultTest
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
        dasServiceApiStub.assertAllMockedMethodsWereCalled();
        parserStub.assertAllMockedMethodsWereCalled();
        signersServiceStub.assertAllMockedMethodsWereCalled();
    }

    @IsTest
    static void unitHandleFlowCreateAddendumAndSignOtherExceptionNegative() {
        VCC_DASFlowCreateAddendumAndSign.Request dasFlowCreateAddendumAndSignRequest = new VCC_DASFlowCreateAddendumAndSign.Request();
        dasFlowCreateAddendumAndSignRequest.esig = 'test esig';
        dasFlowCreateAddendumAndSignRequest.itemId = 'test itemId';
        dasFlowCreateAddendumAndSignRequest.providerName = 'test providerName';
        dasFlowCreateAddendumAndSignRequest.providerUserId = 'test providerUserId';
        dasFlowCreateAddendumAndSignRequest.recordId = VATEST_IdFactory.get(VCC_Addendum__c.class);
        dasFlowCreateAddendumAndSignRequest.siteCode = '123';
        dasFlowCreateAddendumAndSignRequest.type = 'test type';
        String parserReturnValue = 'test parsed record';
        List<String> signersListReturnValue = new List<String>{ 'some signer' };
        VATEST_Stub parserStub = VCC_DASServicesTest.stubParser(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceParserTest.getMockedMethodParse()
                    .withParameterValues(
                        new List<Object>{ new VCC_Addendum__c(Id = dasFlowCreateAddendumAndSignRequest.recordId) }
                    )
                    .returning(parserReturnValue)
            }
        );
        VATEST_Stub signersServiceStub = VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ dasFlowCreateAddendumAndSignRequest.recordId })
                    .returning((Object) signersListReturnValue)
            }
        );
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq = dasFlowCreateAddendumAndSignRequest.toCreateAddendumAndSignRq();
        VCC_DAS.State dasState = new VCC_DAS.State(
            new VCC_SiteId(dasFlowCreateAddendumAndSignRequest?.siteCode),
            'VAHC',
            dasFlowCreateAddendumAndSignRequest?.recordId
        );
        dasState.endpoint = VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN;
        VATEST_Stub dasServiceApiStub = VCC_DASServicesTest.stubApi(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceApiTest.getMockedMethodCreateAddendumAndSign()
                    .withParameterValues(new List<Object>{ createAddendumAndSignRq, dasState })
                    .throwingException(new IllegalArgumentException('test'))
            }
        );
        Test.startTest();
        try {
            List<VCC_DASFlowConsolidatedEndpointResult> flowResultList = VCC_DASFlowCreateAddendumAndSign.flowCreateAddendumAndSignInstance.handleFlowCreateAddendumAndSign(
                new List<VCC_DASFlowCreateAddendumAndSign.Request>{
                    dasFlowCreateAddendumAndSignRequest.clone(),
                    dasFlowCreateAddendumAndSignRequest.clone()
                }
            );
            Assert.areEqual(2, flowResultList.size(), 'Expected size to be 2 because 2 requests were input');
            //not testing the contents of the flow results because that is tested in VCC_DasFlowConsolidatedEnpointResultTest
        } catch (Exception thrownException) {
            Assert.fail(
                'Expected no exception, instead found ' +
                    thrownException.getTypeName() +
                    '\n' +
                    thrownException.getStackTraceString()
            );
        }
        Test.stopTest();
        dasServiceApiStub.assertAllMockedMethodsWereCalled();
        parserStub.assertAllMockedMethodsWereCalled();
        signersServiceStub.assertAllMockedMethodsWereCalled();
    }
}
