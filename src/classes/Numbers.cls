public with sharing class Numbers {

    public static Boolean isDecimal(Object value) {
        if (value == null) return false;

        try {
            getDecimalValue(value);
            return true;
        } catch (Exception exc) {
            return false;
        }
    }

    public static Decimal getDecimalValue(Object value) {
        return Decimal.valueOf(String.valueOf(value));
    }
}