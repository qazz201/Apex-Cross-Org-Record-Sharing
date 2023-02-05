public with sharing class SfWebFlowAuthProvider extends Auth {

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
                                Constants.Auth.AMPERSAND_SIGN
                                        + Constants.Auth.GRANT_TYPE
                                        + Constants.Auth.EQUAL_SIGN => Constants.Auth.AUTHORIZATION_CODE,//'&grant_type='this.GRANT_TYPE_AUTH_CODE,
                                Constants.Auth.AMPERSAND_SIGN
                                        + Constants.Auth.CODE
                                        + Constants.Auth.EQUAL_SIGN => this.getAuthorizationCode() //'&code='// TODO: CHANGE getAuthorizationCode to authentication
                        }
                )
        );
    }

    protected override String getRefreshTokenEndpoint() {
        return this.getResultEndpointUrl(
                this.getTokenUrlParams(
                        new Map<String, String>{
                                Constants.Auth.AMPERSAND_SIGN
                                        + Constants.Auth.GRANT_TYPE
                                        + Constants.Auth.EQUAL_SIGN => Constants.Auth.REFRESH_TOKEN,//'&grant_type=' this.GRANT_TYPE_REFRESH_TOKEN,
                                Constants.Auth.AMPERSAND_SIGN
                                        + Constants.Auth.REFRESH_TOKEN
                                        + Constants.Auth.EQUAL_SIGN => this.getRefreshToken() //'&refresh_token='
                        }
                )
        );
    }

    private Map<String, String> getTokenUrlParams(Map<String, String> specificUrlParams) {
        Map<String, String> defaultTokenUrlParams = new Map<String, String>{
                Constants.Auth.QUESTION_SIGN
                        + Constants.Auth.CLIENT_ID
                        + Constants.Auth.EQUAL_SIGN => this.getClientId(), // '?client_id='
                Constants.Auth.AMPERSAND_SIGN
                        + Constants.Auth.CLIENT_SECRET
                        + Constants.Auth.EQUAL_SIGN => this.getClientSecret(),// '&client_secret='
                Constants.Auth.AMPERSAND_SIGN
                        + Constants.Auth.REDIRECT_URI
                        + Constants.Auth.EQUAL_SIGN => this.getCallbackUrl() // '&redirect_uri='
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
        return Constants.Auth.TOKEN_ENDPOINT + combinedUrlParams;
    }

    public class SfWebFlowAuthProviderException extends Exception {
    }
}