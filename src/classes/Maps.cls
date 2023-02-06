public with sharing class Maps {
    public static Boolean isEmpty(Map<Id, Object> values) {
        if (values == null) {
            return true;
        }

        return values.isEmpty();
    }
}