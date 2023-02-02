public with sharing class AuthManager {
    // check if authorization success( sf no means tat user needs to reauthorize)
    public static void sfWebFlowAuthenticate(String authorizationCode) {
        sfWebFlowAuthenticate(new Auth.AuthorizationParams(authorizationCode, null, null, null));
    }

    // check if authorization success( sf no means tat user needs to reauthorize)
    public static void sfWebFlowAuthenticate(Auth.AuthorizationParams authorizationParams) {
        ICallout calloutClient = new CalloutClient();
        SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(authorizationParams, calloutClient); //  RecordTransferCustomSettingService.getOrgDefaultSetting().AuthorizationCode__c,
        authProvider.authenticate();

        //TODO:__
        if (authProvider.getAccessToken() == null) {
            System.debug('ERRRORR___ ');
            return;
        }

        System.debug(calloutClient);
    }
}