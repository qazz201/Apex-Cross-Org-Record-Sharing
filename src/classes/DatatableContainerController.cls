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
            System.debug('SourceOrgRecordsController ERROR: ' + ex.getStackTraceString());

            //TODO: REWRITE!!!!!
            if (ex.getMessage().contains(Label.Api_Lbl_NotSupported)) {
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