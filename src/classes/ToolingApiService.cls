public with sharing class ToolingApiService {
    private ICalloutClient calloutClient ;

    // Paths
    private final String ROOT_PATH;
    private final String TOOLING_API_PATH = '/services/data/v56.0/tooling/';
    private final String QUERY_PATH = 'query/?q=';

    // Default query
    private final String QUERY_CUSTOM_OBJECT_NAMES = 'SELECT+DeveloperName+from+CustomObject';

    public ToolingApiService(ICalloutClient calloutClient, String endpointDomain) {
        if (calloutClient == null) this.calloutClient = new CalloutClient();
        this.calloutClient = calloutClient;
        this.ROOT_PATH = endpointDomain + this.TOOLING_API_PATH;
    }

    /**
    * @description 
    */
    public List<String> getCustomObjectNames() {
        List<String> names = new List<String>();
        HttpResponse response = this.executeCallout(getEndpointPath(this.QUERY_PATH + this.QUERY_CUSTOM_OBJECT_NAMES));
        
        if (response.getStatusCode() != 200 || response.getBody() == null) return names;

        for (Records record : parseCustomObjectQueryResponse(response.getBody()).records) {
            names.add(record.DeveloperName + '__c');
        }

        System.debug(names);
        return names;
    }

    private HttpResponse executeCallout(String resourceEndpoint) {
        HttpResponse response;
        try {
            calloutClient.setEndpoint(resourceEndpoint);
            response = calloutClient.get();
        } catch (Exception ex) {
            return response;
        }

        return response;
    }

    private String getEndpointPath(String resource) {
        return this.ROOT_PATH + resource;
    }

    public static ToolingQueryResponse parseCustomObjectQueryResponse(String body) {
        return (ToolingQueryResponse) JSON.deserialize(body, ToolingQueryResponse.class);
    }

    public class ToolingQueryResponse {
        public List<Records>records;
    }

    public class Records {
        public String DeveloperName;
    }
}