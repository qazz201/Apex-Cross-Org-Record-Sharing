public with sharing class AuthManager {
    //private ICallout calloutClient = new CalloutClient();

// check if authorization success( sf no means tat user needs to reauthorize)
    public static void sfAuthenticate(String authorizationCode) {
        sfAuthenticate(new Auth.AuthorizationParams(authorizationCode, null, null, null));
    }

    // check if authorization success( sf no means tat user needs to reauthorize)
    public static void sfAuthenticate(Auth.AuthorizationParams authorizationParams) {
        ICallout calloutClient = new CalloutClient();
        SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(authorizationParams, calloutClient); //  RecordTransferCustomSettingService.getOrgDefaultSetting().AuthorizationCode__c,
        authProvider.authenticate();

        if (authProvider.getAccessToken() == null) {
            System.debug('ERRRORR___ ');
            return;
        }

        System.debug(calloutClient);

    }
}