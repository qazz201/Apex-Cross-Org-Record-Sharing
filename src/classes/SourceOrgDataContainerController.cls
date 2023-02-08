public with sharing class SourceOrgDataContainerController extends Controller {

    @AuraEnabled
    public static Boolean checkIfUserAuthenticated() {
        return hadUserAlreadyAuthenticated();
    }

    @AuraEnabled
    public static List<String> getSourceOrgCustomObjectNames() {
        if (!hadUserAlreadyAuthenticated()) {
            throw new AuraHandledException(Label.Auth_Lbl_AuthenticationRequired);
        }
        List<String> customObjectNames = new List<String>();

        try {
            customObjectNames = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient())).getCustomObjectNames();
        } catch (Exception ex) {
            System.debug('ERROR_SourceOrgDataContainerController.getSourceOrgCustomObjectNames(): ' + ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }

        return customObjectNames;
    }
    
    @AuraEnabled
    public static List<String> getStandardObjectNames() {
        if (!hadUserAlreadyAuthenticated()) {
            throw new AuraHandledException(Label.Auth_Lbl_AuthenticationRequired);
        }
        List<String> standardObjectNames = new List<String>();

        for (Schema.SObjectType typ : Schema.getGlobalDescribe().values()) {
            String sobjName = String.valueOf(typ);
            if (!sobjName.contains('__c')) {
                standardObjectNames.add(sobjName);
            }
        }
        standardObjectNames.sort();
        return standardObjectNames;
    }


    private static Boolean hadUserAlreadyAuthenticated() {
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
}