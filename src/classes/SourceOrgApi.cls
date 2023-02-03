public with sharing class SourceOrgApi {
    private RestApiManager restApiManager;

    public SourceOrgApi(Auth authProvider) {
        this.restApiManager = new RestApiManager(authProvider);
    }

    public List<String> getCustomObjectNames() {
        return this.restApiManager.toolingApi().getCustomObjectNames();
    }

    public List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        return this.restApiManager.queryApi().getRecordsByObjectName(objectName, limitCount);
    }

    public DataTable.Table buildLwcTableData(String objectName, Integer limitCount, Integer visibleColumns) { //List<Map<String, Object>>
        List<Map<String, Object>> recordsAsMap = this.restApiManager.queryApi().getRecordsAsMap(objectName, limitCount);
        return new DataTable(recordsAsMap, visibleColumns).build();
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