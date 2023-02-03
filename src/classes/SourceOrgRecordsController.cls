public with sharing class SourceOrgRecordsController extends Controller {

    @AuraEnabled
    public static DataTable.Table getDatatableDataConfig(String objectName, Integer visibleRecords, Integer visibleColumns) {
        DataTable.Table table = new DataTable.Table();
        try {
            table = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient()))
                    .buildLwcTableData(objectName, visibleRecords, visibleColumns);
        } catch (Exception ex) {
            System.debug('SourceOrgRecordsController ERROR: ' + ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return table;
    }
}