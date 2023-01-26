public with sharing class RecordTransferCustomSettingService {

    public static void setOrgDefaultCustomSetting(String fieldName, String fieldValue) {
        setOrgDefaultCustomSetting(new Map<String, String>{
                fieldName => fieldValue
        });
    }
    
    public static void setOrgDefaultCustomSetting(Map<String, String> fieldNameToValue) {
        RecordTransferSettings__c orgDefaultSetting = getOrgDefaultCustomSetting();

        for (String fieldName : fieldNameToValue.keySet()) {
            orgDefaultSetting.put(fieldName, fieldNameToValue.get(fieldName));
        }

        upsert orgDefaultSetting;
    }

    public static RecordTransferSettings__c getOrgDefaultCustomSetting() {
        return RecordTransferSettings__c.getOrgDefaults();
    }
}