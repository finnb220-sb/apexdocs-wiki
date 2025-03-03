@isTest
public class PC_LookupControllerTest {
    @testSetup
    public static void makeData() {
        User manager = PC_TestDataFactory.createManager('TestPCManager55');
        User specialist = PC_TestDataFactory.createSpecialist('TestPCSpecialist');
        System.runAs(manager) {
            ServiceResource sr = PC_TestDataFactory.createServiceResource(specialist.Id, 'TestPCSpecialist', 'Cardiology');
            PC_Service__c pcService = new PC_Service__c(PC_Specialty__c = 'Cardiology', Active__c = true);
            insert pcService;
            PC_Service_Team_Member__c pcstm = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService.Id,
                PC_Service_Resource__c = sr.Id
            );
            insert pcstm;
        }
    }
    @isTest
    public static void testSearch() {
        User manager = [SELECT Id FROM User WHERE LastName = 'TestPCManager55' LIMIT 1];

        System.runAs(manager) {
            PC_Service__c pcService = [SELECT Id, Name FROM PC_Service__c WHERE PC_Specialty__c = 'Cardiology' LIMIT 1];
            PC_Service_Team_Member__c pcstm = [SELECT Id FROM PC_Service_Team_Member__c LIMIT 1];
            Id[] fixedSearchResults = new Id[1];
            fixedSearchResults[0] = pcstm.Id;
            Test.setFixedSearchResults(fixedSearchResults);
            List<LookupSearchResult> result = PC_LookupController.search('Test', pcService.Id);
            System.assertEquals(1, result.size());
            List<LookupSearchResult> someResults = PC_LookupController.getSomeResults(pcService.Id);
            System.assertEquals(1, someResults.size());
        }
    }
}
