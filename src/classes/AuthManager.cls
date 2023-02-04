public with sharing class AuthManager {
    // check if authorization success( sf no means tat user needs to reauthorize)
//    public static void sfWebFlowAuthorize(String authorizationCode) {
//        sfWebFlowAuthorize(new Auth.AuthorizationParams(authorizationCode, null, null, null));
//    }

    // check if authorization success( sf no means tat user needs to reauthorize)
    public static void sfWebFlowAuthorize(Auth.AuthorizationParams authorizationParams) {
        ICallout calloutClient = new CalloutClient();
        SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(authorizationParams, calloutClient);
        authProvider.authorize();

        //TODO:__
        if (authProvider.getAccessToken() == null) {
            System.debug('ERRRORR___ ');
            return;
        }

        System.debug(calloutClient);
    }
}