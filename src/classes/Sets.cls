public with sharing class Sets {
    public static Boolean isEmpty(Set<Id> values) {
        if (values == null) {
            return true;
        }

        return values.isEmpty();
    }
}