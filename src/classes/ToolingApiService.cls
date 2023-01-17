public with sharing class ToolingApiService extends Api {
    // Paths
    private final String TOOLING_API_PATH = '/services/data/v56.0/tooling/';
    private final String QUERY_PATH = 'query/?q=';

    // Default query
    private final String QUERY_CUSTOM_OBJECT_NAMES = 'SELECT+DeveloperName+from+CustomObject';

    public ToolingApiService(ICalloutClient calloutClient, String endpointDomain) {
        super(calloutClient, endpointDomain);
    }

    protected override String getApiPath() {
        return this.TOOLING_API_PATH;
    }

    /**
    * @description 
    */
    public List<String> getCustomObjectNames() {
        List<String> names = new List<String>();
        HttpResponse response = this.executeCallout(
                this.getEndpointPath(this.QUERY_PATH + this.QUERY_CUSTOM_OBJECT_NAMES)
        );

        if (response.getStatusCode() != 200 || response.getBody() == null) return names;

        for (Records record : this.parseCustomObjectQueryResponse(response.getBody()).records) {
            names.add(record.DeveloperName + '__c');
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