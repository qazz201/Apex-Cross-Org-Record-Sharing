# Apex-Cross-Org-Record-Sharing

### Example:

To get all Custom object names from target org:

```javascript
ICallout calloutClient = new CalloutClient();
calloutClient.setEndpoint( RecordTransferCustomSettingService.getOrgDefaultSetting().Instance_Url__c);
calloutClient.setHeader('Authorization', 'Bearer ' +   RecordTransferCustomSettingService.getOrgDefaultSetting().AccessToken__c);

System.debug(new SourceOrgApi(calloutClient).getCustomObjectNames());
```