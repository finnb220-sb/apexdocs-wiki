@IsTest
private class VCC_FutureRenewalControllerTest {
    private static final String testMviId = '1013429125V999999';

    @TestSetup
    private static void makeData() {
        String uniqueUserName = 'taskmedicationcontrollertest' + Datetime.now().getTime() + '@testorg.com';
        Profile p = [
            SELECT Id
            FROM Profile
            WHERE Name = 'VAVET Base Profile'
            LIMIT 1
        ];
        User frrUser = new User(
            Alias = 'standt',
            Division = 'VISN 8',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName
        );

        insert frrUser;
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', frrUser);
        VCC_TestDataFactory.assignPermissionSetByName(frrUser, 'VAHC_Access_Future_Renewal_Request');
        VCC_TestDataFactory.assignPermissionSetByName(frrUser, 'HealthCloudFoundation');

        System.runAs(frrUser) {
            // get the record type id for Person Accounts
            Id rtId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();

            // create and insert a new account, which also creates a contact
            Account a = new Account(FirstName = 'Testly', LastName = 'Person Accounted', RecordTypeId = rtId, VCC_MVI_External_Id__pc = testMviId);
            insert a;

            Id caseRecTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId();
            Id pnRecTypeId = Schema.SObjectType.VCC_Progress_Note__c.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage_Note_Progress_Note').getRecordTypeId();
            Contact con = [
                SELECT Id, VCC_MVI_External_Id__c
                FROM Contact
                LIMIT 1
            ];
            con.VCC_MVI_External_Id__c = testMviId;
            update con;
            //Create Clinical Triage Case
            Case c = new Case(RecordTypeId = caseRecTypeId, VCC_Case_Type__c = 'Symptom', ContactId = con.Id);
            insert c;
            //Create Clinical Triage Progress Note
            VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = c.Id, RecordTypeId = pnRecTypeId, VCC_Caregiver_Name__c = 'Unit Test');
            insert pn;
        }
    }

    @IsTest
    private static void handleFutureRenewalTaskCreationSuccess() {
        Map<String, String> testMap = new Map<String, String>();
        testMap.put(
            'Alpha',
            '[{\"vaStatusValue\":\"ACTIVE\",\"sig\":\"TAKE ONE TABLET BY MOUTH EVERY DAY (WITH FOOD)\",\"quantityValue\":30,\"prescriptionValue\":\"17026186\",\"lastFilledValue\":\"2023-07-05\",\"fillsRemainingValue\":11,\"expiresValue\":\"2024-07-05\",\"drugName\":\"ASPIRIN 325MG BUFFERED TAB\",\"facilityName\":\"CLEVELAND VAMC - 541\",\"indication\":\"\",\"providerComments\":\"\"},{\"vaStatusValue\":\"ACTIVE\",\"sig\":\"TAKE 1 TAB BY MOUTH ONE TIME TESTING TESTING\",\"quantityValue\":1,\"prescriptionValue\":\"10952041\",\"lastFilledValue\":\"2023-05-25\",\"fillsRemainingValue\":4,\"expiresValue\":\"2024-05-22\",\"drugName\":\"A-HEFT STUDY DRUG\",\"facilityName\":\"CLEVELAND VAMC - 541\",\"indication\":\"\",\"providerComments\":\"\"}]'
        );
        testMap.put(
            'Bravo',
            '[{\"vaStatusValue\":\"ACTIVE\",\"sig\":\"TAKE ONE TABLET BY MOUTH EVERY DAY (WITH FOOD)\",\"quantityValue\":30,\"prescriptionValue\":\"17026186\",\"lastFilledValue\":\"2023-07-05\",\"fillsRemainingValue\":11,\"expiresValue\":\"2024-07-05\",\"drugName\":\"ASPIRIN 325MG BUFFERED TAB\",\"facilityName\":\"CLEVELAND VAMC - 541\",\"indication\":\"\",\"providerComments\":\"\"}]'
        );

        Case cse = [
            SELECT Id
            FROM Case
            WHERE VCC_Case_Type__c = 'Symptom'
            LIMIT 1
        ];
        Date dte = Date.newInstance(2024, 12, 9);
        Test.startTest();
        User u = [
            SELECT Id
            FROM User
            WHERE Email = 'standarduser@testorg.com'
            LIMIT 1
        ];
        System.runAs(u) {
            List<Task> tskList = VCC_FutureRenewalController.handleFutureRenewalTaskCreation(cse.Id, testMap, dte);
            System.assertEquals(tskList.size(), 2, 'List should have 2 Tasks');
        }
        Test.stopTest();
    }

    @IsTest
    private static void handleFutureRenewalTaskCreationFailure() {
        Test.startTest();
        try {
            List<Task> tskList = VCC_FutureRenewalController.handleFutureRenewalTaskCreation(null, null, null);
            System.assert(false, 'This assert shouldn\'t run since this is a negative test');
        } catch (Exception apexException) {
            System.assertEquals(AuraHandledException.class.getName(), apexException.getTypeName(), 'Expected exception');
        }
        Test.stopTest();
    }
}
