public virtual with sharing class Controller {
    private static ICallout calloutClient = new CalloutClient();

    public static ICallout getCalloutClient() {
        calloutClient.setEndpoint(
                RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.Instance_Url__c)
        );
        calloutClient.clearAllHeaders();
        calloutClient.setHeader(
                Constants.Auth.AUTHORIZATION_HEADER,
                Constants.Auth.BEARER_HEADER
                        + RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.AccessToken__c)
        );
        return calloutClient;
    }
}