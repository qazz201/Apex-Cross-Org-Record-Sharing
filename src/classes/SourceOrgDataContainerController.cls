public with sharing class SourceOrgDataContainerController extends Controller {
    private static SourceOrgApi sourceOrgApi {
        get {
            return sourceOrgApi == null ? sourceOrgApi = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient())) : sourceOrgApi;
        }
        set;
    }

    @AuraEnabled
    public static UserAuthData checkIfUserAuthenticated() {
        return new UserAuthData(hadUserAlreadyAuthenticated(),
                getAuthDefaultSetting(RecordTransferSettings__c.UserName__c),
                getAuthDefaultSetting(RecordTransferSettings__c.UserEmail__c),
                getAuthDefaultSetting(RecordTransferSettings__c.Instance_Url__c)
        );
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
    public static List<SavedRecordData> copyRecordsByIds(String objectName, List<Id>recordIds) {
        List<SavedRecordData> result = new List<SavedRecordData>();

        try {
            List<SObject> savedRecords = sourceOrgApi.transferRecordsFromSourceToCurrentOrg(objectName, new Set<Id>(recordIds));

            if (Lists.isEmpty(savedRecords)) return result;
            SObjectField sObjectNameField = Schema.getGlobalDescribe().get(objectName).getDescribe().fields.getMap().get(Constants.Query.NAME_FIELD);

            for (SObject record : savedRecords) {
                String nameValue = null;

                if (sObjectNameField != null) {
                    nameValue = (String) record.get(Constants.Query.NAME_FIELD);
                }

                result.add(new SavedRecordData('0036800000I674KAAR', nameValue));
            }

            System.debug('TO SAVE_________' + savedRecords);
        } catch (Exception ex) {
            System.debug(ex.getStackTraceString());
            throw new AuraHandledException(ex.getMessage());
        }
        return result;
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
        public String userEmail { get; set; }
        @AuraEnabled
        public String userOrgUrl { get; set; }

        public UserAuthData(Boolean userAuthenticated, String userName, String userEmail, String userOrgUrl) {
            this.userAuthenticated = userAuthenticated;
            this.userName = userName;
            this.userEmail = userEmail;
            this.userOrgUrl = userOrgUrl;
        }
    }

    public class SavedRecordData {
        @AuraEnabled
        public String recordId { get; set; }
        @AuraEnabled
        public String recordName { get; set; }

        public SavedRecordData(String recordId, String recordName) {
            this.recordId = recordId;
            this.recordName = String.isBlank(recordName) ? recordId : recordName;
        }
    }
}