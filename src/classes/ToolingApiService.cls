public with sharing class ToolingApiService extends Api {
    private static ToolingApiService instance;

    public ToolingApiService(ICallout calloutClient) {
        super(calloutClient);
    }

    public ToolingApiService(Auth authProvider) {
        super(authProvider);
    }

    protected override String getApiPath() {
        return Constants.Api.TOOLING_API_ROOT_PATH;
    }

    /**
    * @description Singleton
    */
    public static ToolingApiService getInstance(Auth authProvider) {
        if (instance == null) {
            instance = new ToolingApiService(authProvider);
        }
        return instance;
    }

    /**
    * @description 
    */
    public List<String> getCustomObjectNames() {
        List<String> names = new List<String>();
        String pathCustomObjectQuery = this.getEndpointPath(Constants.Api.QUERY_PATH + Constants.Api.QUERY_CUSTOM_OBJECT_NAMES);
        HttpResponse response = this.executeGetCallout(pathCustomObjectQuery);

        if (response == null || response.getBody() == null) {
            return names;
        } else if (response.getStatusCode() != 200) {
            throw new ApiException(String.valueOf(response.getBody()));
        }

        for (Records record : this.parseCustomObjectQueryResponse(response.getBody())?.records) {
            if (record.DeveloperName.contains(this.CUSTOM_FIELD_POSTFIX)) continue;
            names.add(record.DeveloperName + this.CUSTOM_FIELD_POSTFIX);
        }

        return names;
    }

    public ToolingQueryResponse parseCustomObjectQueryResponse(String body) {
        return (ToolingQueryResponse) JSON.deserialize(body, ToolingQueryResponse.class);
    }

    public class ToolingQueryResponse {
        public List<Records>records;
    }

    public class Records {
        public String DeveloperName;
    }
}