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
    private static final String TOOLING_OBJ = 'toolingObj';
    private static final Map<String, String> queryPatterns = new Map<String, String>{
            OBJECT_BY_NAME => 'SELECT+FIELDS(ALL)+FROM+{0}+LIMIT+{1}',
            TOOLING_OBJ => 'SELECT+DeveloperName+from+CustomObject'
    };

    private static final String RECORD_QUERY_REQUEST = 'SELECT+FIELDS(ALL)+FROM+{0}+LIMIT+{1}';

    public static List<String> getCustomObjectNames() {
        List<String> names = new List<String>();

        calloutClient.setEndpoint(getQueryPath(apiResources.get(TOOLING_QUERY) + queryPatterns.get(TOOLING_OBJ))); // /services/data/v56.0/tooling/sobjects/CustomObject/describe/     //'/services/data/v56.0/query/?q=SELECT+name+from+MyCustomObject__c' // /services/data/v56.0/sobjects/
        HttpResponse res = calloutClient.get();

        if (res.getStatusCode() != 200 || res.getBody() == null) return names;
        ToolingQueryResponse toolingQueryResponses = (ToolingQueryResponse) JSON.deserialize(res.getBody(), ToolingQueryResponse.class);

        for (Records record : toolingQueryResponses.records) {
            names.add(record.DeveloperName + '__c');
        }

        System.debug(names);
        return names;
    }

    public static List<Object> getRecordsByObjectName(String objectName, Integer limitCount) {
        List<Object> result = new List<Object>();

        if (String.isBlank(objectName)) return result;
        if (limitCount == null || limitCount == 0) limitCount = 200;

        calloutClient.setEndpoint(getQueryPath(
                +apiResources.get(QUERY)
                        + String.format(queryPatterns.get(OBJECT_BY_NAME), new List<Object>{
                        objectName, limitCount
                })));//'/services/data/v56.0/sobjects/Contact/0036800000G0E5KAAV' // /services/data/v56.0/ui-api/record-defaults/clone/0036800000G0E5KAAV
        HttpResponse res = calloutClient.get();


        System.debug(res.getBody());
        System.debug(res.getStatus());
        System.debug(res.getHeader('Location'));
        System.debug(res.getHeaderKeys());
        return result;
    }

    private static String getQueryPath(String apiResource) {
        return ROOT_PATH + apiResource;
    }

    public class ToolingQueryResponse {
        public List<Records>records;
    }

    public class Records {
        public String DeveloperName;
    }
}

// services/data/v56.0/sobjects/MyCustomObject__c/describe -get info about object
// https://host/services/data/vXX.0/metadata/deployRequest  https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_rest_deploy.htm

////        while (res.getStatusCode() == 302) {
////            req.setEndpoint(res.getHeader('Location'));
////            res = new Http().send(req);
////         
////        }
// req.setHeader('Content-Type', 'application/json');
//req.setBody('{"hello":true}');