/**
 * @description
 * @author
 * @since
 * @group Helpers/Utilities
 */
public inherited sharing class VCC_JSONUtil {
    public static Object deserialize(String jsonData, System.Type wrapperClass) {
        return JSON.deserialize(translateKeywords(jsonData, wrapperClass), wrapperClass);
    }

    private static String translateKeywords(String data, System.Type wrapperClass) {
        Map<String, String> replacements = ((VCC_WrapperWithKeyword) wrapperClass.newInstance()).getKeywordTranslationMap();

        for (String tag : replacements.keySet()) {
            data = data.replace('"' + tag + '"', '"' + replacements.get(tag) + '"');
        }

        return data;
    }
}
