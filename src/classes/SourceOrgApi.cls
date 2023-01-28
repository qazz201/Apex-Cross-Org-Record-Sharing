public with sharing class SourceOrgApi {
//    private static final String ROOT_PATH = 'callout:CrossOrgDataTransferNamedCredential';
//    private static RestApiManager restApiManager = new RestApiManager(new CalloutClient(), ROOT_PATH);
    private RestApiManager restApiManager;


    public SourceOrgApi(ICallout calloutClient) {
        this.restApiManager = new RestApiManager(calloutClient);
    }

    public List<String> getCustomObjectNames() {
        return restApiManager.toolingApi().getObjectNames(); //todo make api as variable ar make singleton!
    }

    public List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        return restApiManager.queryApi().getRecordsByObjectName(objectName, limitCount); //todo make api as variable!
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