public with sharing class RestApiManager {
    private Auth authProvider;

    public RestApiManager(Auth authProvider) {
        this.authProvider = authProvider;
    }

    public ToolingApiService toolingApi() {
        return ToolingApiService.getInstance(this.authProvider);
    }

    public QueryApiService queryApi() {
        return QueryApiService.getInstance(this.authProvider);
    }
}