public with sharing class ToolingApiService extends Api {
    private static ToolingApiService instance;

    private final String CUSTOM_FIELD_POSTFIX = '__c';

    // Paths
    private final String TOOLING_API_ROOT_PATH = '/services/data/v56.0/tooling/';
    private final String QUERY_PATH = 'query/?q=';

    // Default query
    private final String QUERY_CUSTOM_OBJECT_NAMES = 'SELECT+DeveloperName+from+CustomObject';

    public ToolingApiService(ICallout calloutClient) {
        super(calloutClient);
    }

    protected override String getApiPath() {
        return this.TOOLING_API_ROOT_PATH;
    }

    public static ToolingApiService getInstance(ICallout calloutClient) {
        if (instance == null) {
            instance = new ToolingApiService(calloutClient);
        }
        return instance;
    }

    /**
    * @description 
    */
    public List<String> getCustomObjectNames() {
        List<String> names = new List<String>();
        HttpResponse response = this.executeCallout(
                this.getEndpointPath(this.QUERY_PATH + this.QUERY_CUSTOM_OBJECT_NAMES)
        );

        if (response != null && response.getStatusCode() != 200) {
            throw new ApiException(String.valueOf(response.getStatusCode()));
        }

        if (response == null || response.getBody() == null) return names;

        for (Records record : this.parseCustomObjectQueryResponse(response.getBody())?.records) {
            names.add(record.DeveloperName + CUSTOM_FIELD_POSTFIX);
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