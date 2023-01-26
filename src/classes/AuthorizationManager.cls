public with sharing class AuthorizationManager {
    //private ICallout calloutClient = new CalloutClient();

    public void sfAuthorization() {
        try {
            ICallout calloutClient = new CalloutClient();
            SfWebFlowAuthProvider authProvider = new SfWebFlowAuthProvider(
                    RecordTransferCustomSettingService.getOrgDefaultCustomSetting().AuthorizationCode__c,
                    calloutClient
            );

            authProvider.authenticate();
            if (authProvider.getAccessToken() == null) {
                System.debug('ERRRORR___ ');
                return;
            }

            calloutClient.setEndpoint(authProvider.getInstanceUrl());
            calloutClient.setHeader('Authorization', 'Bearer ' + authProvider.getAccessToken());

            System.debug(new SourceOrgApi(calloutClient).getCustomObjectNames());
            RecordTransferCustomSettingService.setOrgDefaultCustomSetting('AccessToken__c', authProvider.getAccessToken());

            System.debug(calloutClient);
        } catch (SfWebFlowAuthProvider.SfWebFlowAuthProviderException ex) {
            System.debug('User Should pass new auth code!');
        }
    }
}