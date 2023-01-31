public abstract with sharing class Api {
    protected ICallout calloutClient;
    protected String endpointApiUrl;

    public Api(ICallout calloutClient) {
        this.calloutClient = calloutClient;
        this.endpointApiUrl = this.calloutClient.getEndpoint() + this.getApiPath();
    }

    protected abstract String getApiPath();

    protected virtual HttpResponse executeCallout(String resourceEndpoint) {
        HttpResponse response;
        try {
            this.calloutClient.setEndpoint(resourceEndpoint);
            response = this.calloutClient.get();
        } catch (Exception ex) {
            return response;
        }

        return response;
    }

    protected virtual String getEndpointPath(String apiResource) {
        return this.endpointApiUrl + apiResource;
    }

    public class ApiException extends Exception {
    }
//    public class ApiException extends Exception {
//        public Integer statusCode;
//        public String message;
//
//        public ApiException(Integer statusCode, String message) {
//            this.statusCode = statusCode;
//            this.message = message;
//        }
//
//        public override String getMessage() {
//            return this.message;
//        }
//    }
} 