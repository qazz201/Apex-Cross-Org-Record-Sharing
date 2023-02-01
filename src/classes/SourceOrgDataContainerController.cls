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
            SourceOrgApi sourceOrgApi = getSourceOrgApi(new CalloutParams(
                    getAuthDefaultSetting(RecordTransferSettings__c.Instance_Url__c),
                    getAuthDefaultSetting(RecordTransferSettings__c.AccessToken__c))
            );

            customObjectNames = sourceOrgApi.getCustomObjectNames();
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }

        return customObjectNames;
    }

    private static SourceOrgApi getSourceOrgApi(CalloutParams calloutParams) {
        calloutClient.setEndpoint(calloutParams.endpoint);
        calloutClient.clearAllHeaders();
        calloutClient.setHeader('Authorization', 'Bearer ' + calloutParams.accessToken);
        SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(calloutClient);
        System.debug('aaaa--_ ' + calloutClient.getEndpoint());
        return new SourceOrgApi(authProvider);
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