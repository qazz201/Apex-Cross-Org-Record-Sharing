public with sharing class SearchApiService extends Api {
    private static SearchApiService instance;
    private SObjectService sObjectService = new SObjectService();//TODO: SObjectService.getInstance()

    public SearchApiService(ICallout calloutClient) {
        super(calloutClient);
    }

    public SearchApiService(Auth authProvider) {
        super(authProvider);
    }

    protected override String getApiPath() {
        return Constants.Api.SEARCH_API_ROOT_PATH;
    }

    /**
    * @description Singleton
    */
    public static SearchApiService getInstance(Auth authProvider) {
        if (instance == null) {
            instance = new SearchApiService(authProvider);
        }
        return instance;
    }

    /**
    * @description 
    */
    public List<SObject> searchRecords(String sObjectName, String searchReq) {
        return this.sObjectService.generateSObjects(sObjectName, this.searchRecordsRaw(sObjectName, searchReq));
    }

    /**
    * @description 
    */
    public List<Map<String, Object>> searchRecordsRaw(String sObjectName, String searchReq) {
        if (String.isBlank(sObjectName) || String.isBlank(searchReq)) return null;
        if (searchReq.containsAny(Constants.Sosl.SPECIAL_CHARS)) {
            throw new SearchApiServiceException(String.format(Label.Api_Lbl_ForbiddenChars, new List<String>{
                    Constants.Sosl.SPECIAL_CHARS
            }));
        }

        String pathSearchQuery = this.getEndpointPath(String.format(Constants.Sosl.SOSL_SEARCH_TEMPLATE, new List<String>{
                searchReq, sObjectName
        }));
        HttpResponse response = this.executeGetCallout(pathSearchQuery);
        return this.getSearchRecordsKeyFromResponse(response);
    }

    private List<Map<String, Object>> getSearchRecordsKeyFromResponse(HttpResponse response) {
        Map<String, Object> valueToFieldNames = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> searchRecordsRaw = (List<Object>) JSON.deserializeUntyped(JSON.serialize(valueToFieldNames.get(Constants.Api.SEARCH_RECORDS)));
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (Object record : searchRecordsRaw) {
            Map<String, Object> objValueToFieldName = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));
            result.add(objValueToFieldName);
        }
        return result;
    }

    public class SearchApiServiceException extends Exception {
    }

}