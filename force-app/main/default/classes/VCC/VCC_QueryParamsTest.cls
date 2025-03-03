@isTest
private class VCC_QueryParamsTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @isTest
    private static void buildQuery() {
        Map<String, Object> params = new Map<String, Object>{ 'firstName' => 'Casey', 'lastName' => 'Smitson', 'dob' => '1992-05-12' };
        System.runAs(getTestUser()) {
            Test.startTest();
            String expectedResult = 'FirstName = \'Casey\' AND LastName = \'Smitson\' AND PersonBirthdate = 1992-05-12 ';
            VCC_QueryParams searchParams = new VCC_QueryParams();
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.FirstName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('firstName'))
            );
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.MiddleName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('middleName'))
            );
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.LastName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('lastName'))
            );
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.PersonBirthdate, VCC_QueryParam.QueryParamCondition.EQUALS, VCC_QueryParam.QueryParamType.DATETYPE, (String) params.get('dob'))
            );
            String serializeParams = searchParams.toQueryString();
            System.assert(serializeParams != null, 'Search params were not properly assigned');
            System.assertEquals(expectedResult, serializeParams, 'serializeParams have not been formatted correctly');
            Test.stopTest();
        }
    }
}
