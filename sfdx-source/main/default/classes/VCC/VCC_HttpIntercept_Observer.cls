public with sharing class VCC_HttpIntercept_Observer implements VCC_HttpService.Intercept {
    public static void observeNext() {
        VCC_HttpService.setIntercept(new VCC_HttpIntercept_Observer());
    }

    public static void observeAll() {
        VCC_HttpService.persistIntercept = true;
        VCC_HttpService.setIntercept(new VCC_HttpIntercept_Observer());
    }

    public static HttpData getData() {
        return httpData;
    }

    private static HttpData httpData = new HttpData();

    public HttpRequest interceptHttpRequest(HttpRequest request) {
        if (request == null) {
            return null;
        }
        httpData = new HttpData();
        httpData.requestMethod = request.getMethod();
        httpData.requestIsCompressed = request.getCompressed();
        httpData.requestEndpoint = request.getEndpoint();
        httpData.requestBody = request.getBody();
        httpData.timeSent = System.now().getTime();
        return request;
    }

    public HttpResponse interceptHttpResponse(HttpResponse response) {
        if (response == null) {
            return null;
        }
        httpData.responseStatusCode = response.getStatusCode();
        httpData.responseStatus = response.getStatus();
        httpData.responseBody = response.getBody();
        httpData.timeReceived = System.now().getTime();
        return response;
    }

    public class HttpData {
        //request

        public String requestMethod;

        public Boolean requestIsCompressed;

        public String requestEndpoint;

        public String requestBody;

        //response

        public Integer responseStatusCode;

        public String responseStatus;

        public String responseBody;

        //stats

        public Long timeSent;

        public Long timeReceived;
    }
}
