public with sharing class DatatableContainerController extends Controller {

    @AuraEnabled
    public static DataTable.Table getDatatableDataConfig(String objectName,
            Integer visibleRecords,
            Integer visibleColumns,
            Integer offsetValue) {

        DataTable.Table table = new DataTable.Table();
        // if (visibleRecords == null || visibleColumns == null) return table;
        try {
            table = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient()))
                    .buildLwcTableData(objectName, visibleRecords, visibleColumns, offsetValue);
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