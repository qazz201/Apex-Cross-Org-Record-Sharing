public abstract with sharing class Api {
    protected Auth authProvider;
    protected ICallout calloutClient;
    protected String endpointApiUrl;

    protected final String CUSTOM_FIELD_POSTFIX = '__c';
    private static Integer RETRY_TIMES = 0;

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
        return response;
    }

    protected virtual String getEndpointPath(String apiResource) {
        return this.endpointApiUrl + apiResource;
    }

    protected virtual Object parseQueryResponse(String body, Type parseType) {
        return JSON.deserialize(body, parseType);
    }

    private HttpResponse handleCalloutResponseByStatusCode(HttpResponse response, String resourceEndpoint) {
        if (this.authProvider == null) return response;
        HttpResponse newResponse = response;

        if (response.getStatusCode() == 400) {
            System.debug('HANDLE STATUS CODE_ CODE=400');
            throw new ApiException(response.getBody());
        } else if (response.getStatusCode() == 401) {
            //401 {"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}
            System.debug('HANDLE STATUS CODE_ CODE=401');
            HttpResponse responseWithNewToken = this.calloutGetWithRefreshedAccessToken(resourceEndpoint);
            if (responseWithNewToken != null) newResponse = responseWithNewToken;
        }

        return newResponse;
    }
    
    private HttpResponse calloutGetWithRefreshedAccessToken(String resourceEndpoint) {
        if (RETRY_TIMES >= Constants.Api.MAX_RETRY_TIMES) return null;

        RETRY_TIMES++;
        Auth.RefreshTokenResponse refreshedToken = this.authProvider.getNewAccessToken();

        this.calloutClient.clearAllHeaders();
        this.calloutClient.setHeader(Constants.Auth.AUTHORIZATION_HEADER, Constants.Auth.BEARER_HEADER + refreshedToken.access_token);
        HttpResponse response = this.executeGetCallout(resourceEndpoint);

        //update access_token after callout
        this.authProvider.saveAccessToken(refreshedToken.access_token);
        RETRY_TIMES = 0;
        return response;
    }

    public class ApiException extends Exception {
    }
} 