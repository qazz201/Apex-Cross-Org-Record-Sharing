public with sharing class DataTable {
    private List<Map<String, Object>> recordsAsMap;
    private Integer columnsToShow;
    private Set<String> requiredColumnsToShow = new Set<String>{
            'Id', 'Name'
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
        Integer columnsCreated = 0;

        for (String fieldName : firstRecord.keySet()) {
            if (columnsCreated == this.columnsToShow) break;

            columnConfig.add(
                    new DataTableColumnsConfig.Builder()
                            .setFieldName(fieldName)
                            .setLabel(fieldName)
                            .build()
            );
            columnsCreated++;
        }

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

    public class ColumnItem {
        @AuraEnabled
        public String label { get; set; }
        @AuraEnabled
        public String fieldName { get; set; }
        @AuraEnabled
        public String type { get; set; }
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