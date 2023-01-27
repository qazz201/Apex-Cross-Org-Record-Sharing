public with sharing class RecordTransferCustomSettingService {

    public static void setOrgDefaultSetting(String fieldName, String fieldValue) {
        setOrgDefaultSetting(new Map<String, String>{
                fieldName => fieldValue
        });
    }

    public static void setOrgDefaultSetting(Map<String, String> fieldNameToValue) {
        RecordTransferSettings__c orgDefaultSetting = getOrgDefaultSetting();

        for (String fieldName : fieldNameToValue.keySet()) {
            orgDefaultSetting.put(fieldName, fieldNameToValue.get(fieldName));
        }

        upsert orgDefaultSetting;
    }

    public static RecordTransferSettings__c getOrgDefaultSetting() {
        return RecordTransferSettings__c.getOrgDefaults();
    }
}