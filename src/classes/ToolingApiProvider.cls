public with sharing class ToolingApiProvider implements IToolingApi {
    private ToolingApiService toolingApiService;

    public ToolingApiProvider(ICallout calloutClient, String endpointDomain) {
        this.toolingApiService = new ToolingApiService(calloutClient, endpointDomain);
    }

    public List<String> getObjectNames() {
        return this.toolingApiService.getCustomObjectNames();
    }
}