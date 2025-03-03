@IsTest
public with sharing class VCC_DASServiceHttpTest {
    /**
     * @description for testing
     */
    public class TestRQ extends VCC_DASBaseRQ {
        private Boolean isValid = true;

        @TestVisible
        private TestRQ() {
            return;
        }

        @TestVisible
        private TestRQ(Boolean isValid) {
            this.isValid = isValid;
        }

        public override Boolean isValid() {
            return this.isValid;
        }
    }

    // testing VCC_DASServiceHttp from the bottom up

    @IsTest
    static void unitStatusCodeExceptionConstructorPositive() {
        Test.startTest();
        Assert.isInstanceOfType(
            new VCC_DASServiceHttp.StatusCodeException('Exception message', new HttpResponse()),
            VCC_DASServiceHttp.StatusCodeException.class,
            'Expected constructor to produce an instance of VCC_DASServiceHttp.StatusCodeException.class'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitStatusCodeExceptionConstructorNegative() {
        Test.startTest();
        try {
            Assert.isInstanceOfType(
                new VCC_DASServiceHttp.StatusCodeException((String) null, (HttpResponse) null),
                VCC_DASServiceHttp.StatusCodeException.class,
                'Expected constructor to produce an instance of VCC_DASServiceHttp.StatusCodeException.class'
            );
            Assert.fail('Expected a null pointer exception.');
        } catch (NullPointerException nullPointerException) {
            Assert.isTrue(true, 'Expected exception caught. Test passes');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitRaiseStatusCodeExceptionPositive() {
        String responseBody = JSON.serialize(new Map<String, Object>{ 'message' => 'test' });
        String status = 'OK';
        Integer statusCode = 200;

        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setBody(responseBody);
        httpResponse.setStatus(status);
        httpResponse.setStatusCode(statusCode);

        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).raiseStatusCodeException(httpResponse);
            Assert.fail('Expected method "raiseStatusCodeException" to throw a StatusCodeException');
        } catch (VCC_DASServiceHttp.StatusCodeException statusCodeException) {
            Assert.areEqual(
                status,
                statusCodeException.status,
                'Expected attribute "status" from the StatusCodeException to match the "status attribute from the HttpResponse'
            );
            Assert.areEqual(
                statusCode,
                statusCodeException.statusCode,
                'Expected attribute "status" from the StatusCodeException to match the "status attribute from the HttpResponse'
            );
            Assert.areEqual(
                responseBody,
                statusCodeException.responseBody,
                'Expected attribute "status" from the StatusCodeException to match the "status attribute from the HttpResponse'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitRaiseStatusCodeExceptionNegative() {
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).raiseStatusCodeException((HttpResponse) null);
            Assert.fail('Expected a NullPointerException');
        } catch (NullPointerException nullPointerException) {
            Assert.isTrue(true, 'Expected exception caught. Test passes');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateBodyPositive() {
        TestRQ testRq = new TestRQ(true);
        Test.startTest();
        (new VCC_DASServiceHttp()).validateBody(testRq);
        Assert.isTrue(true, 'No exception thrown. Test passes. Adding this assert to satisfy static code analysis.');
        Test.stopTest();
    }

    @IsTest
    static void unitValidateBodyInvalidNegative() {
        TestRQ testRq = new TestRQ(false);
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).validateBody(testRq);
            Assert.fail('Expected a VCC_DASServiceHttp.InvalidRequestException');
        } catch (VCC_DASServiceHttp.InvalidRequestException invalidRequestException) {
            Assert.isTrue(
                invalidRequestException.getMessage().contains(VCC_DASServiceHttp.INVALID_REQUEST_MESSAGE),
                'Expected exception message to contain the string stored at VCC_DASServiceHttp.INVALID_REQUEST_MESSAGE '
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateBodyNullNegative() {
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).validateBody(null);
            Assert.fail('Expected a VCC_DASServiceHttp.InvalidRequestException');
        } catch (VCC_DASServiceHttp.InvalidRequestException invalidRequestException) {
            Assert.isTrue(
                invalidRequestException.getMessage().contains(VCC_DASServiceHttp.INVALID_REQUEST_MESSAGE),
                'Expected exception message to contain the string stored at VCC_DASServiceHttp.INVALID_REQUEST_MESSAGE '
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateResponsePositive() {
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(200);
        Test.startTest();
        (new VCC_DASServiceHttp()).validateResponse(httpResponse);
        Assert.isTrue(true, 'No exception thrown. Test passes.');
        Test.stopTest();
    }

    @IsTest
    static void unitValidateResponseStatusCode400Negative() {
        HttpResponse httpResponse = new HttpResponse();
        httpResponse.setStatusCode(400);
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).validateResponse(httpResponse);
            Assert.fail('Expected a VCC_DASServiceHttp.StatusCodeException');
        } catch (VCC_DASServiceHttp.StatusCodeException statusCodeException) {
            Assert.isTrue(true, 'No exception thrown. Test passes.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateResponseNullNegative() {
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).validateResponse((HttpResponse) null);
            Assert.fail('Expected a VCC_DASServiceHttp.StatusCodeException');
        } catch (NullPointerException nullPointerException) {
            Assert.isTrue(true, 'No exception thrown. Test passes.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitCreateHeadersPositive() {
        VCC_SiteId siteId = new VCC_SiteId('123');
        String callingAppName = 'VAHC';
        Id recordId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_DAS.State dasStateVariables = new VCC_DAS.State(siteId, callingAppName, recordId);
        dasStateVariables.endpoint = VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN;

        Test.startTest();
        List<VCC_HttpHeaderField> headers = (new VCC_DASServiceHttp()).createHeaders(dasStateVariables);
        Test.stopTest();
        Assert.isTrue(headers.size() == 4, 'Expected four headers');
        Boolean hasCallingAppNameHeader = false;
        Boolean hasSiteIdHeader = false;
        Boolean hasConversationIdHeader = false;
        Boolean hasB3Header = false;
        for (VCC_HttpHeaderField headerField : headers) {
            if (headerField.name == VCC_HttpHeaderCallingAppName.VCC_HTTP_HEADER_CALLING_APP_NAME) {
                hasCallingAppNameHeader = true;
                continue;
            }
            if (headerField.name == VCC_HttpHeaderConversationId.HEADER_NAME) {
                hasConversationIdHeader = true;
                continue;
            }
            if (headerField.name == VCC_HttpHeaderSiteId.HEADER_NAME) {
                hasSiteIdHeader = true;
                continue;
            }
            if (headerField.name == VCC_HttpHeaderB3.VCC_HEADER_NAME_B3) {
                hasB3Header = true;
                continue;
            }
        }
        Assert.isTrue(hasCallingAppNameHeader, 'Expected conversation id header.');
        Assert.isTrue(hasSiteIdHeader, 'Expected conversation id header.');
        Assert.isTrue(hasConversationIdHeader, 'Expected conversation id header.');
        Assert.isTrue(hasB3Header, 'Expected conversation id header.');
    }

    @IsTest
    static void unitCreatePostRequestPositive() {
        VCC_DAS.Endpoint endpoint = VCC_DAS.Endpoint.SAVE_NOTE_AND_ENCOUNTER;
        TestRQ testRq = new TestRQ();
        VCC_HttpHeaderField testHeader = new VCC_HttpHeaderSiteId(new VCC_SiteId('123'));
        String getEndpointReturnValue = 'hi';
        VCC_DASServicesTest.stubEndpoint(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceEndpointTest.getMockedMethodGetEndpoint()
                    .withParameterValues(new List<Object>{ endpoint })
                    .returning(getEndpointReturnValue)
            }
        );
        Test.startTest();
        HttpRequest generatedRequest = (new VCC_DASServiceHttp())
            .createPostRequest(testRq, endpoint, new List<VCC_HttpHeaderField>{ testHeader });
        Assert.areEqual(
            testHeader.value,
            generatedRequest.getHeader(testHeader.name),
            'Expected to find VCC_HttpHeader "testHeader" on the HttpRequest'
        );
        Assert.areEqual(generatedRequest.getMethod(), 'POST', 'Expected HttpRequest method to be "POST"');
        Assert.areEqual(
            JSON.serialize(testRq),
            generatedRequest.getBody(),
            'Expected body of the HttpRequest to be the "testRq" serialized.'
        );
        Assert.areEqual(
            getEndpointReturnValue,
            generatedRequest.getEndpoint(),
            'Expected endpoint to be the stubbed value stored in "getEndpointReturnValue"'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitCreatePostRequestBadRQNegative() {
        TestRQ testRq = new TestRQ(false);
        VCC_DASServicesTest.stubEndpoint(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceEndpointTest.getMockedMethodGetEndpoint()
                    .withParameterValues(new List<Object>{})
                    .throwingException() // method shouldn't be called so this exception will not be thrown
            }
        );
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).createPostRequest(testRq, null, new List<VCC_HttpHeaderField>{});
            Assert.fail('Expected an InvalidRequestException');
        } catch (VCC_DASServiceHttp.InvalidRequestException invalidRequestException) {
            Assert.isTrue(true, 'Correct exception was caught.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitCreatePostRequestNullRQNegative() {
        VCC_DASServicesTest.stubEndpoint(
            new List<VATEST_MockedMethod>{
                VCC_DASServiceEndpointTest.getMockedMethodGetEndpoint()
                    .withParameterValues(new List<Object>{})
                    .throwingException() // method shouldn't be called so this exception will not be thrown
            }
        );
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).createPostRequest(null, null, new List<VCC_HttpHeaderField>{});
            Assert.fail('Expected an InvalidRequestException');
        } catch (VCC_DASServiceHttp.InvalidRequestException invalidRequestException) {
            Assert.isTrue(true, 'Correct exception was caught.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSendHttpRequestPositive() {
        StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
        calloutMock.setStaticResource('VCC_DasCreateAddendumSignSuccess');
        calloutMock.setStatusCode(200);
        HttpRequest httpRequest = new HttpRequest();

        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        Assert.isNotNull((new VCC_DASServiceHttp()).send(httpRequest), 'Expected a non-null response');
        Test.stopTest();
    }

    @IsTest
    static void unitSendHttpRequestNegative() {
        StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
        calloutMock.setStaticResource('VCC_DasCreateAddendumSignSuccess');
        calloutMock.setStatusCode(400);
        HttpRequest httpRequest = new HttpRequest();

        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        try {
            (new VCC_DASServiceHttp()).send(httpRequest);
            Assert.fail('Expected a StatusCodeException');
        } catch (VCC_DASServiceHttp.StatusCodeException statusCodeException) {
            Assert.isTrue(true, 'Exception thrown. Test passes.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSendBaseRqAndDasStatePositive() {
        //set test values
        VCC_SiteId testSiteId = new VCC_SiteId('123');
        String testAppName = 'APP';
        Id dummyProgressNoteId = VATEST_IdFactory.get(VCC_Progress_Note__c.class);
        VCC_DAS.State dasState = new VCC_DAS.State(testSiteId, testAppName, dummyProgressNoteId);
        dasState.endpoint = VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN;
        TestRQ testRq = new TestRQ(true);

        // callout mock setup
        StaticResourceCalloutMock calloutMock = new StaticResourceCalloutMock();
        calloutMock.setStaticResource('VCC_DasCreateAddendumSignSuccess');
        calloutMock.setStatusCode(200);

        Test.setMock(HttpCalloutMock.class, calloutMock);
        Test.startTest();
        Assert.isNotNull((new VCC_DASServiceHttp()).send(testRq, dasState), 'Expected a non-null response');
        Test.stopTest();
    }
}
