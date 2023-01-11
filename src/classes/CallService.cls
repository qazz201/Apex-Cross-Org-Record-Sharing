public with sharing class CallService {
    private static final String ROOT_PATH = 'callout:CrossOrgDataTransferNamedCredential';

    public static void call() {

        HttpRequest req = new HttpRequest();
        req.setEndpoint(ROOT_PATH + '/services/data/v56.0/query/?q=SELECT+name+from+Contact');
        req.setMethod('GET');
        req.setHeader('Authorization', 'Bearer token');

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