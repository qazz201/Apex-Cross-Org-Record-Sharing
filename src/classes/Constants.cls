public with sharing class Constants {

    public static Auth Auth {
        get {
            return Auth == null ? Auth = new Auth() : Auth;
        }
        set;
    }

    public static DataTable DataTable {
        get {
            return DataTable == null ? DataTable = new Datatable() : DataTable;
        }
        set;
    }

    public static Api Api {
        get {
            return Api == null ? Api = new Api() : Api;
        }
        set;
    }

    public static RestQueryBuilder RestQueryBuilder {
        get {
            return RestQueryBuilder == null ? RestQueryBuilder = new RestQueryBuilder() : RestQueryBuilder;
        }
        set;
    }

    public static Query Query {
        get {
            return Query == null ? Query = new Query() : Query;
        }
        set;
    }

    public static Sosl Sosl {
        get {
            return Sosl == null ? Sosl = new Sosl() : Sosl;
        }
        set;
    }

    public class Auth {
        private Auth() {
        }
        public final String OAUTH_ROOT = '{0}/services/oauth2'; // {0} - login.salesforce or test.salesforce
        public final String TOKEN_ENDPOINT = OAUTH_ROOT + '/token';
        public final String USER_INFO_ENDPOINT = OAUTH_ROOT + '/userinfo';
        public final String AUTHORIZATION_HEADER = 'Authorization';
        public final String BEARER_HEADER = 'Bearer ';
        public final String AMPERSAND_SIGN = '&';
        public final String QUESTION_SIGN = '?';
        public final String EQUAL_SIGN = '=';
        public final String AUTHORIZATION_CODE = 'authorization_code';
        public final String REFRESH_TOKEN = 'refresh_token';
        public final String GRANT_TYPE = 'grant_type';
        public final String CODE = 'code';
        public final String CLIENT_ID = 'client_id';
        public final String CLIENT_SECRET = 'client_secret';
        public final String REDIRECT_URI = 'redirect_uri';
    }

    public class Api {
        private Api() {
        }
        public final String SERVICES_DATA_ROOT = '/services/data/v56.0';
        public final String TOOLING_API_ROOT_PATH = SERVICES_DATA_ROOT + '/tooling/';
        public final String QUERY_API_ROOT_PATH = SERVICES_DATA_ROOT + '/query/?q=';
        public final String SEARCH_API_ROOT_PATH = SERVICES_DATA_ROOT + '/search/?q=';
        public final String QUERY_PATH = 'query/?q=';
        public final String RECORDS = 'records';
        public final String SEARCH_RECORDS = 'searchRecords';
        public final Integer MAX_RETRY_TIMES = 3;
    }

    public class RestQueryBuilder {
        private RestQueryBuilder() {
        }
        public final String SELECT_TEMPLATE = 'SELECT+{0}+FROM+{1}';
        public final String WHERE_TEMPLATE = 'WHERE+{0}';
        public final String LIMIT_TEMPLATE = 'LIMIT+{0}';
        public final String OFFSET_TEMPLATE = 'OFFSET+{0}';
        public final String ORDER_BY_TEMPLATE = 'ORDER+BY+{0}+{1}';
        public final String QUOTES_TEMPLATE = '({0})';
        public final String PLUS_SIGN = '+';
        public final String LOGICAL_AND = 'AND';
        public final String LOGICAL_OR = 'OR';
        public final String OPERATOR_IN = 'IN';
        public final String DESC_SORT = 'DESC';
        public final String ASC_SORT = 'ASC';
    }

    public class Datatable {
        private Datatable() {
        }
        public final Integer INITIAL_COLUMN_WIDTH = 200;
        public final String TARGET_BLANC = '_blanc';
        public final String FIELD_NAME = 'fieldName';
        public final String LABEL_ATTRIBUTE = 'label';
        public final String TEXT_TYPE = 'text';
        public final String TARGET_ATTRIBUTE = 'target';
        public final String URL_TYPE = 'url';
    }

    public class Query {
        private Query() {
        }
        public final String DEVELOPER_NAME_FIELD = 'DeveloperName';
        public final String CUSTOM_OBJECT_SOBJECT = 'CustomObject';
        public final String ALL_FIELDS = 'FIELDS(ALL)';
        public final String NAME_FIELD = 'Name';
        public final String ID_FIELD = 'Id';
        public final String IS_DELETED_FIELD = 'IsDeleted';
        public final String ATTRIBUTES_FIELD = 'attributes';
        public final String CREATED_BY_ID_FIELD = 'CreatedById';
        public final String LAST_MODIFIED_BY_ID_FIELD = 'LastModifiedById';
        public final String SYSTEM_MODSTAMP_FIELD = 'SystemModstamp';
        public final String CREATED_DATE_FIELD = 'CreatedDate';
    }

    public class Sosl {
        private Sosl() {
        }
        public final String SOSL_SEARCH_TEMPLATE = 'FIND+\'{\'{0}*\'}\'+IN+ALL+FIELDS+RETURNING+{1}+(FIELDS(ALL)+Limit+200)';
        public final String SPECIAL_CHARS = '!"#$%&()*+,-./:;<=>?@[\\]^_`{|}~\'';
    }
}