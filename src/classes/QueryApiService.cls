public with sharing class QueryApiService extends Api {
    private static QueryApiService instance;
    
    private Integer DEFAULT_QUERY_LIMIT = 200;

    public QueryApiService(ICallout calloutClient) {
        super(calloutClient);
    }

    public QueryApiService(Auth authProvider) {
        super(authProvider);
    }

    protected override String getApiPath() {
        return Constants.Api.QUERY_API_ROOT_PATH;
    }

    /**
    * @description 
    */
    public static QueryApiService getInstance(Auth authProvider) {
        if (instance == null) {
            instance = new QueryApiService(authProvider);
        }
        return instance;
    }


    /**
      * @description 
    */
    public List<Map<String, Object>> getRecordsAsMap(String objectName, Integer limitCount) {
        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPath(objectName, limitCount));
        return this.parseQueryObjectResponse(response);
    }

    /**
      * @description 
    */
    public List<SObject> saveRecordsByObjectName(String objectName, Integer limitCount) {
        List<SObject> sObjects = this.getRecordsByObjectName(objectName, limitCount);
        insert sObjects; //todo: use database.insert
        return sObjects;
    }

    /**
     * @description 
    */
    public List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        if (String.isBlank(objectName)) return new List<SObject>();
        if (limitCount == 0 || limitCount == null) {
            limitCount = this.DEFAULT_QUERY_LIMIT;
        }

        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPath(objectName, limitCount));

        return this.generateSObjectsFromQueryResponse(response, objectName);
    }

    /**
     * @description 
    */
    public List<SObject> generateSObjectsFromQueryResponse(HttpResponse response, String sObjectName) {
        List<SObject> result = new List<SObject>();
        Map<String, Schema.SObjectField> objectFieldToName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap(); // the object should exist on current org!
        List<Map<String, Object>> listFieldNameToValue = this.parseQueryObjectResponse(response);

        for (Map<String, Object> parsedObj : listFieldNameToValue) {
            SObject dynamicSObject = Schema.getGlobalDescribe().get(sObjectName).newSObject();

            for (String fieldName : parsedObj.keySet()) {
                Schema.SObjectField objectField = objectFieldToName.get(fieldName);
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

        return result;
    }

    private List<Map<String, Object>> parseQueryObjectResponse(HttpResponse response) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        Map<String, Object> valueToFieldNames = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) JSON.deserializeUntyped(JSON.serialize(valueToFieldNames.get('records')));

        for (Object record : records) {
            Map<String, Object> objValueToFieldName = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));
            result.add(objValueToFieldName);
        }
        return result;
    }

    private void setSObjectFieldValue(
            SObject sObjectToFill,
            Schema.SObjectField objectField,
            String fieldName,
            Object fieldValueObj) {

        String fieldValue = String.valueOf(fieldValueObj);
        if (String.isBlank(fieldValue)) return; // TODO: remove for record update??

        if (objectField == null || Ids.isId(fieldValue) || !objectField?.getDescribe().isUpdateable()) return;
        if (Dates.isDate(fieldValue)) {
            sObjectToFill.put(fieldName, Dates.getValue(fieldValue));
            return;
        }
        sObjectToFill.put(fieldName, fieldValue);
    }

    private String getFormattedQueryPath(String objectName, Integer limitCount) {
        return this.getEndpointPath(
                String.format(Constants.Api.QUERY_OBJECT_BY_NAME_WITH_ALL_FIELDS, new List<Object>{
                        objectName, limitCount
                })
        );
    }
}