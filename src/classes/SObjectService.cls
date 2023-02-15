public with sharing class SObjectService {
    private static SObjectService instance;

    public SObjectService() {
    }

    /**
    * @description Singleton
    */
    public static SObjectService getInstance() {
        if (instance == null) {
            instance = new SObjectService();
        }
        return instance;
    }

    /**
    * @description 
    */
    public List<SObject> generateSObjects(String sObjectName, List<Map<String, Object>> listFieldNameToValue) {
        List<SObject> result = new List<SObject>();
        if (Lists.isEmpty(listFieldNameToValue)) return result;

        SObjectType recordSObjectType = Schema.getGlobalDescribe().get(sObjectName);

        if (recordSObjectType == null) {
            throw new SObjectServiceException(String.format(Label.Api_Lbl_ObjectDoesNotExistOnCurrentOrg, new List<String>{
                    sObjectName
            }));
        }

        Map<String, Schema.SObjectField> sobjectFieldName = recordSObjectType.getDescribe().fields.getMap(); // the object should exist on current org!

        for (Map<String, Object> parsedObj : listFieldNameToValue) {
            SObject dynamicSObject = recordSObjectType.newSObject();

            for (String fieldName : parsedObj.keySet()) {
                Schema.SObjectField objectField = sobjectFieldName.get(fieldName);
                if (objectField == null) continue;

                this.setSObjectFieldValue(
                        dynamicSObject,
                        objectField,
                        fieldName,
                        parsedObj.get(fieldName)
                );
            }
            result.add(dynamicSObject);
        }

        if (Lists.isEmpty(result)) {
            throw new SObjectServiceException(String.format(Label.SourceOrg_Lbl_ObjectCanNotBeCopied,
                    new List<String>{
                            sObjectName
                    }));
        }
        return result;
    }

    private void setSObjectFieldValue(
            SObject sObjectToFill,
            Schema.SObjectField objectField,
            String fieldName,
            Object fieldValueObj) {

        String fieldValue = String.valueOf(fieldValueObj);
        if (String.isBlank(fieldValue)) return;
        String fieldTypeName = objectField.getDescribe().getType().name();

        if (objectField == null || Ids.isId(fieldValue) || !objectField?.getDescribe().isUpdateable()) {
            System.debug('Can not update: ' + fieldName);
            return;
        } else if (Dates.isDate(fieldValue)) {
            sObjectToFill.put(fieldName, Dates.getValue(fieldValue));
            return;
        } else if (fieldTypeName == String.valueOf(DisplayType.STRING) && Numbers.isDecimal(fieldValue)) {
            sObjectToFill.put(fieldName, String.ValueOf(fieldValue));
            return;
        } else if (fieldTypeName != String.valueOf(DisplayType.STRING) && Numbers.isDecimal(fieldValue)) {
            sObjectToFill.put(fieldName, Integer.valueOf(Numbers.getDecimalValue(fieldValue)));
            return;
        } else if (fieldTypeName == String.valueOf(DisplayType.BOOLEAN)) {
            sObjectToFill.put(fieldName, Boolean.valueOf(fieldValue));
            return;
        }

        sObjectToFill.put(fieldName, fieldValue);
    }

    public class SObjectServiceException extends Exception {
    }
}