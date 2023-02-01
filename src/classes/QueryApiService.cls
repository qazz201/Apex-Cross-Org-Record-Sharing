public with sharing class QueryApiService extends Api {
    // Path
    private final String QUERY_API_ROOT_PATH = '/services/data/v56.0/query/?q=';

    // Default query
    private final String SELECT_OBJECT_BY_NAME = 'SELECT+FIELDS(ALL)+FROM+{0}+LIMIT+{1}';
    private Integer DEFAULT_QUERY_LIMIT = 200;

    public QueryApiService(ICallout calloutClient) {
        super(calloutClient);
    }

    public QueryApiService(Auth authProvider) {
        super(authProvider);
    }

    protected override String getApiPath() {
        return this.QUERY_API_ROOT_PATH;
    }

    /**
     * @description 
    */
    public override List<SObject> getRecordsByObjectName(String objectName, Integer limitCount) {
        if (String.isBlank(objectName)) return new List<SObject>();
        if (limitCount == 0 || limitCount == null) {
            limitCount = this.DEFAULT_QUERY_LIMIT;
        }

        HttpResponse response = this.executeGetCallout(
                this.getEndpointPath(
                        String.format(this.SELECT_OBJECT_BY_NAME, new List<Object>{
                                objectName, limitCount
                        })
                )
        );
        return this.createSObjectsFromQueryResponse(response, objectName);
    }

    private List<SObject> createSObjectsFromQueryResponse(HttpResponse response, String sObjectName) {
        List<SObject> result = new List<SObject>();

        Map<String, Object> valueToFieldNames = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
        List<Object> records = (List<Object>) JSON.deserializeUntyped(JSON.serialize(valueToFieldNames.get('records')));
        Map<String, Schema.SObjectField> objectFieldToName = Schema.getGlobalDescribe().get(sObjectName).getDescribe().fields.getMap();

        for (Object record : records) {
            SObject dynamicSObject = Schema.getGlobalDescribe().get(sObjectName).newSObject();
            Map<String, Object> objValueToFieldName = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(record));

            for (String fieldName : objValueToFieldName.keySet()) {
                this.setSObjectFieldValue(
                        dynamicSObject,
                        objectFieldToName.get(fieldName),
                        fieldName,
                        objValueToFieldName.get(fieldName)
                );
            }
            result.add(dynamicSObject);
        }

        return result;
    }

    private void setSObjectFieldValue(
            SObject sObjectToFill,
            Schema.SObjectField objectField,
            String fieldName,
            Object fieldValueObj) {

        String fieldValue = String.valueOf(fieldValueObj);
        if (String.isBlank(fieldValue)) return; // TODO: remove for record update??

        if (objectField == null || Ids.isId(fieldValue) || !objectField?.getDescribe().isUpdateable()) return;
        if (Dates.isDate(fieldValue)) {
            sObjectToFill.put(fieldName, Dates.getValue(fieldValue));
            return;
        }

        sObjectToFill.put(fieldName, fieldValue);
    }
}