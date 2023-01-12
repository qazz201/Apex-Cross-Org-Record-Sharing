public with sharing class MasterOrgApi {
    private static CalloutClient calloutClient = new CalloutClient();
    private static final String ROOT_PATH = 'callout:CrossOrgDataTransferNamedCredential';

    private static final String TOOLING = 'tooling';
    private static final String QUERY = 'query';

    private static final Map<String, String> apiResources = new Map<String, String>{
            TOOLING => '/services/data/v56.0/tooling/query/?q=',
            QUERY => '/services/data/v56.0/query/?q='
    };

///services/data/v56.0/sobjects/MyCustomObject__c/describe -get info about object

    public static List<String> getCustomObjectNames() {
        List<String> names = new List<String>();

        calloutClient.setEndpoint(ROOT_PATH + apiResources.get(TOOLING) + 'SELECT+DeveloperName+from+CustomObject'); // /services/data/v56.0/tooling/sobjects/CustomObject/describe/     //'/services/data/v56.0/query/?q=SELECT+name+from+MyCustomObject__c' // /services/data/v56.0/sobjects/
        HttpResponse res = calloutClient.get();

        if (res.getStatusCode() != 200 || res.getBody() == null) return names;

        System.debug(res.getBody());

        return names;
    }

    public static void metadataCall() {
        HttpRequest req = new HttpRequest();
        req.setEndpoint(ROOT_PATH + '/services/data/v56.0/query/?q=SELECT+FIELDS(ALL)+FROM+Account+LIMIT+10');//'/services/data/v56.0/sobjects/Contact/0036800000G0E5KAAV' // /services/data/v56.0/ui-api/record-defaults/clone/0036800000G0E5KAAV
        req.setMethod('GET');
        //req.setHeader('Authorization', 'Bearer token');
        req.setHeader('Authorization', 'Bearer ' + UserInfo.getSessionID());
        // req.setHeader('Content-Type', 'application/json');
        //req.setBody('{"hello":true}');

        Http http = new Http();
        HTTPResponse res = http.send(req);

//        while (res.getStatusCode() == 302) {
//            req.setEndpoint(res.getHeader('Location'));
//            res = new Http().send(req);
//         
//        }

        System.debug(res.getBody());
        System.debug(res.getStatus());
        System.debug(res.getHeader('Location'));
        System.debug(res.getHeaderKeys());
    }
}

// https://host/services/data/vXX.0/metadata/deployRequest  https://developer.salesforce.com/docs/atlas.en-us.api_meta.meta/api_meta/meta_rest_deploy.htm

////        while (res.getStatusCode() == 302) {
////            req.setEndpoint(res.getHeader('Location'));
////            res = new Http().send(req);
////         
////        }