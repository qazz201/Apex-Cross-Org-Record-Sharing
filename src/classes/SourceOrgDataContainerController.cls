public with sharing class SourceOrgDataContainerController extends Controller {
    private static SourceOrgApi sourceOrgApi {
        get {
            return sourceOrgApi == null ? sourceOrgApi = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient())) : sourceOrgApi;
        }
        set;
    }

    @AuraEnabled
    public static UserAuthData checkIfUserAuthenticated() {
        return new UserAuthData(hadUserAlreadyAuthenticated(), 'TestName', 'TestURL');
    }

    @AuraEnabled
    public static List<String> getSourceOrgCustomObjectNames() {
        if (!hadUserAlreadyAuthenticated()) {
            throw new AuraHandledException(Label.Auth_Lbl_AuthenticationRequired);
        }
        List<String> customObjectNames = new List<String>();

        try {
            customObjectNames = sourceOrgApi.getCustomObjectNames();
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
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
            if (sobjName.contains('__c') || sobjName.contains('__x')) continue;
            standardObjectNames.add(sobjName);
        }
        standardObjectNames.sort();
        return standardObjectNames;
    }

    @AuraEnabled
    public static void copyRecordsByIds(String objectName, List<Id>recordIds) {
        try {
            List<SObject> records = sourceOrgApi.transferRecordsFromSourceToCurrentOrg(objectName, new Set<Id>(recordIds));
            System.debug('TO SAVE_________' + records);
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
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

    public class UserAuthData {
        @AuraEnabled
        public Boolean userAuthenticated { get; set; }
        @AuraEnabled
        public String userName { get; set; }
        @AuraEnabled
        public String userOrgUrl { get; set; }

        public UserAuthData(Boolean userAuthenticated, String userName, String userOrgUrl) {
            this.userAuthenticated = userAuthenticated;
            this.userName = userName;
            this.userOrgUrl = userOrgUrl;
        }
    }
}