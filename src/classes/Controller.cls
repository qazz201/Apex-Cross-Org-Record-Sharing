public virtual with sharing class Controller {
    private static ICallout calloutClient = new CalloutClient();

    private static String AUTHORIZATION = 'Authorization';
    private static String BEARER = 'Bearer ';

    public static ICallout getCalloutClient() {
        calloutClient.setEndpoint(
                RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.Instance_Url__c)
        );
        calloutClient.clearAllHeaders();
        calloutClient.setHeader(
                AUTHORIZATION,
                BEARER + RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.AccessToken__c)
        );
        return calloutClient;
    }

}