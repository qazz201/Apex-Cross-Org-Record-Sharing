public abstract with sharing class Auth {
    protected ICallout calloutClient;

    protected AuthorizationParams authorizationParams = new AuthorizationParams();
    protected AccessTokenResponse accessTokenResponse = new AccessTokenResponse();

    public Auth(AuthorizationParams authorizationParams, ICallout calloutClient) {
        this.authorizationParams = authorizationParams;
        this.calloutClient = calloutClient;
    }

    public Auth(ICallout calloutClient) {
        this.calloutClient = calloutClient;
    }

    protected abstract String getAccessTokenEndpoint();
    protected abstract String getRefreshTokenEndpoint();
    protected abstract String getUserInfoEndpoint();

    /**
    *  @description authorize via params from custom settings (by using clientId and clientSecret and authCode) or passed auth params
    *  reauthorization is supported
    */
    public virtual void authorize() {
        this.calloutClient.clearAllHeaders();
        calloutClient.setEndpoint(this.getAccessTokenEndpoint());
        HttpResponse response = calloutClient.post();

        System.debug('AUTH Response code: ' + response.getStatusCode());

        if (response.getStatusCode() >= 400) {
            System.debug('Reauthorization...');
            this.reauthorize();
            return;
        }

        this.accessTokenResponse = this.parseAccessTokenResponse(response.getBody());
        this.saveUserInfoInCustomSetting(this.getUserInfo());
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

        System.debug('GetNewAccessToken: ' + response.getBody());
        if (response.getStatusCode() != 200) {
            throw new AuthException('Reauthorization Error: ' + response.getBody());
        }

        return this.parseRefreshTokenResponse(response.getBody());
    }

    /**
     * @description 
    */
    public virtual void saveAccessToken(String access_token) {
        RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, access_token);
    }

    /**
     * @description 
    */
    public virtual UserInfoResponse getUserInfo() {
        String userInfoEndpoint = this.getUserInfoEndpoint();
        if (String.isBlank(userInfoEndpoint) || this.doesUserInfoExist()) return null;

        calloutClient.setEndpoint(userInfoEndpoint);
        calloutClient.clearAllHeaders();
        calloutClient.setHeader(
                Constants.Auth.AUTHORIZATION_HEADER,
                Constants.Auth.BEARER_HEADER + this.getAccessToken()
        );

        HttpResponse response = calloutClient.post();
        return this.parseUserInfoResponse(response.getBody());
    }

    protected virtual void reauthorize() { // TODO:Add counter for Reauth
        RefreshTokenResponse refreshTokenResponse = this.getNewAccessToken();
        this.accessTokenResponse.access_token = refreshTokenResponse?.access_token;
        this.saveAccessToken(refreshTokenResponse?.access_token);
        System.debug('__reauthorize_accessTokenResponse__ ' + this.accessTokenResponse);
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

    public virtual String getEnvironmentUrl() {
        String currentEnvironmentUrl = this.authorizationParams?.environmentUrl;
        return String.isNotBlank(currentEnvironmentUrl) ? currentEnvironmentUrl : RecordTransferCustomSettingService.getOrgDefaultSetting()?.EnvironmentUrl__c;
    }

    protected virtual void saveAuthParamsInCustomSetting() {
        RecordTransferCustomSettingService.setOrgDefaultSetting(new Map<SObjectField, String>{
                RecordTransferSettings__c.AuthorizationCode__c => this.getAuthorizationCode(),
                RecordTransferSettings__c.Client_Id__c => this.getClientId(),
                RecordTransferSettings__c.ClientSecret__c => this.getClientSecret(),
                RecordTransferSettings__c.RedirectUri__c => this.getCallbackUrl(),
                RecordTransferSettings__c.AccessToken__c => this.getAccessToken(),
                RecordTransferSettings__c.Refresh_Token__c => this.getRefreshToken(),
                RecordTransferSettings__c.Instance_Url__c => this.getInstanceUrl(),
                RecordTransferSettings__c.EnvironmentUrl__c => this.getEnvironmentUrl()
        });
    }

    protected virtual void saveUserInfoInCustomSetting(UserInfoResponse userInfo) {
        if (userInfo == null) return;
        
        RecordTransferCustomSettingService.setOrgDefaultSetting(new Map<SObjectField, String>{
                RecordTransferSettings__c.UserEmail__c => userInfo.email,
                RecordTransferSettings__c.UserName__c => userInfo.name,
                RecordTransferSettings__c.PreferredUsername__c => userInfo.preferred_username
        });
    }

    private Boolean doesUserInfoExist() {
        return String.isNotBlank(RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.UserEmail__c))
                || String.isNotBlank(RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.UserName__c))
                || String.isNotBlank(RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.PreferredUsername__c));
    }

    protected AccessTokenResponse parseAccessTokenResponse(String responseBody) {
        return (AccessTokenResponse) JSON.deserialize(responseBody, AccessTokenResponse.class);
    }

    protected RefreshTokenResponse parseRefreshTokenResponse(String responseBody) {
        return (RefreshTokenResponse) JSON.deserialize(responseBody, RefreshTokenResponse.class);
    }

    protected UserInfoResponse parseUserInfoResponse(String responseBody) {
        return (UserInfoResponse) JSON.deserialize(responseBody, UserInfoResponse.class);
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

    public class UserInfoResponse {
        public String preferred_username;
        public String name;
        public String email;
    }

    public class AuthorizationParams {
        String authorizationCode;
        String clientId;
        String clientSecret;
        String callbackUrl;
        String environmentUrl;

        public AuthorizationParams() {
        }

        public AuthorizationParams(String authorizationCode,
                String clientId,
                String clientSecret,
                String callbackUrl,
                String environmentUrl) {
            this.authorizationCode = authorizationCode;
            this.clientId = clientId;
            this.clientSecret = clientSecret;
            this.callbackUrl = callbackUrl;
            this.environmentUrl = environmentUrl;
        }
    }

    public class AuthException extends Exception {
    }
}