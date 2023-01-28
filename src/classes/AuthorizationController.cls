public with sharing class AuthorizationController {

    @AuraEnabled
    public static void saveConnectedAppAuthParams(String authCode, String clientId, String clientSecret, String callbackUrl) {
        RecordTransferCustomSettingService.setOrgDefaultSetting(new Map<SObjectField, String>{
                RecordTransferSettings__c.AuthorizationCode__c => authCode,
                RecordTransferSettings__c.Client_Id__c => clientId,
                RecordTransferSettings__c.ClientSecret__c => clientSecret,
                RecordTransferSettings__c.RedirectUri__c => callbackUrl
        });
        
        System.debug(authCode);
        System.debug(clientId);
        System.debug(clientSecret);
        System.debug(callbackUrl);
    }
}