public with sharing class RecordTransferCustomSettingService {


    public static void setOrgDefaultSetting(Map<SObjectField, String> fieldValueToType) {
        Map<String, String> fieldNameToValue = new Map<String, String>();

        for (SObjectField field : fieldValueToType.keySet()) {
            fieldNameToValue.put(field.getDescribe().getName(), fieldValueToType.get(field));
        }

        setOrgDefaultSetting(fieldNameToValue);
    }

    public static void setOrgDefaultSetting(SObjectField field, String fieldValue) {
        setOrgDefaultSetting(new Map<String, String>{
                field.getDescribe().getName() => fieldValue
        });
    }

    public static void setOrgDefaultSetting(String fieldName, String fieldValue) {
        setOrgDefaultSetting(new Map<String, String>{
                fieldName => fieldValue
        });
    }

    public static void setOrgDefaultSetting(Map<String, String> fieldNameToValue) {
        RecordTransferSettings__c orgDefaultSetting = getOrgDefaultSetting();

        for (String fieldName : fieldNameToValue.keySet()) {
            String fieldValue = fieldNameToValue.get(fieldName);
            if (String.isBlank(fieldValue)) continue;

            orgDefaultSetting.put(fieldName, fieldValue);
        }

        upsert orgDefaultSetting;
    }

    public static RecordTransferSettings__c getOrgDefaultSetting() {
        return RecordTransferSettings__c.getOrgDefaults();
    }
}