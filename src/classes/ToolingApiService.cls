public with sharing class ToolingApiService extends Api {
    private static ToolingApiService instance;

    private final String CUSTOM_FIELD_POSTFIX = '__c';
    private final String AUTHORIZATION = 'Authorization';
    private final String BEARER = 'Bearer ';

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
        String pathCustomObjectQuery = this.getEndpointPath(this.QUERY_PATH + this.QUERY_CUSTOM_OBJECT_NAMES);
        HttpResponse response = this.executeCallout(pathCustomObjectQuery);

        if (response == null || response.getBody() == null) {
            return names;
        }
        
        response = this.handleCustomObjectNamesResponseStatuses(response, pathCustomObjectQuery);

        for (Records record : this.parseCustomObjectQueryResponse(response.getBody())?.records) {
            names.add(record.DeveloperName + CUSTOM_FIELD_POSTFIX);
        }

        return names;
    }

    private HttpResponse handleCustomObjectNamesResponseStatuses(HttpResponse response, String endpoint) {
        HttpResponse newResponse = response;

        if (response.getStatusCode() == 400) {
            //400 "expired access/refresh token"
            System.debug('getCustomObjectNames__ CODE=400');
        } else if (response.getStatusCode() == 401) {
            //401 {"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}
            System.debug('getCustomObjectNames__ CODE=401');
            newResponse = this.calloutWithRefreshedAccessToken(endpoint);
        } else if (response.getStatusCode() != 200) {
            throw new ApiException(String.valueOf(response.getStatusCode()));
        }

        return newResponse;
    }

    private HttpResponse calloutWithRefreshedAccessToken(String endpoint) {
        this.calloutClient.clearAllHeaders();
        SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(this.calloutClient);
        Auth.RefreshTokenResponse refreshTokenResponse = authProvider.getNewAccessToken();
        calloutClient.setHeader(AUTHORIZATION, BEARER + refreshTokenResponse.access_token);

        HttpResponse response = this.executeCallout(endpoint);

        //update access_token after callout
        RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, refreshTokenResponse.access_token);
        System.debug('NEW TOKEN: calloutWithRefreshedAccessToken__ ' + refreshTokenResponse);

        return response;
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