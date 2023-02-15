public with sharing class AuthenticationController {

    @AuraEnabled
    public static void authorize(String authCode,
            String clientId,
            String clientSecret,
            String callbackUrl,
            String environmentUrl) {
        try {
            AuthManager.sfWebFlowAuthorize(new Auth.AuthorizationParams(authCode, clientId, clientSecret, callbackUrl, environmentUrl));
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
    }
}