public with sharing class Ids {
    public static Boolean isId(Object value) {
        if (value == null) return false;
        try {
            Id idValue = (Id) String.valueOf(value);
            return true;
        } catch (Exception exc) {
            return false;
        }
    }
}