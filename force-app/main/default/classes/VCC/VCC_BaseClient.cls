public abstract with sharing class VCC_BaseClient {
    private final String EXCEPTION_TEMPLATE = 'Error {0}: {1}';

    public enum ClientOption {
        TRAINING_MODE,
        DEBUG_MODE
    }

    public enum ResponseType {
        INFORMATIONAL,
        SUCCESSFUL,
        REDIRECTION,
        SERVER_ERROR,
        CLIENT_ERROR,
        UNKNOWN
    }

    public final Set<ClientOption> CLIENT_OPTIONS = new Set<ClientOption>{};

    abstract protected HTTPRequest createHttpRequest(String httpRequestMethod, Object requestBody);

    public String appName { get; set; }

    public String serviceName { get; set; }

    public Callable callback { get; set; }

    protected void setAppName(String appName) {
        this.appName = appName;
    }

    protected void setServiceName(String serviceName) {
        this.serviceName = serviceName;
    }

    protected BaseResponse send(HttpRequest req) {
        if (CLIENT_OPTIONS.contains(ClientOption.DEBUG_MODE)) {
            System.debug(LoggingLevel.DEBUG, req.getBody());
        }

        req.setEndpoint(VCC_EndpointService.getEndpoint(this.appName, this.serviceName));

        HttpResponse res;

        if (CLIENT_OPTIONS.contains(ClientOption.TRAINING_MODE)) {
            res = new HttpResponse();
            res.setBody('Training Mode');
        } else {
            res = VCC_HttpService.send(req);
        }

        if (CLIENT_OPTIONS.contains(ClientOption.DEBUG_MODE)) {
            System.debug(LoggingLevel.DEBUG, res.getBody());
        }

        return new BaseResponse(res, this.serviceName, this.appName);
    }

    public virtual class BaseResponse {
        @AuraEnabled
        public VCC_BaseClient.ResponseType type { get; private set; }

        @AuraEnabled
        public Integer statusCode {
            get;
            set {
                this.type = this.handleStatusCode(value);
                this.statusCode = value;
            }
        }

        @AuraEnabled
        public HttpResponse httpResponse { get; set; }

        @AuraEnabled
        public List<VCC_EndpointService.StatusCodeMetadata> statusCodeMetadata { get; set; }

        @AuraEnabled
        public List<Exception> exceptions { get; set; }

        private VCC_BaseClient.ResponseType handleStatusCode(Integer code) {
            if (code >= 100 && code <= 199) {
                return VCC_BaseClient.ResponseType.INFORMATIONAL;
            } else if (code >= 200 && code <= 299) {
                return VCC_BaseClient.ResponseType.SUCCESSFUL;
            } else if (code >= 300 && code <= 399) {
                return VCC_BaseClient.ResponseType.REDIRECTION;
            } else if (code >= 400 && code <= 499) {
                return VCC_BaseClient.ResponseType.CLIENT_ERROR;
            } else if (code >= 500 && code <= 599) {
                return VCC_BaseClient.ResponseType.SERVER_ERROR;
            }
            return VCC_BaseClient.ResponseType.UNKNOWN;
        }

        public BaseResponse() {
            this.statusCode = 0;
            this.statusCodeMetadata = new List<VCC_EndpointService.StatusCodeMetadata>();
            this.exceptions = new List<Exception>();
        }

        public BaseResponse(HttpResponse res, String serviceName, String appName) {
            this();
            this.statusCode = res.getStatusCode();
            this.httpResponse = res;
            this.statusCodeMetadata = VCC_EndpointService.getStatusCodeMetadata(this.statusCode, serviceName, appName);
        }

        public BaseResponse(BaseResponse res) {
            this();
            this.statusCode = res.statusCode;
            this.statusCodeMetadata = res.statusCodeMetadata;
        }
    }

    public VCC_BaseClient() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_BaseClient(Set<VCC_BaseClient.ClientOption> options) {
        this.CLIENT_OPTIONS.addAll(options);
    }
    protected void handleStatusCode(BaseResponse baseResponse) {
        for (VCC_EndpointService.StatusCodeMetadata scm : baseResponse.statusCodeMetadata) {
            if (scm.type == 'EXCEPTION') {
                String message = scm.message + ' ====> ' + baseResponse.httpResponse.getBody().replace('{', '').replace('}', '');

                Logger.info('EXCEPTION MESSAGE' + scm.statusCode + message);
                Logger.saveLog();
                throw new HttpStatusCodeException(String.format(EXCEPTION_TEMPLATE, new List<String>{ String.valueOf(scm.statusCode), message }));
            }
        }
    }
    class HttpStatusCodeException extends Exception {
    }
}
