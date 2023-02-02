public with sharing class DataTable {
    private List<Map<String, Object>> recordsAsMap;
    private Integer columnsToShow;

    public DataTable(List<Map<String, Object>> recordsAsMap, Integer columnsToShow) {
        if (Lists.isEmpty(recordsAsMap) || columnsToShow == 0) return;
        this.recordsAsMap = recordsAsMap;
        this.columnsToShow = columnsToShow;
    }

    public void build() {
        System.debug('DATATABLE___');
        System.debug(this.createColumnsConfig());
    }

    private List<DataTableColumnsConfig> createColumnsConfig() {
        List<DataTableColumnsConfig> columnConfig = new List<DataTableColumnsConfig>();
        Map<String, Object> firstRecord = (Map<String, Object>) Lists.getFirst(this.recordsAsMap);
        Integer columnsCreated = 0;

        for (String fieldNAme : firstRecord.keySet()) {
            if (columnsCreated == this.columnsToShow) break;

            columnConfig.add(
                    new DataTableColumnsConfig.Builder()
                            .setFieldName(fieldNAme)
                            .setLabel(fieldNAme)
                            .build()
            );
            columnsCreated++;
        }

        return columnConfig;
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
        public List<ColumnItem> columns { get; set; }
        @AuraEnabled
        public List<Map<String, Object>> data { get; set; }

        public Table() {
            this.columns = new List<ColumnItem>();
            this.data = new List<Map<String, Object>>();
        }
    }
}