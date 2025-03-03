public with sharing class VCC_HttpService {
    private static Http http = new Http();

    private static Controller serviceController = new Controller();

    public static HttpResponse send(HttpRequest request) {
        serviceController.interceptRequest(request);
        HttpResponse response = serviceController.interceptResponse(serviceController.send(request));
        resetServiceController();
        return response;
    }

    private static void resetServiceController() {
        if (persistIntercept == false) {
            serviceController.intercept = null;
        }

        if (persistOverride == false) {
            serviceController.sendOverride = null;
        }
    }

    public static Boolean persistIntercept = false;

    public static void setIntercept(Intercept intercept) {
        serviceController.intercept = intercept;
    }

    public static Boolean persistOverride = false;

    public static void setOverride(SendOverride sendOverride) {
        serviceController.sendOverride = sendOverride;
    }

    private class Controller {
        public Intercept intercept { get; set; }

        public SendOverride sendOverride { get; set; }

        public HttpRequest interceptRequest(HttpRequest request) {
            if (this.intercept == null) {
                return request;
            }
            return this.intercept.interceptHttpRequest(request);
        }

        public HttpResponse interceptResponse(HttpResponse response) {
            if (this.intercept == null) {
                return response;
            }
            return this.intercept.interceptHttpResponse(response);
        }

        public HttpResponse send(HttpRequest request) {
            if (this.sendOverride == null) {
                return http.send(request);
            }
            return sendOverride.sendHttpRequest(request);
        }
    }

    public interface Intercept {
        HttpResponse interceptHttpResponse(HttpResponse response);
        HttpRequest interceptHttpRequest(HttpRequest request);
    }

    public interface SendOverride {
        HttpResponse sendHttpRequest(HttpRequest request);
    }
}
