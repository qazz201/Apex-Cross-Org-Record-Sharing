public with sharing class QueryApiService extends Api {
    private static QueryApiService instance;
    private SObjectService sObjectService {
        get {
            return sObjectService == null ? sObjectService = new SObjectService() : sObjectService;
        }
        set;
    }
    
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

        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPathWithAllFields(objectName, limitCount, null));
        return this.sObjectService.generateSObjects(objectName, this.parseQueryObjectResponseAndCacheIt(response));
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

        return this.sObjectService.generateSObjects(objectName, restRecordsForSobjects);
    }

    /**
    * @description 
    */
    public List<Map<String, Object>> getResponseRecordsRaw(String objectName, Integer limitCount) {
        return this.getResponseRecordsRaw(objectName, limitCount, null);
    }

    /**
    * @description 
    */
    public List<Map<String, Object>> getResponseRecordsRaw(String objectName, Integer limitCount, Integer offsetValue) {
        HttpResponse response = this.executeGetCallout(this.getFormattedQueryPathWithAllFields(objectName, limitCount, offsetValue));
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

//    private List<SObject> generateSObjects(String sObjectName, List<Map<String, Object>> listFieldNameToValue) {
//        List<SObject> result = new List<SObject>();
//        SObjectType recordSObjectType = Schema.getGlobalDescribe().get(sObjectName);
//
//        if (recordSObjectType == null) {
//            System.debug('ERROR____: record ' + sObjectName + 'does not exist on the current org');
//            throw new QueryApiServiceException(String.format(Label.Api_Lbl_ObjectDoesNotExistOnCurrentOrg, new List<String>{
//                    sObjectName
//            }));
//        }
//
//        Map<String, Schema.SObjectField> sobjectFieldName = recordSObjectType.getDescribe().fields.getMap(); // the object should exist on current org!
//
//        for (Map<String, Object> parsedObj : listFieldNameToValue) {
//            SObject dynamicSObject = recordSObjectType.newSObject();
//
//            for (String fieldName : parsedObj.keySet()) {
//                Schema.SObjectField objectField = sobjectFieldName.get(fieldName);
//                if (objectField == null) continue;
//
//                this.setSObjectFieldValue(
//                        dynamicSObject,
//                        objectField,
//                        fieldName,
//                        parsedObj.get(fieldName)
//                );
//            }
//            result.add(dynamicSObject);
//        }
//
//        // TODO:!!!!
//        if (Lists.isEmpty(result)) {
//            throw new QueryApiServiceException(String.format(Label.SourceOrg_Lbl_ObjectCanNotBeCopied,
//                    new List<String>{
//                            sObjectName
//                    }));
//        }
//        return result;
//    }

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

//    private void setSObjectFieldValue(
//            SObject sObjectToFill,
//            Schema.SObjectField objectField,
//            String fieldName,
//            Object fieldValueObj) {
//
//        String fieldValue = String.valueOf(fieldValueObj);
//        if (String.isBlank(fieldValue)) return; // TODO: remove for record update??
//        String fieldTypeName = objectField.getDescribe().getType().name();
//
//        // System.debug(fieldName + ' __Type=__' + objectField.getDescribe().getType().name());
//
//        if (objectField == null || Ids.isId(fieldValue) || !objectField?.getDescribe().isUpdateable()) {
//            System.debug('Can not update: ' + fieldName);
//            return;
//        } else if (Dates.isDate(fieldValue)) {
//            sObjectToFill.put(fieldName, Dates.getValue(fieldValue));
//            return;
//        } else if (fieldTypeName == String.valueOf(DisplayType.STRING) && Numbers.isDecimal(fieldValue)) {
//            sObjectToFill.put(fieldName, String.ValueOf(fieldValue));
//            return;
//        } else if (fieldTypeName != String.valueOf(DisplayType.STRING) && Numbers.isDecimal(fieldValue)) {
//            sObjectToFill.put(fieldName, Integer.valueOf(Numbers.getDecimalValue(fieldValue)));
//            return;
//        } else if (fieldTypeName == String.valueOf(DisplayType.BOOLEAN)) {
//            sObjectToFill.put(fieldName, Boolean.valueOf(fieldValue));
//            return;
//        }
//
//        sObjectToFill.put(fieldName, fieldValue);
//    }

//    private String getFormattedQueryPathWithAllFields(String objectName, Integer limitCount) {
//        RestQueryBuilder queryBuilder = new RestQueryBuilder(objectName, Constants.Query.ALL_FIELDS);
//        queryBuilder.addLimit(limitCount);
//        return this.getEndpointPath(queryBuilder.toRestSoql());
//    }

    private String getFormattedQueryPathWithAllFields(String objectName, Integer limitCount, Integer offsetValue) {
        if (offsetValue == null) offsetValue = 0;

        RestQueryBuilder queryBuilder = new RestQueryBuilder(objectName, Constants.Query.ALL_FIELDS);
        queryBuilder.addLimit(limitCount)
                .addOrderBy(Constants.Query.CREATED_DATE_FIELD, Constants.RestQueryBuilder.DESC_SORT) //TODO:Does not work properly for ACCOUNT 1111!!!!!!!!!!!!
                .addOffset(offsetValue);
        return this.getEndpointPath(queryBuilder.toRestSoql());
    }

    private String getFormattedQueryPathWithRecordIds(String objectName, Set <Id> sourceRecordIds) {
        RestQueryBuilder queryBuilder = new RestQueryBuilder(objectName, Constants.Query.ALL_FIELDS);
        queryBuilder.addCondition(Constants.Query.ID_FIELD, Constants.RestQueryBuilder.OPERATOR_IN, sourceRecordIds);
        return this.getEndpointPath(queryBuilder.toRestSoql());
    }

    public class QueryApiServiceException extends Exception {
    }
}