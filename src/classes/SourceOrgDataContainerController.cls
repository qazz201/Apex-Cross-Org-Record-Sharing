public with sharing class SourceOrgDataContainerController extends Controller {
    private static ICallout calloutClient = new CalloutClient();

//    private static final String AUTHORIZATION_REQUIRED_MSG = Label.AuthAuthorizationRequired;

//    @AuraEnabled
//    public static Boolean checkAuthorization() {
//        return hadUserAlreadyAuthorized();
//    }

    @AuraEnabled
    public static List<String> getSourceOrgCustomObjectNames() {
        if (!hadUserAlreadyAuthorized()) {
            throw new AuraHandledException(Label.Auth_Lbl_AuthorizationRequired);
        }
        List<String> customObjectNames = new List<String>();

        try {
            customObjectNames = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient())).getCustomObjectNames();
        } catch (Exception ex) {
            System.debug('ERRR__ ' + ex);
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

//    public class Authorization {
//        @AuraEnabled
//        public Boolean hadUserAlreadyAuthorized { get; set; }
//        @AuraEnabled
//        public Boolean doesAuthCodeValid { get; set; }
//        @AuraEnabled
//        public Boolean doesAccessTokenValid { get; set; }
//    }
}