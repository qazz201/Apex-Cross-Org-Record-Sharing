public abstract with sharing class Api {
    protected Auth authProvider;
    protected ICallout calloutClient;
    protected String endpointApiUrl;

    protected final String CUSTOM_FIELD_POSTFIX = '__c';

    public Api(ICallout calloutClient) {
        this.calloutClient = calloutClient;
        this.endpointApiUrl = this.calloutClient.getEndpoint() + this.getApiPath();
    }

    public Api(Auth authProvider) {
        this.authProvider = authProvider;
        this.calloutClient = authProvider.getCalloutClient();
        this.endpointApiUrl = this.calloutClient.getEndpoint() + this.getApiPath();
    }

    protected abstract String getApiPath();

    protected virtual HttpResponse executeGetCallout(String resourceEndpoint) {
        this.calloutClient.setEndpoint(resourceEndpoint);
        HttpResponse response = this.calloutClient.get();
        System.debug('CALLOUT URL: ' + resourceEndpoint);
        response = this.handleCalloutResponseByStatusCode(response, resourceEndpoint);
        System.debug('RESPONSE__: ' + response.getBody());
        return response;
    }

    protected virtual String getEndpointPath(String apiResource) {
        return this.endpointApiUrl + apiResource;
    }

    private HttpResponse handleCalloutResponseByStatusCode(HttpResponse response, String resourceEndpoint) {
        if (this.authProvider == null) return response;
        HttpResponse newResponse = response;

        if (response.getStatusCode() == 400) {
            //400 "expired access/refresh token"
            System.debug('HANDLE STATUS CODE_ CODE=400');
            throw new ApiException(response.getBody());
            //TODO: create handler
        } else if (response.getStatusCode() == 401) {
            //401 {"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}
            System.debug('HANDLE STATUS CODE_ CODE=401');
            newResponse = this.calloutGetWithRefreshedAccessToken(resourceEndpoint);
        }

        return newResponse;
    }

    //TODO: Add retry counter( may be infinite call if status code=400 or 401)!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    private HttpResponse calloutGetWithRefreshedAccessToken(String resourceEndpoint) {
        Auth.RefreshTokenResponse refreshedToken = this.authProvider.getNewAccessToken();

        this.calloutClient.clearAllHeaders();
        this.calloutClient.setHeader(Constants.Auth.AUTHORIZATION_HEADER, Constants.Auth.BEARER_HEADER + refreshedToken.access_token);
        HttpResponse response = this.executeGetCallout(resourceEndpoint);

        //TODO: add save method in AuthProvider!!!!
        //update access_token after callout
        RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, refreshedToken.access_token);
        System.debug('NEW TOKEN: calloutWithRefreshedAccessToken__ ' + refreshedToken);

        return response;
    }

    public class ApiException extends Exception {
    }
} 