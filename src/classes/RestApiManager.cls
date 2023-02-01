public with sharing class RestApiManager {
//    private final ICallout calloutClient;
    private Auth authProvider;

    public RestApiManager(Auth authProvider) {
        this.authProvider = authProvider;
        //  this.endpointDomain = endpointDomain;
    }

    public Api toolingApi() {
        return new ToolingApiService(this.authProvider);//new ToolingApiProvider(this.authProvider);
    }

    public Api queryApi() {
        return new QueryApiService(this.authProvider);//new QueryApiProvider(this.calloutClient);
    }
}