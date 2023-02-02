public with sharing class SourceOrgDataContainerController {
    private static ICallout calloutClient = new CalloutClient();

    private static final String AUTHORIZATION_REQUIRED_MSG = 'Authorization required!';

    @AuraEnabled
    public static Boolean checkAuthorization() {
        return hadUserAlreadyAuthorized();
    }

    @AuraEnabled
    public static List<String> getSourceOrgCustomObjectNames() {
        if (!hadUserAlreadyAuthorized()) {
            throw new AuraHandledException(AUTHORIZATION_REQUIRED_MSG);
        }
        List<String> customObjectNames = new List<String>();

        try {
            SourceOrgApi sourceOrgApi = getSourceOrgApi(new CalloutParams(
                    getAuthDefaultSetting(RecordTransferSettings__c.Instance_Url__c),
                    getAuthDefaultSetting(RecordTransferSettings__c.AccessToken__c))
            );

            customObjectNames = sourceOrgApi.getCustomObjectNames();
        } catch (Exception ex) {
            System.debug('ERRR__ '+ex);
            throw new AuraHandledException(ex.getMessage());
        }

        return customObjectNames;
    }

    private static SourceOrgApi getSourceOrgApi(CalloutParams calloutParams) {
        calloutClient.setEndpoint(calloutParams.endpoint);
        calloutClient.clearAllHeaders();
        calloutClient.setHeader('Authorization', 'Bearer ' + calloutParams.accessToken);

        System.debug('aaaa--_ ' + calloutClient.getEndpoint());
        return new SourceOrgApi(new SfWebFlowAuthProvider(calloutClient));
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