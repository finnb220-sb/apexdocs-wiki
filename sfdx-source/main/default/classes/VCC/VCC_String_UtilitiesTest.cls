@isTest
public with sharing class VCC_String_UtilitiesTest {
    private static String username = 'stringutil';

    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', testUser);
        testUser.Username = username + testUser.Username;
        update testUser;
    }

    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%' LIMIT 1];
    }

    @isTest
    public static void splitUniqueTest() {
        String templateString = 'a{0}a{0}b{0}b{0}b{0}b{0}1{0}2{0}3{0}4{0}5{0}6{0}7{0}7';
        Set<String> uniqueItems = new Set<String>{ 'a', 'b', '1', '2', '3', '4', '5', '6', '7' };
        Map<String, Set<String>> separatorToUniqueMap = new Map<String, Set<String>>{ ',' => null, '\r\n' => null, '\\' => null, ' ' => null, ':' => null };
        Exception unexpectedSplitException, unexpectedValidationException;
        Boolean allCorrect = true;
        Boolean noneMissed = true;

        Test.startTest();
        try {
            for (String separator : separatorToUniqueMap.keySet()) {
                String str = String.format(templateString, new List<String>{ separator });

                separatorToUniqueMap.put(separator, VCC_String_Utilities.splitUnique(str, separator));
            }
        } catch (Exception e) {
            unexpectedSplitException = e;
        }

        try {
            for (Set<String> uniqueSet : separatorToUniqueMap.values()) {
                if (!uniqueItems.containsAll(uniqueSet) || !uniqueSet.containsAll(uniqueItems)) {
                    noneMissed = false;
                }
                for (String item : uniqueSet) {
                    if (!uniqueItems.contains(item)) {
                        allCorrect = false;
                    }
                }
            }
        } catch (Exception e) {
            unexpectedValidationException = e;
        }

        Test.stopTest();

        System.assert(allCorrect == true, 'An element was not separated correctly.');
        System.assert(noneMissed == true, 'An element is missing.');
        System.assert(unexpectedSplitException == null, 'An exception was thrown unexpectedly while splitting.');
        System.assert(unexpectedValidationException == null, 'An exception was thrown unexpectedly while validating.');
    }

    @IsTest
    static void fieldTruncationTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            SObjectField fieldToTruncateTo = Account.LastName;
            Integer fieldLength = fieldToTruncateTo.getDescribe().getLength();
            String stringToTruncate = '';
            for (Integer i = 0; i < fieldLength; i++) {
                stringToTruncate += 'a';
            }
            stringToTruncate += 'this should be truncated';

            String truncatedString = VCC_String_Utilities.truncateStringForField(stringToTruncate, fieldToTruncateTo);

            System.assert(truncatedString.length() == fieldLength, 'String is longer than field length.');
            System.assert(!truncatedString.contains('this'), 'String not truncated properly.');
            System.assert(!truncatedString.contains('should'), 'String not truncated properly.');
            System.assert(!truncatedString.contains('be'), 'String not truncated properly.');
            System.assert(!truncatedString.contains('truncated'), 'String not truncated properly.');
        }
        Test.stopTest();
    }
}
