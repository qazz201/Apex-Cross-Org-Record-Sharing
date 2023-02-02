public with sharing class Lists {

    public static Object getFirst(List<Object> values) {
        return !isEmpty(values) ? values[0] : null;
    }

    public static Boolean isEmpty(List<Object> values) {
        if (values == null) {
            return true;
        }

        return values.isEmpty();
    }

//    public static Object getFirst(List<Map<Object, Object>> values) {
//        return !values.isEmpty() ? values[0] : null;
//    }
}