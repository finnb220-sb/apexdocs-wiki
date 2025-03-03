/**
 * Author:Jaren Yach
 *  Created Date 05/13/2022
 *  Purpose: This class is used for mocking multiple http callouts
 */
@IsTest
public class MultiCalloutRequestMock implements HttpCalloutMock {
    private static Integer calloutIndex = 0;
    Map<String, HttpCalloutMock> requests;
    Map<Integer, HttpCalloutMock> requestsByIndex;

    public MultiCalloutRequestMock(Map<String, HttpCalloutMock> requests) {
        this.requests = requests;
        this.requestsByIndex = new Map<Integer, HttpCalloutMock>();
        for (Integer i = 0; i < requests.size(); i++) {
            requestsByIndex.put(i, this.requests.values()[i]);
        }
    }

    public HttpResponse respond(HttpRequest req) {
        HttpCalloutMock mock = requests.get(req.getEndpoint());
        //Try getting mock by the index of callouts
        if (mock == null) {
            if (requestsByIndex.containsKey(calloutIndex)) {
                mock = requestsByIndex.get(calloutIndex);
            }
        }
        calloutIndex++;
        if (mock != null) {
            return mock.respond(req);
        } else {
            throw new CalloutException('HTTP callout not supported for test methods');
        }
    }

    public void addRequestMock(String url, HttpCalloutMock mock) {
        requests.put(url, mock);
    }
}
