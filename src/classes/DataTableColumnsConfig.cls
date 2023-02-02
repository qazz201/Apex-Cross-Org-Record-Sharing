public with sharing class DataTableColumnsConfig {
    @AuraEnabled
    public String type { get; set; }
    @AuraEnabled
    public String label { get; set; }
    @AuraEnabled
    public String fieldName { get; set; }

    public DataTableColumnsConfig() {
        this.type = 'text';
    }

    public class Builder {
        private DataTableColumnsConfig config;

        public Builder() {
            this.config = new DataTableColumnsConfig();
        }
        
        public DataTableColumnsConfig build() {
            return config;
        }
        public Builder setType(String typeValue) {
            config.type = typeValue;
            return this;
        }
        public Builder setLabel(String labelValue) {
            config.label = labelValue;
            return this;
        }
        public Builder setFieldName(String fieldName) {
            config.fieldName = fieldName;
            return this;
        }
    }

//    public class ColumnItem {
//        @AuraEnabled
//        public String label { get; set; }
//        @AuraEnabled
//        public String fieldName { get; set; }
//        @AuraEnabled
//        public String type { get; set; }
//    }
}