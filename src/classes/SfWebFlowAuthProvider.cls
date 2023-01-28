public with sharing class SfWebFlowAuthProvider implements IAuth {
    private ICallout calloutClient;
    private String authorizationCode;
    private AccessTokenResponse accessTokenResponse = new AccessTokenResponse();

    // private final String AUTHORIZATION_ENDPOINT = 'https://login.salesforce.com/services/oauth2/authorize';
    private final String TOKEN_ROOT_ENDPOINT = 'https://login.salesforce.com/services/oauth2/token';
    private final String GRANT_TYPE_AUTH_CODE = 'authorization_code';
    private final String GRANT_TYPE_REFRESH_TOKEN = 'refresh_token';

    public SfWebFlowAuthProvider(String authorizationCode, ICallout calloutClient) {
        this.authorizationCode = authorizationCode;
        this.calloutClient = calloutClient;
    }

    public String getAccessToken() {
        String currentAccessToken = this.accessTokenResponse.access_token;
        return String.isNotBlank(currentAccessToken) ? currentAccessToken : RecordTransferCustomSettingService.getOrgDefaultSetting()?.AccessToken__c;
    }

    public String getRefreshToken() {
        String currentRefreshToken = this.accessTokenResponse.refresh_token;
        return String.isNotBlank(currentRefreshToken) ? currentRefreshToken : RecordTransferCustomSettingService.getOrgDefaultSetting()?.Refresh_Token__c;
    }

    public String getInstanceUrl() {
        String currentInstanceUrl = this.accessTokenResponse.instance_url;
        return String.isNotBlank(currentInstanceUrl) ? currentInstanceUrl : RecordTransferCustomSettingService.getOrgDefaultSetting()?.Instance_Url__c;
    }

    public void authenticate() {
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
        RecordTransferCustomSettingService.setOrgDefaultSetting(new Map<SObjectField, String>{
                RecordTransferSettings__c.AccessToken__c => this.accessTokenResponse.access_token,
                RecordTransferSettings__c.Refresh_Token__c => this.accessTokenResponse.refresh_token,
                RecordTransferSettings__c.Instance_Url__c => this.accessTokenResponse.instance_url
        });

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

    private AccessTokenResponse parseTokenResponse(String responseBody) {
        return (AccessTokenResponse) JSON.deserialize(responseBody, AccessTokenResponse.class);
    }

    private Map<String, String> getTokenUrlParams(Map<String, String> specificUrlParams) {
        RecordTransferSettings__c transferSetting = RecordTransferCustomSettingService.getOrgDefaultSetting();

        Map<String, String> tokenUrlParams = new Map<String, String>{
                '?client_id=' => transferSetting.Client_Id__c,
                '&client_secret=' => transferSetting.ClientSecret__c,
                '&redirect_uri=' => transferSetting.RedirectUri__c
        };
        tokenUrlParams.putAll(specificUrlParams);
        return tokenUrlParams;
    }

    private String getAccessTokenEndpoint() {
        return this.getResultEndpointUrl(
                this.getTokenUrlParams(
                        new Map<String, String>{
                                '&grant_type=' => this.GRANT_TYPE_AUTH_CODE,
                                '&code=' => this.authorizationCode
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

    class AccessTokenResponse {
        public String access_token;
        public String refresh_token;
        public String instance_url;
    }

    public class SfWebFlowAuthProviderException extends Exception {
    }
}