public with sharing class AuthenticationController {

    @AuraEnabled
    public static void authorize(String authCode, String clientId, String clientSecret, String callbackUrl) {
        try {
            AuthManager.sfWebFlowAuthorize(new Auth.AuthorizationParams(authCode, clientId, clientSecret, callbackUrl));

            System.debug(authCode);
            System.debug(clientId);
            System.debug(clientSecret);
            System.debug(callbackUrl);
        } catch (Exception ex) {
            System.debug('CONTROLLER ERROR__ ' + ex);
            throw new AuraHandledException(ex.getMessage());
        }
    }
}