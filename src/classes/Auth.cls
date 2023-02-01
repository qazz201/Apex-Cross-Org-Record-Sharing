public abstract with sharing class Auth {
    protected ICallout calloutClient;

    protected AuthorizationParams authorizationParams = new AuthorizationParams();
    protected AccessTokenResponse accessTokenResponse = new AccessTokenResponse();

    public Auth(String authorizationCode, ICallout calloutClient) {
        this.authorizationParams.authorizationCode = authorizationCode;
        this.calloutClient = calloutClient;
    }

    public Auth(AuthorizationParams authorizationParams, ICallout calloutClient) {
        this.authorizationParams = authorizationParams;
        this.calloutClient = calloutClient;
    }

    public Auth(ICallout calloutClient) {
        this.calloutClient = calloutClient;
    }

//    public Auth() {
//    }

    protected abstract String getAccessTokenEndpoint();
    protected abstract String getRefreshTokenEndpoint();

    /**
   *  @description authenticate via params from custom settings or passed auth params
   */
    public virtual void authenticate() {
        this.calloutClient.clearAllHeaders();
        calloutClient.setEndpoint(this.getAccessTokenEndpoint());
        HttpResponse response = calloutClient.post();

        System.debug(response.getBody());
        System.debug('AUTH Response code___ ' + response.getStatusCode());

        if (response.getStatusCode() >= 400) {
            System.debug('Reauthorization...');
            this.refreshAuthentication();
            return;
        }

        this.accessTokenResponse = this.parseAccessTokenResponse(response.getBody());
        this.saveAuthParamsInCustomSetting();

        System.debug(this.accessTokenResponse);
    }

    /**
    * @description get refreshed access token params (if expired)
    */
    public virtual RefreshTokenResponse getNewAccessToken() {
        this.calloutClient.clearAllHeaders();
        this.calloutClient.setEndpoint(this.getRefreshTokenEndpoint());
        HttpResponse response = calloutClient.post();

        System.debug('AAAA-- _' + response.getBody());
        if (response.getStatusCode() != 200) {
            throw new AuthException('Reauthorization Error: ' + response.getBody());
        }

        return this.parseRefreshTokenResponse(response.getBody());
    }

    public virtual void setCalloutClient(ICallout calloutClient) {
        this.calloutClient = calloutClient;
    }
    
    public virtual ICallout getCalloutClient() {
        return this.calloutClient;
    }

    public virtual String getAccessToken() {
        String currentAccessToken = this.accessTokenResponse?.access_token;
        return String.isNotBlank(currentAccessToken) ? currentAccessToken : RecordTransferCustomSettingService.getOrgDefaultSetting()?.AccessToken__c;
    }

    public virtual String getRefreshToken() {
        String currentRefreshToken = this.accessTokenResponse?.refresh_token;
        return String.isNotBlank(currentRefreshToken) ? currentRefreshToken : RecordTransferCustomSettingService.getOrgDefaultSetting()?.Refresh_Token__c;
    }

    public virtual String getInstanceUrl() {
        String currentInstanceUrl = this.accessTokenResponse?.instance_url;
        return String.isNotBlank(currentInstanceUrl) ? currentInstanceUrl : RecordTransferCustomSettingService.getOrgDefaultSetting()?.Instance_Url__c;
    }

    public virtual String getAuthorizationCode() {
        String currentAuthorizationCode = this.authorizationParams?.authorizationCode;
        return String.isNotBlank(currentAuthorizationCode) ? currentAuthorizationCode : RecordTransferCustomSettingService.getOrgDefaultSetting()?.AuthorizationCode__c;
    }

    public virtual String getClientId() {
        String currentClientId = this.authorizationParams?.clientId;
        return String.isNotBlank(currentClientId) ? currentClientId : RecordTransferCustomSettingService.getOrgDefaultSetting()?.Client_Id__c;
    }

    public virtual String getClientSecret() {
        String currentClientSecret = this.authorizationParams?.clientSecret;
        return String.isNotBlank(currentClientSecret) ? currentClientSecret : RecordTransferCustomSettingService.getOrgDefaultSetting()?.ClientSecret__c;
    }

    public virtual String getCallbackUrl() {
        String currentCallbackUrl = this.authorizationParams?.callbackUrl;
        return String.isNotBlank(currentCallbackUrl) ? currentCallbackUrl : RecordTransferCustomSettingService.getOrgDefaultSetting()?.RedirectUri__c;
    }

    protected virtual void refreshAuthentication() {
        RefreshTokenResponse refreshTokenResponse = this.getNewAccessToken();
        this.accessTokenResponse.access_token = refreshTokenResponse?.access_token;
        RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, refreshTokenResponse?.access_token);

        System.debug('____ ' + this.accessTokenResponse);
    }
    
    protected virtual void saveAuthParamsInCustomSetting() {
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

    protected AccessTokenResponse parseAccessTokenResponse(String responseBody) {
        return (AccessTokenResponse) JSON.deserialize(responseBody, AccessTokenResponse.class);
    }

    protected RefreshTokenResponse parseRefreshTokenResponse(String responseBody) {
        return (RefreshTokenResponse) JSON.deserialize(responseBody, RefreshTokenResponse.class);
    }

    public class RefreshTokenResponse {
        public String access_token;
        public String instance_url;
    }

    public class AccessTokenResponse {
        public String access_token;
        public String refresh_token;
        public String instance_url;
    }

    public class AuthorizationParams {
        String authorizationCode;
        String clientId;
        String clientSecret;
        String callbackUrl;

        public AuthorizationParams() {
        }

        public AuthorizationParams(String authorizationCode, String clientId, String clientSecret, String callbackUrl) {
            this.authorizationCode = authorizationCode;
            this.clientId = clientId;
            this.clientSecret = clientSecret;
            this.callbackUrl = callbackUrl;
        }
    }

    public class AuthException extends Exception {
    }
}