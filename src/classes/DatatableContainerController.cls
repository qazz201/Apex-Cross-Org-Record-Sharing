public with sharing class DatatableContainerController extends Controller {
    private static SourceOrgApi sourceOrgApi = new SourceOrgApi(getSfWebFlowAuthProvider());

    @AuraEnabled
    public static DataTable.Table getDatatableDataConfig(String objectName,
            Integer visibleRecords,
            Integer visibleColumns,
            Integer offsetValue,
            String searchQuery) {

        DataTable.Table table = new DataTable.Table();

        try {
            List<Map<String, Object>> rawRecords = new List<Map<String, Object>>();

            if (String.isNotBlank(searchQuery)) {
                rawRecords = sourceOrgApi.searchRecordsRaw(objectName, searchQuery);
            } else {
                rawRecords = sourceOrgApi.getResponseRecordsRaw(objectName, visibleRecords, offsetValue);
            }

            table = new DataTable(rawRecords, visibleColumns).build();
        } catch (Exception ex) {
            exceptionHandler(ex, objectName);
        }
        return table;
    }

    private static void exceptionHandler(Exception ex, String objectName) {
        System.debug('SourceOrgRecordsController ERROR: ' + ex.getStackTraceString());
        String message = ex.getMessage();

        if (message.contains(Label.Api_Lbl_NotSupported) || message.contains(Constants.Query.CREATED_DATE_FIELD)) {
            throw new AuraHandledException(String.format(Label.SourceOrg_Lbl_ObjectCanNotBeCopied,
                    new List<String>{
                            objectName
                    }));
        }

        throw new AuraHandledException(message);
    }
}