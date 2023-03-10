public with sharing class DataTable {
    private List<Map<String, Object>> recordsAsMap;
    private Integer visibleColumns;
    private String sourceOrgUrl;

    private Set<String> requiredColumnsInTable = new Set<String>{
            Constants.Query.ID_FIELD,
            Constants.Query.NAME_FIELD
    };

    private Set<String> omitColumns = new Set<String>{
            Constants.Query.ATTRIBUTES_FIELD,
            Constants.Query.IS_DELETED_FIELD,
            Constants.Query.CREATED_BY_ID_FIELD,
            Constants.Query.LAST_MODIFIED_BY_ID_FIELD,
            Constants.Query.SYSTEM_MODSTAMP_FIELD
    };

    public DataTable(List<Map<String, Object>> recordsAsMap, Integer visibleColumns) {
        this.recordsAsMap = recordsAsMap;
        this.visibleColumns = visibleColumns;
        this.sourceOrgUrl = RecordTransferCustomSettingService.getOrgDefaultSettingValueByName(RecordTransferSettings__c.Instance_Url__c);
    }

    public Table build() {
        Table table = new Table();
        if (Lists.isEmpty(this.recordsAsMap) || this.visibleColumns == 0) return table;

        table.columns = this.createColumnsConfig();
        table.data = this.filterRecordFieldsByConfig(table.columns);

        System.debug('Datatable.build() result: ' + table);
        return table;
    }

    private List<DataTableColumnsConfig> createColumnsConfig() {
        List<DataTableColumnsConfig> columnConfig = new List<DataTableColumnsConfig>();
        Map<String, Object> firstRecord = (Map<String, Object>) Lists.getFirst(this.recordsAsMap);

        columnConfig.addAll(this.createRequiredColumnsConfig(firstRecord));
        columnConfig.addAll(this.createNOTRequiredColumnsConfig(firstRecord, this.visibleColumns - this.requiredColumnsInTable.size()));

        return columnConfig;
    }

    private List<Map<String, Object>> filterRecordFieldsByConfig(List<DataTableColumnsConfig> columnsConfig) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (Map<String, Object> record : this.recordsAsMap) {
            Map<String, Object> filteredRecordFields = new Map<String, Object>();

            for (DataTableColumnsConfig config : columnsConfig) {
                String configFieldName = config.fieldName;

//                if (record.containsKey(configFieldName) && configFieldName == 'Name') {
//                    filteredRecordFields.put(configFieldName, this.sourceOrgUrl + '/' + record.get('Id'));
//
//                }
                if (record.containsKey(configFieldName)) {
                    filteredRecordFields.put(configFieldName, record.get(configFieldName));
                }
            }
            result.add(filteredRecordFields);
        }

        return result;
    }

    private List<DataTableColumnsConfig> createRequiredColumnsConfig(Map<String, Object> firstRecord) {
        List<DataTableColumnsConfig> columnConfig = new List<DataTableColumnsConfig>();
        Integer createdColumns = 0;

        for (String requiredField : this.requiredColumnsInTable) {
            if (createdColumns == this.visibleColumns) break;
            if (!firstRecord.containsKey(requiredField)) continue;

            columnConfig.add(this.buildColumnConfig(requiredField));
            createdColumns++;
        }

        return columnConfig;
    }

    private List<DataTableColumnsConfig> createNOTRequiredColumnsConfig(Map<String, Object> firstRecord, Integer columnsToCreate) {
        List<DataTableColumnsConfig> columnConfig = new List<DataTableColumnsConfig>();
        if (columnsToCreate <= 0) return columnConfig;

        Integer createdColumns = 0;

        for (String fieldName : firstRecord.keySet()) {
            if (createdColumns == columnsToCreate) break;
            if (this.requiredColumnsInTable.contains(fieldName) || this.omitColumns.contains(fieldName)) continue;

            columnConfig.add(this.buildColumnConfig(fieldName));
            createdColumns++;
        }
        return columnConfig;
    }

    private DataTableColumnsConfig buildColumnConfig(String fieldName) {
        DataTableColumnsConfig.Builder config = new DataTableColumnsConfig.Builder()
                .setFieldName(fieldName)
                .setLabel(fieldName)
                .setInitialWidth(Constants.DataTable.INITIAL_COLUMN_WIDTH);

        //TODO: delete?
        if (fieldName == Constants.Query.NAME_FIELD) {
            config.setType(Constants.DataTable.URL_TYPE)
                    .setTypeAttributes(
                            new Map<String, Object>{
                                    Constants.DataTable.LABEL_ATTRIBUTE => new Map<String, String>{
                                            Constants.DataTable.FIELD_NAME => fieldName
                                    },
                                    Constants.DataTable.TARGET_ATTRIBUTE => Constants.DataTable.TARGET_BLANC
                            }
                    ); //typeAttributes: {label: { fieldName: 'Name' }, target: '_blank'} },
        }
        return config.build();
    }

    public class Table {
        @AuraEnabled
        public List<DataTableColumnsConfig> columns { get; set; }
        @AuraEnabled
        public List<Map<String, Object>> data { get; set; }

        public Table() {
            this.columns = new List<DataTableColumnsConfig>();
            this.data = new List<Map<String, Object>>();
        }
    }
}