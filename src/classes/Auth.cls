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
    
    protected virtual void authenticate() {
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
}