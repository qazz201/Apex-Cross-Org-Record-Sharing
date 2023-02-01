public abstract with sharing class Api {
    protected Auth authProvider;
    protected ICallout calloutClient;
    protected String endpointApiUrl;

    protected final String CUSTOM_FIELD_POSTFIX = '__c';
    protected final String AUTHORIZATION = 'Authorization';
    protected final String BEARER = 'Bearer ';

    public Api(ICallout calloutClient) {
        this.calloutClient = calloutClient;
        this.endpointApiUrl = this.calloutClient.getEndpoint() + this.getApiPath();
    }

    public Api(Auth authProvider) {
        this.authProvider = authProvider;
        this.calloutClient = authProvider.getCalloutClient();
        this.endpointApiUrl = this.calloutClient.getEndpoint() + this.getApiPath();
    }

    //Public methods
    public virtual List<String> getCustomObjectNames() {
        return null;
    }

    public virtual List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        return null;
    }

    protected abstract String getApiPath();

    protected virtual HttpResponse executeGetCallout(String resourceEndpoint) {
        this.calloutClient.setEndpoint(resourceEndpoint);
        HttpResponse response = this.calloutClient.get();
        response = this.handleCalloutResponseStatusCode(response, resourceEndpoint);
        
        return response;
    }

    protected virtual String getEndpointPath(String apiResource) {
        return this.endpointApiUrl + apiResource;
    }

    private HttpResponse handleCalloutResponseStatusCode(HttpResponse response, String resourceEndpoint) {
        HttpResponse newResponse = response;

        if (response.getStatusCode() == 400 && this.authProvider != null) {
            //400 "expired access/refresh token"
            System.debug('getCustomObjectNames__ CODE=400');
        } else if (response.getStatusCode() == 401 && this.authProvider != null) {
            //401 {"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}
            System.debug('getCustomObjectNames__ CODE=401');
            newResponse = this.calloutGetWithRefreshedAccessToken(resourceEndpoint);
        }

        return newResponse;
    }

    private HttpResponse calloutGetWithRefreshedAccessToken(String resourceEndpoint) {
        Auth.RefreshTokenResponse refreshedToken = this.authProvider.getNewAccessToken();

        this.calloutClient.clearAllHeaders();
        this.calloutClient.setHeader(this.AUTHORIZATION, this.BEARER + refreshedToken.access_token);
        HttpResponse response = this.executeGetCallout(resourceEndpoint);

        //update access_token after callout
        RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, refreshedToken.access_token);
        System.debug('NEW TOKEN: calloutWithRefreshedAccessToken__ ' + refreshedToken);

        return response;
    }

    public class ApiException extends Exception {
    }
} 