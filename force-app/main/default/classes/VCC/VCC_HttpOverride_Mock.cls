public with sharing class VCC_HttpOverride_Mock implements VCC_HttpService.SendOverride {
    private VCC_HttpOverride_Mock(HttpResponse response) {
        this.mockResponse = response;
    }

    private HttpResponse mockResponse { get; set; }

    public static void mockNext(HttpResponse response) {
        VCC_HttpService.setOverride(new VCC_HttpOverride_Mock(response));
    }

    public static void mockAll(HttpResponse response) {
        VCC_HttpService.persistOverride = true;
        VCC_HttpService.setOverride(new VCC_HttpOverride_Mock(response));
    }

    public static void clearMock() {
        VCC_HttpService.setOverride(null);
    }

    public HttpResponse sendHttpRequest(HttpRequest request) {
        return this.mockResponse;
    }
}
