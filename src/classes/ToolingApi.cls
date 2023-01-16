public with sharing class ToolingApi implements IToolingApi {
    private ToolingApiService toolingApiService;

    public ToolingApi(ICalloutClient calloutClient, String endpointDomain) {
        this.toolingApiService = new ToolingApiService(calloutClient, endpointDomain);
    }

    public List<String> getObjectNames() {
        return this.toolingApiService.getCustomObjectNames();
    }
}