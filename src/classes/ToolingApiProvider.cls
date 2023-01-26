public with sharing class ToolingApiProvider implements IToolingApi {
    private ToolingApiService toolingApiService;

    public ToolingApiProvider(ICallout calloutClient) {
        this.toolingApiService = new ToolingApiService(calloutClient);
    }

    public List<String> getObjectNames() {
        return this.toolingApiService.getCustomObjectNames();
    }
}