/**
 * @description Class for helpful string tools.
 * @author Patrick Skamarak
 * @since 12/3/2021
 */
public with sharing class VCC_String_Utilities {
    /**
     * @description Splits the given string by the specified separator, returns a set.
     * @param str String to separate.
     * @param separator What to separate the string by (comma, new line, etc.)
     * @return  `Set<String>` containing all unique items.
     */
    public static Set<String> splitUnique(String str, String separator) {
        Integer index = 0;
        Set<String> unique = new Set<String>();
        if (str == null || str == '' || separator == null) {
            return unique;
        }

        do {
            Integer nextIndex = str.indexOf(separator, index + 1);
            if (nextIndex == -1) {
                unique.add(str.subString(index).remove(separator).trim());
            } else {
                unique.add(str.subString(index, nextIndex).remove(separator).trim());
            }
            index = nextIndex;
        } while (index != -1);
        return unique;
    }

    public static String truncateStringForField(String str, SObjectField sobjectField) {
        return truncateStringForField(str, sobjectField, ' ... ');
    }

    public static String truncateStringForField(String str, SObjectField sobjectField, String truncationPostfix) {
        Integer fieldLength = sobjectField.getDescribe().getLength();
        if (str == null || str.length() < fieldLength) {
            return str;
        }
        if (fieldLength == 0 || fieldLength < truncationPostfix.length()) {
            return null;
        }
        return str.substring(0, (fieldLength - truncationPostfix.length())) + truncationPostfix;
    }
}
