public with sharing class DataTable {
    private List<Map<String, Object>> recordsAsMap;
    private Integer columnsToShow;

    private Set<String> requiredColumnsInTable = new Set<String>{
            'Id', 'Name', 'Type'
    };

    private Set<String> omitColumn = new Set<String>{
            'attributes', 'IsDeleted'
    };

    public DataTable(List<Map<String, Object>> recordsAsMap, Integer columnsToShow) {
        if (Lists.isEmpty(recordsAsMap) || columnsToShow == 0) return;
        this.recordsAsMap = recordsAsMap;
        this.columnsToShow = columnsToShow;
    }

    public Table build() {
        Table table = new Table();
        table.columns = this.createColumnsConfig();
        table.data = this.filterRecordFieldsByConfig(table.columns);

        System.debug('DATATABLE___');
        System.debug(table);
        return table;
    }

    private List<DataTableColumnsConfig> createColumnsConfig() {
        List<DataTableColumnsConfig> columnConfig = new List<DataTableColumnsConfig>();
        Map<String, Object> firstRecord = (Map<String, Object>) Lists.getFirst(this.recordsAsMap);

        columnConfig.addAll(this.createRequiredColumnsConfig(firstRecord));
        columnConfig.addAll(this.createNOTRequiredColumnsConfig(firstRecord, this.columnsToShow - this.requiredColumnsInTable.size()));

        return columnConfig;
    }

    private List<Map<String, Object>> filterRecordFieldsByConfig(List<DataTableColumnsConfig> columnsConfig) {
        List<Map<String, Object>> result = new List<Map<String, Object>>();

        for (Map<String, Object> record : this.recordsAsMap) {
            Map<String, Object> filteredRecordFields = new Map<String, Object>();

            for (DataTableColumnsConfig config : columnsConfig) {
                String configFieldName = config.fieldName;

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
            if (createdColumns == this.columnsToShow) break;
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
            if (this.requiredColumnsInTable.contains(fieldName) || this.omitColumn.contains(fieldName)) continue;

            columnConfig.add(this.buildColumnConfig(fieldName));
            createdColumns++;
        }
        return columnConfig;
    }

    private DataTableColumnsConfig buildColumnConfig(String fieldName) {
        return new DataTableColumnsConfig.Builder()
                .setFieldName(fieldName)
                .setLabel(fieldName)
                .build();
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