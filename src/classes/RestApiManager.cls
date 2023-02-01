public with sharing class RestApiManager {
    private Auth authProvider;

    public RestApiManager(Auth authProvider) {
        this.authProvider = authProvider;
    }

    public Api toolingApi() {
        return new ToolingApiService(this.authProvider);
    }

    public Api queryApi() {
        return new QueryApiService(this.authProvider);
    }
}