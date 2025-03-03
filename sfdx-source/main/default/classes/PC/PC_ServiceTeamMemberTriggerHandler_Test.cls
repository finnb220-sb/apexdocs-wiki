@isTest
public class PC_ServiceTeamMemberTriggerHandler_Test {
    @testSetup
    public static void makeData() {
        User manager = PC_TestDataFactory.createManager('TestPCManager55');
        User specialist = PC_TestDataFactory.createSpecialist('TestPCSpecialist');
        User specialist2 = PC_TestDataFactory.createSpecialist('TestPCSpecialist2');
        System.runAs(manager) {
            PC_Service__c pcService = new PC_Service__c(PC_Specialty__c = 'Cardiology', Active__c = true);
            insert pcService;
            PC_Service__c pcService2 = new PC_Service__c(PC_Specialty__c = 'Clinical Pharmacy', Active__c = true);
            insert pcService2;
        }
    }
    @isTest
    public static void testAddServiceTeamMemberPositive() {
        User manager = [SELECT Id FROM User WHERE LastName = 'TestPCManager55' LIMIT 1];
        User specialist = [SELECT Id FROM User WHERE LastName = 'TestPCSpecialist' LIMIT 1];
        System.runAs(manager) {
            ServiceResource sr = PC_TestDataFactory.createServiceResource(specialist.Id, 'TestPCSpecialist', 'Cardiology');
            PC_Service__c pcService = [SELECT Id FROM PC_Service__c WHERE PC_Specialty__c = 'Cardiology' LIMIT 1];
            PC_Service_Team_Member__c pcstm = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService.Id,
                PC_Service_Resource__c = sr.Id
            );
            insert pcstm;
            List<PC_Service_Team_Member__c> pcstmList = [SELECT Id FROM PC_Service_Team_Member__c LIMIT 1];
            System.AssertEquals(pcstmList.size(), 1);
        }
    }
    @isTest
    public static void testAddServiceTeamMemberNegativeInsert() {
        User manager = [SELECT Id FROM User WHERE LastName = 'TestPCManager55' LIMIT 1];
        User specialist = [SELECT Id FROM User WHERE LastName = 'TestPCSpecialist' LIMIT 1];
        System.runAs(manager) {
            ServiceResource sr = PC_TestDataFactory.createServiceResource(specialist.Id, 'TestPCSpecialist', 'Cardiology');
            PC_Service__c pcService = [SELECT Id FROM PC_Service__c WHERE PC_Specialty__c = 'Cardiology' LIMIT 1];
            PC_Service_Team_Member__c pcstm = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService.Id,
                PC_Service_Resource__c = sr.Id
            );
            insert pcstm;
            try {
                PC_Service_Team_Member__c pcstm2 = new PC_Service_Team_Member__c(
                    PC_Service_Team_Member_Role__c = 'Specialist',
                    PC_Service__c = pcService.Id,
                    PC_Service_Resource__c = sr.Id
                );
                insert pcstm2;
                System.Assert(false);
            } catch (Exception e) {
                System.Assert(true);
            }
        }
    }
    @isTest
    public static void testAddServiceTeamMemberNegativeUpdate() {
        User manager = [SELECT Id FROM User WHERE LastName = 'TestPCManager55' LIMIT 1];
        User specialist = [SELECT Id FROM User WHERE LastName = 'TestPCSpecialist' LIMIT 1];
        User specialist2 = [SELECT Id FROM User WHERE LastName = 'TestPCSpecialist2' LIMIT 1];
        System.runAs(manager) {
            ServiceResource sr = PC_TestDataFactory.createServiceResource(specialist.Id, 'TestPCSpecialist', 'Cardiology');
            ServiceResource sr2 = PC_TestDataFactory.createServiceResource(specialist2.Id, 'TestPCSpecialist2', 'Clinical Pharmacy');
            PC_Service__c pcService = [SELECT Id FROM PC_Service__c WHERE PC_Specialty__c = 'Cardiology' LIMIT 1];
            PC_Service__c pcService2 = [SELECT Id FROM PC_Service__c WHERE PC_Specialty__c = 'Clinical Pharmacy' LIMIT 1];
            PC_Service_Team_Member__c pcstm = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService.Id,
                PC_Service_Resource__c = sr.Id
            );
            insert pcstm;
            PC_Service_Team_Member__c pcstm2 = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService2.Id,
                PC_Service_Resource__c = sr.Id
            );
            insert pcstm2;
            PC_Service_Team_Member__c pcstm3 = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService2.Id,
                PC_Service_Resource__c = sr2.Id
            );
            insert pcstm3;
            try {
                PC_Service_Team_Member__c pcstmUpdate = [
                    SELECT Id, PC_Service__c, PC_Service_Resource__c
                    FROM PC_Service_Team_Member__c
                    WHERE PC_Service_Resource__c = :sr.Id AND PC_Service__c = :pcService2.Id
                    LIMIT 1
                ];
                pcstmUpdate.PC_Service_Resource__c = sr2.Id;
                update pcstmUpdate;
                System.Assert(false);
            } catch (Exception e) {
                System.Assert(true);
            }
            try {
                PC_Service_Team_Member__c pcstmUpdate2 = [
                    SELECT Id, PC_Service__c, PC_Service_Resource__c
                    FROM PC_Service_Team_Member__c
                    WHERE PC_Service_Resource__c = :sr.Id AND PC_Service__c = :pcService2.Id
                    LIMIT 1
                ];
                pcstmUpdate2.PC_Service__c = pcService.Id;
                update pcstmUpdate2;
                System.Assert(false);
            } catch (Exception e) {
                System.Assert(true);
            }
        }
    }
}
