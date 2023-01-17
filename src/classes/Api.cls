public abstract with sharing class Api {
    protected ICalloutClient calloutClient;
    protected String ROOT_PATH;

    public Api(ICalloutClient calloutClient, String endpointDomain) {
        this.calloutClient = calloutClient;
        this.ROOT_PATH = endpointDomain + this.getApiPath();
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

    protected virtual String getEndpointPath(String resource) {
        return this.ROOT_PATH + resource;
    }
} 