public with sharing class MasterOrgApi {
    private static CalloutClient calloutClient = new CalloutClient();
    private static final String ROOT_PATH = 'callout:CrossOrgDataTransferNamedCredential';

    private static final String TOOLING_QUERY = 'tooling';
    private static final String QUERY = 'query';
    private static final Map<String, String> apiResources = new Map<String, String>{
            TOOLING_QUERY => '/services/data/v56.0/tooling/query/?q=',
            QUERY => '/services/data/v56.0/query/?q='
    };

    private static final String OBJECT_BY_NAME = 'objectByName';
    private static final String TOOLING_CUSTOM_OBJ = 'toolingObj';
    private static final Map<String, String> queryPatterns = new Map<String, String>{
            OBJECT_BY_NAME => 'SELECT+FIELDS(ALL)+FROM+{0}+LIMIT+{1}',
            TOOLING_CUSTOM_OBJ => 'SELECT+DeveloperName+from+CustomObject'
    };

    public static List<String> getCustomObjectNames() {
        List<String> names = new List<String>();

        calloutClient.setEndpoint(getQueryPath(apiResources.get(TOOLING_QUERY) + queryPatterns.get(TOOLING_CUSTOM_OBJ)));
        HttpResponse response = calloutClient.get();

        if (response.getStatusCode() != 200 || response.getBody() == null) return names;
        System.debug(response.getBody());
        for (Records record : parseToolingQueryResponse(response.getBody()).records) {
            names.add(record.DeveloperName + '__c');
        }

        System.debug(names);
        return names;
    }

    public static List<Object> getRecordsByObjectName(String objectName, Integer limitCount) {
        List<Object> result = new List<Object>();

        if (String.isBlank(objectName)) return result;
        if (limitCount == null || limitCount == 0) limitCount = 200;

        calloutClient.setEndpoint(getQueryPath(apiResources.get(QUERY)
                + String.format(queryPatterns.get(OBJECT_BY_NAME), new List<Object>{
                objectName, limitCount
        })));
        HttpResponse response = calloutClient.get();

        Map<String, Object> valueToFieldNames = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) JSON.deserializeUntyped(JSON.serialize(valueToFieldNames.get('records')));
        //createRecords(records);
        // List<Map<String,Object>> records22 = (List<Map<String,Object>>) JSON.deserializeUntyped(JSON.serialize(valueToFieldNames.get('records')));

        createRecords(records, objectName);

        System.debug(valueToFieldNames.get('records'));
        System.debug(response.getBody());
        System.debug(records);

//        List<sObject> con = (List<Contact>) JSON.deserialize(JSON.serialize(records), List<Contact>.class);
//
//        insert con;
//        System.debug(con);
        //return valueToFieldNames.get('records');
        return null;
    }


    private static List<Sobject> createRecords(List<Object> records, String sObjectName) {
        List<SObject> result = new List<SObject>();
        Map<String, Schema.SObjectField> objectFieldToName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

        for (Object record : records) {
            SObject sObjToCreate = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            Map<String, Object> objValueToFieldName = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));

            for (String fieldName : objValueToFieldName.keySet()) {
                setSObjectFieldValue(sObjToCreate, objectFieldToName.get(fieldName), fieldName, String.valueOf(objValueToFieldName.get(fieldName)));
            }

            System.debug('___ ' + objValueToFieldName);
            result.add(sObjToCreate);
        }

        System.debug('__AAAAAAAA__ ' + result);

        // insert returnList;
        return result;
    }

    private static void setSObjectFieldValue(
            SObject sObjToFill,
            Schema.SObjectField objectField,
            String fieldName,
            String fieldValue) {
            
        if (objectField == null || Ids.isId(fieldValue) || !objectField?.getDescribe().isUpdateable()) return;
        if (Dates.isDate(fieldValue)) {
            sObjToFill.put(fieldName, Dates.getValue(fieldValue));
            return;
        }

        sObjToFill.put(fieldName, fieldValue);

        //TODO: DELETE
        if (fieldValue == 'Pavlova') {
            sObjToFill.put(fieldName, 'Pavlova##2');
        }
    }

    private static String getQueryPath(String apiResource) {
        return ROOT_PATH + apiResource;
    }

    public static ToolingQueryResponse parseToolingQueryResponse(String body) {
        return (ToolingQueryResponse) JSON.deserialize(body, ToolingQueryResponse.class);
    }

    public class ToolingQueryResponse {
        public List<Records>records;
    }

    public class Records {
        public String DeveloperName;
    }
}

// /services/data/v56.0/tooling/sobjects/CustomObject/describe/     //'/services/data/v56.0/query/?q=SELECT+name+from+MyCustomObject__c' // /services/data/v56.0/sobjects/
//'/services/data/v56.0/sobjects/Contact/0036800000G0E5KAAV' // /services/data/v56.0/ui-api/record-defaults/clone/0036800000G0E5KAAV
// services/data/v56.0/sobjects/MyCustomObject__c/describe -get info about object
// https://host/services/data/vXX.0/metadata/deployRequest  https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_rest_deploy.htm

////        while (res.getStatusCode() == 302) {
////            req.setEndpoint(res.getHeader('Location'));
////            res = new Http().send(req);
////         
////        }
// req.setHeader('Content-Type', 'application/json');
//req.setBody('{"hello":true}');