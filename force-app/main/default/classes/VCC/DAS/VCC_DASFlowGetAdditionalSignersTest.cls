/**
 * @description Test class.
 * @author Booz Allen
 * @see `VCC_DASFlowGetAdditionalSigners`
 */
@isTest
private class VCC_DASFlowGetAdditionalSignersTest {
    @TestVisible
    private static VATEST_Stub stubFlowGetAdditionalSignersInstance(List<VATEST_MockedMethod> mockedMethodList) {
        VATEST_Stub flowGetAdditionalSignersInstanceStub = new VATEST_Stub(
            VCC_DASFlowGetAdditionalSigners.class,
            mockedMethodList
        );
        VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance = (VCC_DASFlowGetAdditionalSigners) flowGetAdditionalSignersInstanceStub.createStub();
        return flowGetAdditionalSignersInstanceStub;
    }

    @TestVisible
    private static VATEST_MockedMethod getMockedMethodHandleFlowGetAdditionalSigners() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'handleFlowGetAdditionalSigners',
                new List<System.Type>{ List<VCC_DASFlowGetAdditionalSigners.Request>.class }
            )
        );
    }

    @IsTest
    static void unitGetAdditionalSignersPositive() {
        VCC_DASFlowGetAdditionalSigners.Request flowGetAdditionalSignersRequest = new VCC_DASFlowGetAdditionalSigners.Request();
        flowGetAdditionalSignersRequest.providerLoginSiteCode = '123';
        VCC_DASFlowGetAdditionalSigners.Result flowGetAdditionalSignersResult = new VCC_DASFlowGetAdditionalSigners.Result(
            new VCC_DASGetAdditionalSignersRS()
        );
        VATEST_MockedMethod mockedMethodHandleFlowGetAdditionalSigners = getMockedMethodHandleFlowGetAdditionalSigners()
            .withParameterValues(
                new List<Object>{ new List<VCC_DASFlowGetAdditionalSigners.Request>{ flowGetAdditionalSignersRequest } }
            )
            .returning(new List<VCC_DASFlowGetAdditionalSigners.Result>{ flowGetAdditionalSignersResult });
        stubFlowGetAdditionalSignersInstance(
            new List<VATEST_MockedMethod>{ mockedMethodHandleFlowGetAdditionalSigners }
        );
        Test.startTest();
        Assert.areEqual(
            new List<VCC_DASFlowGetAdditionalSigners.Result>{ flowGetAdditionalSignersResult },
            VCC_DASFlowGetAdditionalSigners.getAdditionalSigners(
                new List<VCC_DASFlowGetAdditionalSigners.Request>{ flowGetAdditionalSignersRequest }
            ),
            'Expected stubbed value to be returned'
        );
        mockedMethodHandleFlowGetAdditionalSigners.assertMockedMethodWasCalled();
        Test.stopTest();
    }

    @IsTest
    static void unitResultConstructorPositive() {
        Test.startTest();
        VCC_DASGetAdditionalSignersRS getAdditionalSignersRs = new VCC_DASGetAdditionalSignersRS();
        VCC_DASRSCommon.TaggedText taggedText = new VCC_DASRSCommon.TaggedText();
        taggedText.text = '1234';
        getAdditionalSignersRs.taggedTextArray.results.taggedText.add(taggedText);
        Assert.isNotNull(
            new VCC_DASFlowGetAdditionalSigners.Result(getAdditionalSignersRs),
            'Expecting Result class to construct'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitRequestConstructorPositive() {
        Test.startTest();
        VCC_DASFlowGetAdditionalSigners.Request flowGetAdditionalSignersRequest = new VCC_DASFlowGetAdditionalSigners.Request();
        flowGetAdditionalSignersRequest.supplementalParameters = new List<String>{ '123456' };
        Assert.isNotNull(flowGetAdditionalSignersRequest, 'Expected non-null values');
        Test.stopTest();
    }

    @IsTest
    static void unitGetAdditionalSignersDasExceptionNegative() {
        VCC_DASFlowGetAdditionalSigners.Request flowGetAdditionalSignersRequest = new VCC_DASFlowGetAdditionalSigners.Request();
        flowGetAdditionalSignersRequest.providerLoginSiteCode = '123';
        VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ flowGetAdditionalSignersRequest.recordId })
                    .throwingException(new VCC_DASServiceApi.ApiServiceException('test'))
            }
        );

        Test.startTest();
        try {
            VCC_DASFlowGetAdditionalSigners.getAdditionalSigners(
                new List<VCC_DASFlowGetAdditionalSigners.Request>{ flowGetAdditionalSignersRequest }
            );
            Assert.fail('Expected a VCC_DASException.');
        } catch (VCC_DASException thrownDasException) {
            Assert.isTrue(thrownDasException.getMessage().contains('test'), 'Expected correct exception message.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitGetAdditionalSignersOtherExceptionNegative() {
        VCC_DASFlowGetAdditionalSigners.Request flowGetAdditionalSignersRequest = new VCC_DASFlowGetAdditionalSigners.Request();
        flowGetAdditionalSignersRequest.providerLoginSiteCode = '123';
        flowGetAdditionalSignersRequest.recordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ flowGetAdditionalSignersRequest.recordId })
                    .throwingException(new IllegalArgumentException('test'))
            }
        );
        Test.startTest();
        try {
            VCC_DASFlowGetAdditionalSigners.getAdditionalSigners(
                new List<VCC_DASFlowGetAdditionalSigners.Request>{ flowGetAdditionalSignersRequest }
            );
            Assert.fail('Expected a VCC_DASFlowGetAdditionalSigners.FlowGetAdditionalSignersException.');
        } catch (VCC_DASFlowGetAdditionalSigners.FlowGetAdditionalSignersException thrownFlowGetAdditionalSignersException) {
            Assert.isTrue(true, 'Correct exception was caught so the test passes.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitGetAdditionalSignersNoSignersNegative() {
        VCC_DASFlowGetAdditionalSigners.Request flowGetAdditionalSignersRequest = new VCC_DASFlowGetAdditionalSigners.Request();
        flowGetAdditionalSignersRequest.providerLoginSiteCode = '123';
        flowGetAdditionalSignersRequest.recordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_SignersServiceTest.stubSignersService(
            new List<VATEST_MockedMethod>{
                VCC_SignersServiceTest.getMockedMethodGetSignerDuzListForCallout()
                    .withParameterValues(new List<Object>{ flowGetAdditionalSignersRequest.recordId })
                    .returning((Object) new List<String>())
            }
        );
        VATEST_MockedMethod mockedMethodGetAdditionalSigners = VCC_DASServiceApiTest.getMockedMethodGetAdditionalSigners()
            .withParameterValues(new List<Object>{})
            .throwingException(); // throwing exception to fail the test because this method should never be called
        VCC_DASServicesTest.stubApi(new List<VATEST_MockedMethod>{ mockedMethodGetAdditionalSigners });

        Test.startTest();
        VCC_DASFlowGetAdditionalSigners.Result flowGetAdditionalSignersResult = VCC_DASFlowGetAdditionalSigners.getAdditionalSigners(
            new List<VCC_DASFlowGetAdditionalSigners.Request>{ flowGetAdditionalSignersRequest }
        )[0];
        Assert.isNotNull(flowGetAdditionalSignersResult, 'Expected non-null result.');
        Assert.isTrue(
            flowGetAdditionalSignersResult.addedSigners.isEmpty(),
            'Expected to find an empty list of signers added because no signers were found on the record'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitValidateRequestListNullNegative() {
        Test.startTest();
        try {
            VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance.validateInvocableRequestList(
                (List<VCC_DASFlowGetAdditionalSigners.Request>) null
            );
            Assert.fail('Expected an `IllegalArgumentException`');
        } catch (IllegalArgumentException thrownIllegalArgmentException) {
            Assert.areEqual(
                VCC_DASFlowGetAdditionalSigners.NULL_OR_EMPTY_REQUEST_LIST_EXCEPTION_MESSAGE,
                thrownIllegalArgmentException.getMessage(),
                'Expected exception message to match pre-defined string'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateRequestListEmptyNegative() {
        Test.startTest();
        try {
            VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance.validateInvocableRequestList(
                new List<VCC_DASFlowGetAdditionalSigners.Request>{}
            );
            Assert.fail('Expected an `IllegalArgumentException`');
        } catch (IllegalArgumentException thrownIllegalArgmentException) {
            Assert.areEqual(
                VCC_DASFlowGetAdditionalSigners.NULL_OR_EMPTY_REQUEST_LIST_EXCEPTION_MESSAGE,
                thrownIllegalArgmentException.getMessage(),
                'Expected exception message to match pre-defined string'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateRequestListMoreThanOneNegative() {
        Test.startTest();
        try {
            VCC_DASFlowGetAdditionalSigners.flowGetAdditionalSignersInstance.validateInvocableRequestList(
                new List<VCC_DASFlowGetAdditionalSigners.Request>{
                    new VCC_DASFlowGetAdditionalSigners.Request(),
                    new VCC_DASFlowGetAdditionalSigners.Request()
                }
            );
            Assert.fail('Expected an `IllegalArgumentException`');
        } catch (IllegalArgumentException thrownIllegalArgmentException) {
            Assert.areEqual(
                VCC_DASFlowGetAdditionalSigners.NOT_BULKIFIED_EXCEPTION_MESSAGE,
                thrownIllegalArgmentException.getMessage(),
                'Expected exception message to match pre-defined string'
            );
        }
        Test.stopTest();
    }
}
