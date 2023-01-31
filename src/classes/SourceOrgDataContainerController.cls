public with sharing class SourceOrgDataContainerController {
    private static ICallout calloutClient = new CalloutClient();

    @AuraEnabled
    public static Boolean checkAuthorization() {
        return hadUserAlreadyAuthorized();
    }

    @AuraEnabled
    public static List<String> getSourceOrgCustomObjectNames() {
        if (!hadUserAlreadyAuthorized()) {
            throw new AuraHandledException('Authorization required!');
        }
        List<String> customObjectNames = new List<String>();

        try {
            customObjectNames = restGetCustomObjectNames(new CalloutParams(
                    getAuthDefaultSetting(RecordTransferSettings__c.Instance_Url__c),
                    getAuthDefaultSetting(RecordTransferSettings__c.AccessToken__c))
            );
        } catch (Exception ex) {
            if (ex instanceof Api.ApiException) {
                calloutClient.clearAllHeaders();
                //400 "expired access/refresh token"
                //401 {"message":"Session expired or invalid","errorCode":"INVALID_SESSION_ID"}

                if (ex.getMessage() == '401') {
                    customObjectNames = restReauthorizeAndGetCustomObjectNames();
                } else if (ex.getMessage() == '400') {
                    // aura error to update auth code
                }

                System.debug(ex.getMessage());
            } else {
                throw ex;
            }
        }

        return customObjectNames;
    }

    private static List<String> restGetCustomObjectNames(CalloutParams calloutParams) {
        calloutClient.setEndpoint(calloutParams.endpoint);
        calloutClient.clearAllHeaders();
        calloutClient.setHeader('Authorization', 'Bearer ' + calloutParams.accessToken);

        System.debug(calloutClient.getEndpoint());
        return new SourceOrgApi(calloutClient).getCustomObjectNames();
    }

    private static List<String> restReauthorizeAndGetCustomObjectNames() {
        List<String> customObjectNames = new List<String>();
        try {
            SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(calloutClient);
            Auth.RefreshTokenResponse refreshTokenResponse = authProvider.getNewAccessToken();

            customObjectNames = restGetCustomObjectNames(
                    new CalloutParams(refreshTokenResponse.instance_url, refreshTokenResponse.access_token)
            );

            //update access_token after callout
            RecordTransferCustomSettingService.setOrgDefaultSetting(RecordTransferSettings__c.AccessToken__c, refreshTokenResponse.access_token);

            System.debug('NEW TOKEN: ' + refreshTokenResponse);
        } catch (Exception ex) {
            System.debug(ex);
            throw new AuraHandledException(ex.getMessage());
        }

        return customObjectNames;
    }


    private static Boolean hadUserAlreadyAuthorized() {
        return String.isNotBlank(getAuthDefaultSetting(RecordTransferSettings__c.AuthorizationCode__c))
                && String.isNotBlank(getAuthDefaultSetting(RecordTransferSettings__c.Client_Id__c))
                && String.isNotBlank(getAuthDefaultSetting(RecordTransferSettings__c.ClientSecret__c))
                && String.isNotBlank(getAuthDefaultSetting(RecordTransferSettings__c.RedirectUri__c));
    }

    private static String getAuthDefaultSetting(SObjectField fieldName) {
        return RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(fieldName);
    }

    public class CalloutParams {
        public String endpoint;
        public String accessToken;

        public CalloutParams(String endpoint, String accessToken) {
            this.endpoint = endpoint;
            this.accessToken = accessToken;
        }
    }

    public class Authorization {
        @AuraEnabled
        public Boolean hadUserAlreadyAuthorized { get; set; }
        @AuraEnabled
        public Boolean doesAuthCodeValid { get; set; }
        @AuraEnabled
        public Boolean doesAccessTokenValid { get; set; }
    }
}