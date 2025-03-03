/**
 * @author Booz Allen Hamilton
 * @description Wrapping System.Http in another class so that it can be stubbed/mocked for unit testing.
 */
public with sharing class VCC_DASServiceHttp {
    @TestVisible
    private static final String INVALID_REQUEST_MESSAGE = System.Label.VCC_DAS_HttpService_INVALID_REQUEST_MESSAGE;

    @TestVisible
    private static final String BAD_STATUS_CODE_TEMPLATE = System.Label.VCC_DAS_HttpService_BAD_STATUS_CODE_TEMPLATE;

    private Http http = new Http();

    /**
     * @description Builds and sends the DAS API Request
     * @param requestBody
     * @param dasStateVariables
     * @return `String` body of the response
     */
    public String send(VCC_DASBaseRQ requestBody, VCC_DAS.State dasStateVariables) {
        return send(createPostRequest(requestBody, dasStateVariables?.endpoint, createHeaders(dasStateVariables)));
    }

    @TestVisible
    private String send(HttpRequest httpRequest) {
        try {
            VCC_DAS.SERVICES.LOGGER.debug(httpRequest.getBody());
            HttpResponse httpResponse = this.http.send(httpRequest);
            VCC_DAS.SERVICES.LOGGER.debug(String.valueOf(httpResponse.getStatusCode()));
            VCC_DAS.SERVICES.LOGGER.debug(httpResponse.getBody());
            validateResponse(httpResponse);
            return httpResponse.getBody();
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new RemoteServiceException(e);
        }
    }

    @TestVisible
    private HttpRequest createPostRequest(
        VCC_DASBaseRQ requestBody,
        VCC_DAS.Endpoint endpoint,
        List<VCC_HttpHeaderField> httpHeaders
    ) {
        try {
            validateBody(requestBody);
            HttpRequest req = new HttpRequest();
            req.setMethod('POST');
            req.setEndpoint(VCC_DAS.SERVICES.ENDPOINT.getEndpoint(endpoint));
            req.setHeader('Content-Type', 'application/json');
            req.setBody(JSON.serialize(requestBody));
            req.setTimeout(120000);
            for (VCC_HttpHeaderField headerField : httpHeaders) {
                VCC_DAS.SERVICES.LOGGER.debug(headerField.toString());
                headerField.addTo(req);
            }
            return req;
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new CreateRequestException(e);
        }
    }

    @TestVisible
    private List<VCC_HttpHeaderField> createHeaders(VCC_DAS.State dasStateVariables) {
        VCC_TransactionId transactionId = new VCC_TransactionId(
            dasStateVariables?.endpoint,
            dasStateVariables?.recordId
        );
        return new List<VCC_HttpHeaderField>{
            new VCC_HttpHeaderCallingAppName(dasStateVariables?.callingAppName),
            new VCC_HttpHeaderSiteId(dasStateVariables?.siteId),
            new VCC_HttpHeaderConversationId(transactionId),
            new VCC_HttpHeaderB3(transactionId)
        };
    }

    @TestVisible
    private void validateResponse(HttpResponse httpResponse) {
        if (httpResponse.getStatusCode() != 200) {
            raiseStatusCodeException(httpResponse);
        }
    }

    @TestVisible
    private void validateBody(VCC_DASBaseRQ baseRq) {
        if (baseRq == null || baseRq.isValid() == false) {
            VCC_DAS.SERVICES.LOGGER.debug(JSON.serialize(baseRq));
            throw new InvalidRequestException(INVALID_REQUEST_MESSAGE);
        }
    }

    @TestVisible
    private void raiseStatusCodeException(HttpResponse httpResponse) {
        Map<String, Object> obj;
        try {
            obj = (Map<String, Object>) JSON.deserializeUntyped(httpResponse.getBody());
        } catch (Exception e) {
            VCC_DAS.SERVICES.LOGGER.debug('Response body is non-json.');
        }
        StatusCodeException statusCodeException = new StatusCodeException(
            String.format(
                BAD_STATUS_CODE_TEMPLATE,
                new List<String>{
                    (String.isBlank(httpResponse.getStatus())) ? '' : httpResponse.getStatus(),
                    (obj == null || !obj.containsKey('message'))
                        ? httpResponse.getBody()
                        : ((String) obj.get('message')),
                    String.valueOf(httpResponse.getStatusCode())
                }
            )
        );
        statusCodeException.status = httpResponse.getStatus();
        statusCodeException.statusCode = httpResponse.getStatusCode();
        statusCodeException.responseBody = httpResponse.getBody();
        throw statusCodeException;
    }

    /**
     * @description Exception thrown when the `HttpResponse` status code is not 200
     */
    public class StatusCodeException extends VCC_DASException {
        public String status;
        public Integer statusCode;
        public String responseBody;
        /**
         * @description    Constructor sets exception properties
         * @param exceptionMessage String
         * @param response HttpResponse
         */
        public StatusCodeException(String exceptionMessage, HttpResponse response) {
            super(exceptionMessage);
            this.status = response.getStatus();
            this.statusCode = response.getStatusCode();
            this.responseBody = response.getBody();
        }
    }

    /**
     * @description a generic RemoteServiceException thrown if an exception occcurs in the send(HttpRequest) method
     * that is not a StatusCodeException
     */
    public class RemoteServiceException extends VCC_DASException {
    }

    /**
     * @description a CreateRequestException
     */
    public class CreateRequestException extends VCC_DASException {
    }

    /**
     * @description an InvalidRequestException
     */
    public class InvalidRequestException extends VCC_DASException {
    }
}
