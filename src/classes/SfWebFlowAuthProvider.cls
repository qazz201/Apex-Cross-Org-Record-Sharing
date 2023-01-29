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

    /**
    *  @description authenticate via params from custom settings or passed auth params
    */
    public override void authenticate() {
        this.calloutClient.clearAllHeaders();
        calloutClient.setEndpoint(this.getAccessTokenEndpoint());
        HttpResponse response = calloutClient.post();

        System.debug(response.getBody());

        if (response.getStatusCode() >= 400) {
            System.debug('Reauthorization...');
            this.refreshAuthentication();
            return;
        }

        this.accessTokenResponse = this.parseTokenResponse(response.getBody());
        this.saveAuthParamsInCustomSetting();

        System.debug(this.accessTokenResponse);
    }

    private void refreshAuthentication() {
        try {
            this.calloutClient.clearAllHeaders();
            this.calloutClient.setEndpoint(this.getRefreshTokenEndpoint());
            HttpResponse response = calloutClient.post();

            System.debug('AAAA-- ' + response.getBody());
            if (response.getStatusCode() != 200) {
                throw new SfWebFlowAuthProviderException('Reauthorization Error: ' + response.getBody());
            }

            String newAccessToken = this.parseTokenResponse(response.getBody())?.access_token;
            if (String.isBlank(newAccessToken)) return;

            this.accessTokenResponse.access_token = newAccessToken;
            RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, newAccessToken);

            System.debug('____ ' + this.accessTokenResponse);
        } catch (Exception ex) {
            System.debug('SfWebFlowAuthProvider.reAuthorize() ERROR: ' + ex.getStackTraceString());
            throw ex;
        }
    }

    private void saveAuthParamsInCustomSetting() {
        RecordTransferCustomSettingService.setOrgDefaultSetting(new Map<SObjectField, String>{
                RecordTransferSettings__c.AuthorizationCode__c => this.getAuthorizationCode(),
                RecordTransferSettings__c.Client_Id__c => this.getClientId(),
                RecordTransferSettings__c.ClientSecret__c => this.getClientSecret(),
                RecordTransferSettings__c.RedirectUri__c => this.getCallbackUrl(),
                RecordTransferSettings__c.AccessToken__c => this.getAccessToken(),
                RecordTransferSettings__c.Refresh_Token__c => this.getRefreshToken(),
                RecordTransferSettings__c.Instance_Url__c => this.getInstanceUrl()
        });
    }

    private AccessTokenResponse parseTokenResponse(String responseBody) {
        return (AccessTokenResponse) JSON.deserialize(responseBody, AccessTokenResponse.class);
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

    private String getAccessTokenEndpoint() {
        return this.getResultEndpointUrl(
                this.getTokenUrlParams(
                        new Map<String, String>{
                                '&grant_type=' => this.GRANT_TYPE_AUTH_CODE,
                                '&code=' => this.getAuthorizationCode()//this.authorizationCode
                        }
                )
        );
    }

    private String getRefreshTokenEndpoint() {
        return this.getResultEndpointUrl(
                this.getTokenUrlParams(
                        new Map<String, String>{
                                '&grant_type=' => this.GRANT_TYPE_REFRESH_TOKEN,
                                '&refresh_token=' => this.getRefreshToken()
                        }
                )
        );
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