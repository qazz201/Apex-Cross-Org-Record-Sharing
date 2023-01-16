public with sharing class RestApiManager {
    private final ICalloutClient calloutClient = new CalloutClient();
    private String endpointDomain;

    public RestApiManager(String endpointDomain) {
        this.endpointDomain = endpointDomain;
    }

    public ToolingApi toolingApi() {
        return new ToolingApi(this.calloutClient, this.endpointDomain);
    }

    public QueryApi queryApi() {
        return new QueryApi(this.calloutClient, this.endpointDomain);
    }
}