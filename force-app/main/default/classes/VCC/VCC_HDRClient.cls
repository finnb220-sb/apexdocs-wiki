public with sharing class VCC_HDRClient {
    @TestVisible
    private static Boolean bypassCallout = false;

    public class HDRClientException extends Exception {
    }

    @SuppressWarnings('PMD.EmptyStatementBlock')
    public VCC_HDRClient() {
    }

    /**
     * @description
     */

    public VCC_BridgDemographicsRS getDemographicsBridg(VCC_BridgRequest rq) {
        if (!bypassCallout) {
            return VCC_BridgDemographicsRS.parseJSON(callBridg(rq, 'vccBridgDemographics').getBody());
        }

        return null;
    }

    /**
     * @description Callout to DIVA remote service
     * @param rq Request
     * @param serviceName Name of vccEndpoint Custom MD record for endpoint utility
     * @return  `HTTP` Response
     * @exception 'HDRClientException'
     */

    @TestVisible
    public static HttpResponse callBridg(VCC_BridgRequest rq, String serviceName) {
        HttpRequest httpRequest = new HttpRequest();
        httpRequest.setEndpoint(VCC_EndpointUtility.getEndpoint('Bridg', serviceName));
        httpRequest.setHeader('Accept', 'application/json');
        httpRequest.setHeader('Content-Type', 'application/json; charset=UTF-8');
        httpRequest.setHeader('apiKey', '{!$Credential.password}');
        httpRequest.setMethod('POST'); // Will these endponts always be POSTs?
        httpRequest.setBody(JSON.serialize(rq));
        httpRequest.setTimeout(120000); // TODO: this needs to be in custom md

        HttpResponse res = new Http().send(httpRequest);

        switch on handleStatusCode(res.getStatusCode()) {
            when SUCCESS {
                return res;
            }
            when BAD_REQUEST {
                throw new HDRClientException(res.getBody());
            }
            when SERVER_ERROR {
                throw new HDRClientException(res.getBody());
            }
            when else {
                throw new HDRClientException('HDR Client has thrown an exception');
            }
        }
    }

    static VCC_Enum.VCC_HTTPStatusEnum handleStatusCode(Integer statusCode) {
        if (statusCode >= 200 && statusCode <= 299) {
            return VCC_Enum.VCC_HTTPStatusEnum.SUCCESS;
        }

        if (statusCode >= 400 && statusCode <= 499) {
            return VCC_Enum.VCC_HTTPStatusEnum.BAD_REQUEST;
        }

        if (statusCode >= 500 && statusCode <= 599) {
            return VCC_Enum.VCC_HTTPStatusEnum.SERVER_ERROR;
        }

        return VCC_Enum.VCC_HTTPStatusEnum.UNKNOWN;
    }
}
