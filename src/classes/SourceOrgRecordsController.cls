public with sharing class SourceOrgRecordsController extends Controller {

    @AuraEnabled
    public static DataTable.Table getDatatableDataConfig(String objectName, Integer visibleRecords, Integer visibleColumns) {
        DataTable.Table table = new DataTable.Table();
        // if (visibleRecords == null || visibleColumns == null) return table;
        try {
            table = new SourceOrgApi(new SfWebFlowAuthProvider(getCalloutClient()))
                    .buildLwcTableData(objectName, visibleRecords, visibleColumns);
        } catch (Exception ex) {
            System.debug('SourceOrgRecordsController ERROR: ' + ex.getStackTraceString());

            //TODO: REWRITE!!!!!
            if (ex.getMessage().contains('is not supported')) {
                throw new AuraHandledException(String.format(Label.SourceOrg_Lbl_ObjectCanNotBeCopied,
                        new List<String>{
                                objectName
                        }));
            }
            throw new AuraHandledException(ex.getMessage());
        }
        return table;
    }
}