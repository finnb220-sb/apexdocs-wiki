public with sharing virtual class VCC_MPI_HTTP {
    public static HttpRequest createRequest(String httpRequestMethod, String requestBody, String endpointMD) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', endpointMD));
            request.setMethod(httpRequestMethod);
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);
            request.setBody(requestBody);
            return request;
        } catch (Exception e) {
            VCC_LogService.log('VCC_MPI_HTTP.createRequest Exception', VCC_LogService.VCC_LogType.ERROR, e);
            throw new MPIException(e.getMessage());
        }
    }

    public static HttpResponse dispatchRequest(HttpRequest request) {
        try {
            return VCC_HttpService.send(request);
        } catch (Exception e) {
            VCC_LogService.log('VCC_MPI_HTTP.dispatchRequest Exception', VCC_LogService.VCC_LogType.ERROR, e);
            throw new MPIException(e.getMessage());
        }
    }

    public class MPIException extends Exception {
    }
}
