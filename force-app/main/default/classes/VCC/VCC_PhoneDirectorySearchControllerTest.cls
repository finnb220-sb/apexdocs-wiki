@isTest
public class VCC_PhoneDirectorySearchControllerTest {
    private static String username = 'pdsct';

    @TestSetup
    public static void makeData() {
        List<User> userList = new List<User>();
        List<GroupMember> groupMembersList = new List<GroupMember>();

        List<String> psgNames = new List<String>{
            'VCC_Registered_Nurse',
            'VCC_Medical_Provider',
            'VCC_Advanced_Medical_Support_Assistant',
            'VCC_Pharmacy_I',
            'VCC_Pharmacy_II',
            'VCC_Pharmacy_III',
            'TED_Medical_Provider_Group',
            'TED_Registered_Nurse_Group'
        };

        for (Integer i = 0; i < psgNames.size(); i++) {
            User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
            userList.add(testUser);
            VCC_TestDataFactory.addPermSetGroupToUser(psgNames[i], testUser);
            testUser.username = username + testUser.username + i;
        }

        update userList;
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static List<User> getTestUsers() {
        return [SELECT Id, MVIICN__c FROM User WHERE Username LIKE :username + '%'];
    }

    @isTest
    public static void validateSearch() {
        VCC_Softphone_Directory__c one = new VCC_Softphone_Directory__c(
            Name = 'Tony Stark',
            Description__c = 'Billionaire genius playboy philanthropist',
            Phone_Number__c = '1112223333'
        );

        VCC_Softphone_Directory__c two = new VCC_Softphone_Directory__c(Name = 'Thor Odinson', Description__c = 'Pirate Angel, God of Thunder', Phone_Number__c = '1114447777');

        VCC_Softphone_Directory__c three = new VCC_Softphone_Directory__c(Name = 'Loki Odinson', Description__c = 'God of Mischief (adopted)', Phone_Number__c = '9876541230');

        VCC_Softphone_Directory__c four = new VCC_Softphone_Directory__c(
            Name = 'Thanos',
            Description__c = 'Billed as the inevitable Phase 1 villain',
            Phone_Number__c = '8675309888'
        );
        insert new List<VCC_Softphone_Directory__c>{ one, two, three, four };

        Test.startTest();
        for (User u : getTestUsers()) {
            insert new List<VCC_Softphone_Directory__Share>{
                new VCC_Softphone_Directory__Share(ParentId = one.Id, UserOrGroupId = u.Id, AccessLevel = 'READ'),
                new VCC_Softphone_Directory__Share(ParentId = two.Id, UserOrGroupId = u.Id, AccessLevel = 'READ'),
                new VCC_Softphone_Directory__Share(ParentId = three.Id, UserOrGroupId = u.Id, AccessLevel = 'READ'),
                new VCC_Softphone_Directory__Share(ParentId = four.Id, UserOrGroupId = u.Id, AccessLevel = 'READ')
            };

            System.runAs(u) {
                VCC_PhoneDirectorySearchController c = new VCC_PhoneDirectorySearchController();
                c.searchKey = 'God';
                Set<String> expectedResultNames = new Set<String>{ 'Thor Odinson', 'Loki Odinson' };
                //fire SOQL query
                c.search();

                //in unit tests, all SOSL queries return empty.
                //can pre-set the search the results, though. Doing this here by using results from SOQL query
                //https://developer.salesforce.com/docs/atlas.en-us.238.0.apexcode.meta/apexcode/apex_testing_SOSL.htm?q=setFixedSearchResults
                Test.setFixedSearchResults(new List<Id>(new Map<Id, VCC_Softphone_Directory__c>(c.searchResults).keySet()));

                //now fire SOSL query
                c.searchMethod = 'SOSL';
                c.search();

                //since test SOSL results will be same as test SOQL results, just validate search results once.

                System.assert(
                    c.searchResults.size() == expectedResultNames.size(),
                    'Expected ' + expectedResultNames.size() + ' results for search term ' + c.searchKey + ', found ' + c.searchResults.size()
                );

                for (String name : expectedResultNames) {
                    Boolean found = false;
                    for (Integer i = 0; i < c.searchResults.size() && !found; i++) {
                        found = c.searchResults.get(i).Name == name;
                    }
                    System.assert(found, 'Expected to find entry named \'' + name + '\' in query results.');
                }
            }

        }
        Test.stopTest();
    }

    @isTest
    public static void validateSearchNegative() {
        List<VCC_Softphone_Directory__c> entries = new List<VCC_Softphone_Directory__c>{
            new VCC_Softphone_Directory__c(Name = 'Tony Stark', Description__c = 'Billionaire genius playboy philanthropist', Phone_Number__c = '1112223333'),
            new VCC_Softphone_Directory__c(Name = 'Thor Odinson', Description__c = 'Pirate Angel, God of Thunder', Phone_Number__c = '1114447777'),
            new VCC_Softphone_Directory__c(Name = 'Loki Odinson', Description__c = 'God of Mischief (adopted)', Phone_Number__c = '9876541230'),
            new VCC_Softphone_Directory__c(Name = 'Thanos', Description__c = 'Billed as the inevitable Phase 1 villain', Phone_Number__c = '8675309888')
        };
        insert entries;

        for (User u : getTestUsers()) {
            System.runAs(u) {
                VCC_PhoneDirectorySearchController c = new VCC_PhoneDirectorySearchController();
                c.searchKey = 'Groot';
                //fire SOQL query
                c.search();

                System.assert(c.searchResults.size() == 0, 'Expected to find no results when searching for ' + c.searchKey);
            }

        }
    }
}
