public with sharing class AuthManager {
    // check if authorization success( sf no means tat user needs to reauthorize)
    public static void sfWebFlowAuthorize(Auth.AuthorizationParams authorizationParams) {
        ICallout calloutClient = new CalloutClient();
        SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(authorizationParams, calloutClient);
        authProvider.authorize();

        if (authProvider.getAccessToken() == null) {
            throw new AuthManagerException(Label.Auth_Lbl_AuthenticationError);
        }
    }

    public class AuthManagerException extends Exception {
    }
}