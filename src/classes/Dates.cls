public with sharing class Dates {
    public static Boolean isDate(Object value) {
        if (value == null) return false;
        
        try {
            getValue(value);
            return true;
        } catch (Exception exc) {
            return false;
        }
    }

    public static Date getValue(Object value) {
        return Date.valueOf(String.valueOf(value));
    }
}