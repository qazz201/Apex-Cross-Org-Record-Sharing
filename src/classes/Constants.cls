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

    public class Auth {
        private Auth() {
        }
        public final String TOKEN_ENDPOINT = 'https://login.salesforce.com/services/oauth2/token';
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
        public final String TOOLING_API_ROOT_PATH = '/services/data/v56.0/tooling/';
        public final String QUERY_API_ROOT_PATH = '/services/data/v56.0/query/?q=';
        public final String QUERY_PATH = 'query/?q=';
        public final String QUERY_CUSTOM_OBJECT_NAMES = 'SELECT+DeveloperName+from+CustomObject';
        public final String QUERY_OBJECT_BY_NAME_WITH_ALL_FIELDS = 'SELECT+FIELDS(ALL)+FROM+{0}+LIMIT+{1}';
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
}