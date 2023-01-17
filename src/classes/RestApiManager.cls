public with sharing class RestApiManager {
    private final ICallout calloutClient = new CalloutClient();
    private String endpointDomain;

    public RestApiManager(String endpointDomain) {
        this.endpointDomain = endpointDomain;
    }

    public ToolingApiProvider toolingApi() {
        return new ToolingApiProvider(this.calloutClient, this.endpointDomain);
    }

    public QueryApiProvider queryApi() {
        return new QueryApiProvider(this.calloutClient, this.endpointDomain);
    }
}