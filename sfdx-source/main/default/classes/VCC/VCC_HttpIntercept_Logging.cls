public with sharing class VCC_HttpIntercept_Logging implements VCC_HttpService.Intercept {
    public static void logNext() {
        VCC_HttpService.setIntercept(new VCC_HttpIntercept_Logging());
    }

    public static void logAll() {
        VCC_HttpService.persistIntercept = true;
        VCC_HttpService.setIntercept(new VCC_HttpIntercept_Logging());
    }

    public static HttpRequest logHttpRequest(HttpRequest request) {
        System.debug(LoggingLevel.DEBUG, request.getEndpoint());
        System.debug(LoggingLevel.DEBUG, request.getBody());
        return request;
    }

    public static HttpResponse logHttpResponse(HttpResponse response) {
        System.debug(LoggingLevel.DEBUG, response.getStatusCode());
        System.debug(LoggingLevel.DEBUG, response.getBody());
        return response;
    }

    public HttpRequest interceptHttpRequest(HttpRequest request) {
        return logHttpRequest(request);
    }

    public HttpResponse interceptHttpResponse(HttpResponse response) {
        return logHttpResponse(response);
    }
}
