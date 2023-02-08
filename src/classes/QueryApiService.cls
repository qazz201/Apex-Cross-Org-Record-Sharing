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
        return this.generateSObjects(objectName, this.parseQueryObjectResponseAndCacheIt(response));
    }


    /**
     * @description 
    */
    public List<SObject> getRecordsByObjectNameAndIds(String objectName, Set<Id> sourceOrgRecordIds) {
        if (String.isBlank(objectName) || Sets.isEmpty(sourceOrgRecordIds)) return new List<SObject>();
        List<Map<String, Object>> restRecordsForSobjects = new List<Map<String, Object>>();
        Map<Id, Object> cachedRecordByIds = this.getResponseRecordsFromCache(sourceOrgRecordIds);
        Set<Id> filteredIds = sourceOrgRecordIds;

        if (!Maps.isEmpty(cachedRecordByIds)) {
            filteredIds.removeAll(cachedRecordByIds.keySet());
        }

        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPathWithRecordIds(objectName, filteredIds));
        List<Map<String, Object>> parsedResponse = this.parseQueryObjectResponseAndCacheIt(response);

        if (!Maps.isEmpty(cachedRecordByIds)) {
            restRecordsForSobjects.addAll((List<Map<String, Object>>) cachedRecordByIds.values());
        }
        restRecordsForSobjects.addAll(parsedResponse);

        return this.generateSObjects(objectName, restRecordsForSobjects);
    }

    /**
    * @description 
    */
    public List<Map<String, Object>> getResponseRecords(String objectName, Integer limitCount) {
        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPathWithAllFields(objectName, limitCount));
        return this.parseQueryObjectResponseAndCacheIt(response);
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
        SObjectType recordSObjectType = Schema.getGlobalDescribe().get(sObjectName);
        if (recordSObjectType == null) return result; //TODO: THROW ERROR THAT OBJ NOT EXIST ON CURRENT ORG!!!!!!!!!!!!!

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

        return result;
    }

    private List<Map<String, Object>> parseQueryObjectResponseAndCacheIt(HttpResponse response) {
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
        String fieldTypeName = objectField.getDescribe().getType().name();

        System.debug(fieldName + ' __Type=__' + objectField.getDescribe().getType().name());

        if (objectField == null || Ids.isId(fieldValue) || !objectField?.getDescribe().isUpdateable()) {
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

    private String getFormattedQueryPathWithAllFields(String objectName, Integer limitCount) {
        RestQueryBuilder queryBuilder = new RestQueryBuilder(objectName, Constants.Query.ALL_FIELDS);
        queryBuilder.addLimit(limitCount);
        return this.getEndpointPath(queryBuilder.toRestSoql());
    }

    private String getFormattedQueryPathWithRecordIds(String objectName, Set <Id> sourceRecordIds) {
        RestQueryBuilder queryBuilder = new RestQueryBuilder(objectName, Constants.Query.ALL_FIELDS);
        queryBuilder.addCondition(Constants.Query.ID_FIELD, Constants.RestQueryBuilder.OPERATOR_IN, sourceRecordIds);
        return this.getEndpointPath(queryBuilder.toRestSoql());
    }
}