public with sharing class RestQueryBuilder {
    private String sObjectName;
    private List<String> restQueryFields;
    private String whereCondition = '';
    private String limitCondition = '';
    private String offsetCondition = '';
    private String orderByCondition = '';

    public RestQueryBuilder(String sObjectName, List<String>queryFields) {
        this.sObjectName = sObjectName;
        this.restQueryFields = queryFields;
    }

    public RestQueryBuilder(String sObjectName, String queryField) {
        this.sObjectName = sObjectName;
        this.restQueryFields = new List<String>{
                queryField
        };
    }

    /**
     * @description 
    */
    public String toRestSoql() {
        String selectClause = this.formSelectTemplate();
        String whereClause = this.formWhereTemplate();
        return selectClause + whereClause + this.orderByCondition + this.limitCondition + this.offsetCondition;
    }

    /**
     * @description 
    */
    public RestQueryBuilder addCondition(String field, String operator, String value) {
        if (String.isBlank(this.whereCondition)) {
            this.whereCondition = field
                    + Constants.RestQueryBuilder.PLUS_SIGN
                    + operator
                    + Constants.RestQueryBuilder.PLUS_SIGN
                    + value;
            return this;
        }

        this.whereCondition += Constants.RestQueryBuilder.PLUS_SIGN
                + field
                + Constants.RestQueryBuilder.PLUS_SIGN
                + operator
                + Constants.RestQueryBuilder.PLUS_SIGN
                + value;
        return this;
    }


    /**
  * @description 
 */
    public RestQueryBuilder addCondition(String field, String operator, Set<Id> ids) {
        String groupedIds = '';

        for (Id value : ids) {
            if (String.isBlank(groupedIds)) {
                groupedIds = '\'' + value + '\'';
                continue;
            }

            groupedIds += ',\'' + value + '\'';
        }

        groupedIds = String.format(Constants.RestQueryBuilder.QUOTES_TEMPLATE, new List<String>{
                groupedIds
        });
        this.addCondition(field, operator, groupedIds);

        return this;
    }

    /**
     * @description 
    */
    public RestQueryBuilder addOrderBy(String field, String order) {
        if (String.isBlank(field)) return this;
        if (String.isBlank(order)) order = '';
        this.orderByCondition = Constants.RestQueryBuilder.PLUS_SIGN + String.format(Constants.RestQueryBuilder.ORDER_BY_TEMPLATE, new List<String>{
                field, order
        });
        return this;
    }

    /**
  * @description 
 */
    public RestQueryBuilder addLimit(Integer limitValue) {
        if (limitValue == 0 || limitValue == null) return this;
        this.limitCondition = Constants.RestQueryBuilder.PLUS_SIGN + String.format(Constants.RestQueryBuilder.LIMIT_TEMPLATE, new List<Integer>{
                limitValue
        });
        return this;
    }

    /**
 * @description 
*/
    public RestQueryBuilder addOffset(Integer offsetValue) {
        if (offsetValue == 0 || offsetValue == null) return this;
        this.offsetCondition = Constants.RestQueryBuilder.PLUS_SIGN + String.format(Constants.RestQueryBuilder.OFFSET_TEMPLATE, new List<Integer>{
                offsetValue
        });
        return this;
    }

    /**
     * @description 
    */
    public RestQueryBuilder logicalAnd() {
        if (String.isBlank(this.whereCondition)) {
            return this;
        }

        this.whereCondition += Constants.RestQueryBuilder.PLUS_SIGN + Constants.RestQueryBuilder.LOGICAL_AND;
        return this;
    }

    /**
     * @description 
    */
    public RestQueryBuilder logicalOr() {
        if (String.isBlank(this.whereCondition)) {
            return this;
        }

        this.whereCondition += Constants.RestQueryBuilder.PLUS_SIGN + Constants.RestQueryBuilder.LOGICAL_OR;
        return this;
    }

    private String formSelectTemplate() {
        return String.format(Constants.RestQueryBuilder.SELECT_TEMPLATE, new List<String>{
                this.formRestFields(), this.sObjectName
        });
    }

    private String formWhereTemplate() {
        if (String.isBlank(this.whereCondition)) return '';
        return Constants.RestQueryBuilder.PLUS_SIGN + String.format(Constants.RestQueryBuilder.WHERE_TEMPLATE, new List<String>{
                this.whereCondition
        });
    }

    private String formRestFields() {
        String result = '';

        for (String field : this.restQueryFields) {
            if (String.isBlank(result)) {
                result = field;
                continue;
            }
            result += Constants.RestQueryBuilder.PLUS_SIGN + field;
        }

        return result;
    }
}