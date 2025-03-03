@IsTest
public class VCC_LookupSearchResultTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }

    /**
     * @description test method
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    static void willInitialize() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_LookupSearchResult result = new VCC_LookupSearchResult('Id', 'type', 'icon', 'title', 'subtitle');

            System.assertEquals('Id', result.getId(), 'Id matches expected value ID');
            System.assertEquals('type', result.getSObjectType(), 'type matches expected value Type');
            System.assertEquals('icon', result.getIcon(), 'icon matches expected value icon');
            System.assertEquals('title', result.getTitle(), 'title matches expected value title');
            System.assertEquals('subtitle', result.getSubtitle(), 'subtitle matches expected value subtitle');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitPositiveValuesComparison() {
        System.runAs(getTestUser()) {
            Test.startTest();
            List<VCC_LookupSearchResult> resultList = new List<VCC_LookupSearchResult>();

            for (integer i = 0; i < 2; i++) {
                string val = i + ' value';
                resultList.add(new VCC_LookupSearchResult(val, val, val, val, val));
            }
            resultList.sort();
            System.assertEquals('0 value', resultList[0].getTitle(), 'First value after short should be i=0');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitNegativeNullValuesComparison() {
        System.runAs(getTestUser()) {
            Test.startTest();
            List<VCC_LookupSearchResult> resultList = new List<VCC_LookupSearchResult>();
            for (integer i = 0; i < 2; i++) {
                resultList.add(new VCC_LookupSearchResult(null, null, null, null, null));
            }
            resultList.sort();
            System.assertEquals(null, resultList[0].getTitle(), 'First value after short should be null');
            Test.stopTest();
        }
    }

    @IsTest
    static void unitNegativeEmptyNullComparison() {
        System.runAs(getTestUser()) {
            Test.startTest();
            List<VCC_LookupSearchResult> resultList = new List<VCC_LookupSearchResult>();
            resultList.add(new VCC_LookupSearchResult('', '', '', '', ''));
            resultList.add(new VCC_LookupSearchResult(null, null, null, null, null));

            resultList.sort();
            System.assertEquals('', resultList[0].getTitle(), 'First value after short should be empty');
            Test.stopTest();
        }
    }
}
