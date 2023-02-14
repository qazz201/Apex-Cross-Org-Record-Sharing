public with sharing class SourceOrgApi {
    private RestApiManager restApiManager;
    private ToolingApiService toolingApiService {
        get {
            return toolingApiService == null ? this.restApiManager.toolingApi() : toolingApiService;
        }
        set;
    }

    private QueryApiService queryApiService {
        get {
            return queryApiService == null ? this.restApiManager.queryApi() : queryApiService;
        }
        set;
    }

    private SearchApiService searchApiService {
        get {
            return searchApiService == null ? this.restApiManager.searchApi() : searchApiService;
        }
        set;
    }

    public SourceOrgApi(Auth authProvider) {
        this.restApiManager = new RestApiManager(authProvider);
    }

    //Tooling Api
    public List<String> getCustomObjectNames() {
        return this.toolingApiService.getCustomObjectNames();
    }

    public List<String> getStandardObjectNames() {
        List<String> standardObjectNames = new List<String>();

        for (Schema.SObjectType typ : Schema.getGlobalDescribe().values()) {
            String sobjName = String.valueOf(typ);
            if (sobjName.contains('__c') || sobjName.contains('__x')) continue;
            standardObjectNames.add(sobjName);
        }
        standardObjectNames.sort();
        return standardObjectNames;
    }

    //Search Api
    public List<SObject> searchRecords(String objectName, String searchReq) {
        return this.searchApiService.searchRecords(objectName, searchReq);
    }

    public List<Map<String, Object>> searchRecordsRaw(String objectName, String searchReq) {
        return this.searchApiService.searchRecordsRaw(objectName, searchReq);
    }

    //Query Api
    public List<SObject> transferRecordsFromSourceToCurrentOrg(String objectName, Set<Id> sourceOrgRecordIds) {
        List<SObject> records = this.queryApiService.getRecordsByObjectNameAndIds(objectName, sourceOrgRecordIds);
        insert records;
        return records;
    }

    public List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        return this.queryApiService.getRecordsByObjectName(objectName, limitCount);
    }

    public List<Map<String, Object>> getResponseRecordsRaw(String objectName, Integer limitCount, Integer offsetValue) {
        return this.queryApiService.getResponseRecordsRaw(objectName, limitCount, offsetValue);
    }

//    public DataTable.Table buildLwcTableData(String objectName, Integer limitCount, Integer visibleColumns, Integer offsetValue) {
//        List<Map<String, Object>> recordsAsMap = this.queryApiService.getResponseRecordsRaw(objectName, limitCount, offsetValue);
//        return new DataTable(recordsAsMap, visibleColumns).build();
//    }
}