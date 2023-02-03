public with sharing class SourceOrgRecordsController extends Controller {

    @AuraEnabled
    public static DataTable.Table getDatatableDataConfig(String objectName, Integer recordsToShow, Integer columnsToShow) {
        DataTable.Table table = new DataTable.Table();
        try {
            table = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient()))
                    .buildLwcTableData(objectName, recordsToShow, columnsToShow);
        } catch (Exception ex) {
            System.debug('SourceOrgRecordsController ERROR: ' + ex);
            throw new AuraHandledException(ex.getMessage());
        }
        return table;
    }
}