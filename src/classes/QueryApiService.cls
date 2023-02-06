public with sharing class QueryApiService extends Api {
    private static QueryApiService instance;

    private Integer DEFAULT_QUERY_LIMIT = 200;
    private static Map<Id, Object> responseRecordsCache = new Map<Id, Object>();

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

//    /**
//    * @description 
//    */
//    public Map<Id, Object> getCache() {
//        return responseRecordsCache;
//    }

    /**
    * @description 
    */
    public List<Map<String, Object>> getRecordsAsMap(String objectName, Integer limitCount) {
        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPathWithAllFields(objectName, limitCount));
        return this.parseQueryObjectResponse(response);
    }

    /**
    * @description 
    */
    public Map<Id, Object> getResponseRecordsFromCache(Set<Id> sourceOrgRecordIds) {
        Map<Id, Object> cachedRecords = new Map<Id, Object>();
        if (Maps.isEmpty(responseRecordsCache)) return cachedRecords;

        for (Id recordId : sourceOrgRecordIds) {
            if (!responseRecordsCache.containsKey(recordId)) continue;
            cachedRecords.put(recordId, responseRecordsCache.get(recordId));
        }
        return cachedRecords;
    }

    /**
     * @description 
    */
    public List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        if (String.isBlank(objectName)) return new List<SObject>();
        if (limitCount == 0 || limitCount == null) {
            limitCount = this.DEFAULT_QUERY_LIMIT;
        }

        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPathWithAllFields(objectName, limitCount));
        return this.generateSObjects(objectName, this.parseQueryObjectResponse(response));
    }

    /**
     * @description 
    */
    public List<SObject> getRecordsByObjectNameAndIds(String objectName, Set<Id> sourceOrgRecordIds) {
        // a02IY000001412vYAA BoardActivityType__c
        // https://brave-fox-wwflpc-dev-ed.my.salesforce.com/services/data/v56.0/query/?q=SELECT+FIELDS(ALL)+FROM+Contact+WHERE+Id+In('003IY000001pZfxYAE','003IY000001pZfyYAE')
        //
        //
        //
        //
        //
        //
        return null;
    }

    private void addResponseRecordsToCache(List<Map<String, Object>> parsedRecordsResponse) {
        if (Lists.isEmpty(parsedRecordsResponse)) return;

        for (Map<String, Object> sourceOrgRecord : parsedRecordsResponse) {
            for (String field : sourceOrgRecord.keySet()) {
                if (field != Constants.Query.ID_FIELD) continue;
                Id fieldIdValue = Id.valueOf((String) sourceOrgRecord.get(field));
                if (responseRecordsCache.containsKey(fieldIdValue)) continue;

                responseRecordsCache.put(fieldIdValue, sourceOrgRecord);// TODO: handle Cache Size
            }
        }
        System.debug('Records Ids Cache: ' + responseRecordsCache.keySet());
    }

    private List<SObject> generateSObjects(String sObjectName, List<Map<String, Object>> listFieldNameToValue) {
        List<SObject> result = new List<SObject>();
        Map<String, Schema.SObjectField> sobjectFieldName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap(); // the object should exist on current org!

        for (Map<String, Object> parsedObj : listFieldNameToValue) {
            SObject dynamicSObject = Schema.getGlobalDescribe().get(sObjectName).newSObject();

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

        return result;
    }

    private List<Map<String, Object>> parseQueryObjectResponse(HttpResponse response) {
        // map of field name to value
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        Map<String, Object> valueToFieldNames = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) JSON.deserializeUntyped(JSON.serialize(valueToFieldNames.get(Constants.Api.RECORDS)));

        for (Object record : records) {
            Map<String, Object> objValueToFieldName = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));
            result.add(objValueToFieldName);
        }

        this.addResponseRecordsToCache(result);
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

    private String getFormattedQueryPathWithAllFields(String objectName, Integer limitCount) {
        RestQueryBuilder queryBuilder = new RestQueryBuilder(objectName, Constants.Query.ALL_FIELDS);
        queryBuilder.addLimit(limitCount);
        return this.getEndpointPath(queryBuilder.toRestSoql());
    }
}