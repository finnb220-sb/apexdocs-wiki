@IsTest
public with sharing class VCC_CDWIntegrationUserTest {
    private static String testMviId = '1013429125V999999';

    @TestSetup
    private static void makeData() {
        // get the record type id for Person Accounts
        Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

        // create and insert a new account, which also creates a contact
        Account a = new Account(FirstName = 'Testly', LastName = 'Person Accounted', RecordTypeId = rtId, VCC_MVI_External_Id__pc = testMviId);
        insert a;

        Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId();
        Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Tier_III_Progress_Note').getRecordTypeId();
        //Retreive contact created in testSetup to update the MVI External Id
        Contact con = [SELECT Id, VCC_MVI_External_Id__c FROM Contact LIMIT 1];
        //Set External Id to static variable
        con.VCC_MVI_External_Id__c = testMviId;
        update con;

        //Create Pharmacy Case
        Case c1 = new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Pharmacy', ContactId = con.Id, Description = 'First');
        insert c1;
        //Create Pharmacy Progress Note
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(
            VCC_Case__c = c1.Id,
            VCC_Primary_Diagnosis_Code__c = '0hs3R0000005WXQQA2',
            VCC_Procedure_Code__c = '0hs3R0000005TvGQAU',
            VCC_Secondary_Diagnosis_Code__c = null,
            RecordTypeId = pnRecTypeId
        );
        insert pn;
    }

    @IsTest
    private static void checkCDWPermissions() {
        User u = VCC_TestDataFactory.insertUser('Integration Base Profile');
        VCC_TestDataFactory.assignPermissionSetByName(u, 'HealthCloudFoundation');
        VCC_TestDataFactory.assignPermissionSetByName(u, 'VAHC_CDW_Integration_User');

        List<VCC_Progress_Note__c> notes = new List<VCC_Progress_Note__c>();
        Exception caughtException;
        // String primaryCode = 'A50.30 - Late congenital syphilitic oculopathy, unspecified';
        // String procedureCode = '99447';
        String primaryCode = '0hs3R0000005WXQQA2';
        String procedureCode = '0hs3R0000005TvGQAU';

        Test.startTest();
        System.runAs(u) {
            try {
                notes = [
                    SELECT Name, VCC_Primary_Diagnosis_Code__r.Name, VCC_Procedure_Code__r.Name, VCC_Secondary_Diagnosis_Code__r.Name, VCC_Current_Address_not_Primary_Address__c
                    FROM VCC_Progress_Note__c
                ];
            } catch (Exception e) {
                System.debug(LoggingLevel.ERROR, e.getMessage());
                System.debug(LoggingLevel.ERROR, e.getStackTraceString());
                caughtException = e;
            }
        }
        Test.stopTest();

        System.debug('results size: ' + notes.size());
        System.debug('notes::: ' + JSON.serializePretty(notes[0]));

        System.assert(caughtException == null, 'An exception was thrown.');
        System.assert(notes != null, 'Data not returned as expected.');
        System.assert(notes[0].VCC_Primary_Diagnosis_Code__c == primaryCode, 'Expected to match primaryCode.');
        System.assert(notes[0].VCC_Procedure_Code__c == procedureCode, 'Expected to match procedureCode.');
        System.assert(notes[0].VCC_Secondary_Diagnosis_Code__c == null, 'Expected to be null.');
        System.assert(notes[0].VCC_Current_Address_not_Primary_Address__c == false, 'Expected false.');
    }
}
