@isTest
public with sharing class VCC_Adapter_NoteToJsonTest {
    private static String username = 'antj';

    @TestSetup
    public static void makeData() {
        List<User> userList = new List<User>();
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
            VCC_TestDataFactory.assignPermissionSetByName(testUser, 'HealthCloudFoundation');
            testUser.username = username + testUser.username + i;
        }
        update userList;
    }

    public static List<User> getTestUsers() {
        return [SELECT Id, MVIICN__c FROM User WHERE Username LIKE :username + '%'];
    }

    @isTest
    public static void jsonParseTestAddendumRN() {
        VCC_Adapter_NoteToJson.Parameters params = new VCC_Adapter_NoteToJson.Parameters();
        params.progressNoteConfig = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Addendum__c');

        VCC_Addendum__c addend = new VCC_Addendum__c(VCC_Addendum__c = 'hello test');

        insert addend;

        List<VCC_Addendum__Share> shareListForInsert = new List<VCC_Addendum__Share>();
        for (User u : getTestUsers()) {
            shareListForInsert.add(new VCC_Addendum__Share(ParentId = addend.Id, AccessLevel = 'Edit', UserOrGroupId = u.Id));
        }

        insert shareListForInsert;

        Test.startTest();
        for (User u : getTestUsers()) {
            List<String> adapterOutput;

            params.noteSObject = new VCC_Addendum__c(Id = addend.Id);

            System.runAs(u) {
                adapterOutput = VCC_Adapter_NoteToJson.parse(new List<VCC_Adapter_NoteToJson.Parameters>{ params });
            }

            System.assert(adapterOutput[0].contains('hello test'), 'Expected text not found.');
        }
        Test.stopTest();
    }

    @isTest
    public static void jsonParseTestCTRN() {
        VCC_Adapter_NoteToJson.Parameters params = new VCC_Adapter_NoteToJson.Parameters();
        params.progressNoteConfig = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');

        Case c = new Case(RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId());

        insert c;
        VCC_Progress_Note__c pn = new VCC_Progress_Note__c(VCC_Case__c = c.id);
        insert pn;

        // Create a list to hold the CaseShare records we're going to insert
        List<CaseShare> caseShareListForInsert = new List<CaseShare>();

        // For each test user, create a CaseShare record
        for (User u : getTestUsers()) {
            caseShareListForInsert.add(new CaseShare(CaseId = c.Id, UserOrGroupId = u.Id, CaseAccessLevel = 'Edit'));
        }

        // Insert the CaseShare records
        insert caseShareListForInsert;

        Test.startTest();
        for (User u : getTestUsers()) {
            params.noteSObject = new VCC_Progress_Note__c(Id = pn.Id);

            List<String> adapterOutput;
            List<VCC_ProgressNoteJsonModel.ProgressNoteSection> sections;

            System.runAs(u) {
                adapterOutput = VCC_Adapter_NoteToJson.parse(new List<VCC_Adapter_NoteToJson.Parameters>{ params });
                sections = (List<VCC_ProgressNoteJsonModel.ProgressNoteSection>) JSON.deserialize(adapterOutput[0], List<VCC_ProgressNoteJsonModel.ProgressNoteSection>.class);
            }

            System.assert(sections.size() > 0, 'Expected a section.');
        }
        Test.stopTest();
    }
}
