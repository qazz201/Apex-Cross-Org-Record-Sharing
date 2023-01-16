public with sharing class QueryApi implements IQueryApi {
    private QueryApiService queryApiService;


    public QueryApi(ICalloutClient calloutClient, String endpointDomain) {
//        super(calloutClient, endpointDomain);
        this.queryApiService = new QueryApiService(calloutClient, endpointDomain);
    }
//    public QueryApi setLimitCount(Integer limitCount) {
//        this.limitCount = limitCount;
//        return QueryApi;
//    }

    public List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        return this.queryApiService.getRecordsByObjectNameAndDefaultQuery(objectName, limitCount);
    }

    public List<SObject> getRecordsByObjectNameAndQuery(String objectName, String customQuery) {
        return null;
    }
}