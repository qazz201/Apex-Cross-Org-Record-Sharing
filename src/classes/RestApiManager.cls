public with sharing class RestApiManager {
    private final ICallout calloutClient;
    // private String endpointDomain;

    public RestApiManager(ICallout calloutClient) {
        this.calloutClient = calloutClient;
        //  this.endpointDomain = endpointDomain;
    }

    public ToolingApiProvider toolingApi() {
        return new ToolingApiProvider(this.calloutClient);
    }

    public QueryApiProvider queryApi() {
        return new QueryApiProvider(this.calloutClient);
    }
}