public with sharing class SfWebFlowAuthProvider extends Auth {
    // private final String AUTHORIZATION_ENDPOINT = 'https://login.salesforce.com/services/oauth2/authorize';
    private final String TOKEN_ROOT_ENDPOINT = 'https://login.salesforce.com/services/oauth2/token';
    private final String GRANT_TYPE_AUTH_CODE = 'authorization_code';
    private final String GRANT_TYPE_REFRESH_TOKEN = 'refresh_token';

    public SfWebFlowAuthProvider(String authorizationCode, ICallout calloutClient) {
        super(authorizationCode, calloutClient);
    }

    public SfWebFlowAuthProvider(AuthorizationParams authorizationParams, ICallout calloutClient) {
        super(authorizationParams, calloutClient);
    }

    public SfWebFlowAuthProvider(ICallout calloutClient) {
        super(calloutClient);
    }
    
    protected override String getAccessTokenEndpoint() {
        return this.getResultEndpointUrl(
                this.getTokenUrlParams(
                        new Map<String, String>{
                                '&grant_type=' => this.GRANT_TYPE_AUTH_CODE,
                                '&code=' => this.getAuthorizationCode()
                        }
                )
        );
    }

    protected override String getRefreshTokenEndpoint() {
        return this.getResultEndpointUrl(
                this.getTokenUrlParams(
                        new Map<String, String>{
                                '&grant_type=' => this.GRANT_TYPE_REFRESH_TOKEN,
                                '&refresh_token=' => this.getRefreshToken()
                        }
                )
        );
    }

    private Map<String, String> getTokenUrlParams(Map<String, String> specificUrlParams) {
        Map<String, String> defaultTokenUrlParams = new Map<String, String>{
                '?client_id=' => this.getClientId(),
                '&client_secret=' => this.getClientSecret(),
                '&redirect_uri=' => this.getCallbackUrl()
        };
        defaultTokenUrlParams.putAll(specificUrlParams);
        return defaultTokenUrlParams;
    }

    private String getResultEndpointUrl(Map<String, String> urlParams) {
        if (urlParams.isEmpty()) return null;
        String combinedUrlParams = '';

        for (String urlKey : urlParams.keySet()) {
            combinedUrlParams += urlKey + urlParams.get(urlKey);
        }
        return this.TOKEN_ROOT_ENDPOINT + combinedUrlParams;
    }

    public class SfWebFlowAuthProviderException extends Exception {
    }
}