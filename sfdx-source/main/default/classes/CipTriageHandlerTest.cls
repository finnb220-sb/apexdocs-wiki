@isTest
public class CipTriageHandlerTest {
    @testSetup
    private static void setupData() {
        User u;
        CIP_UserAttribute__c ua;
        Triage__c tri;

        CIP_Settings__c setting = new CIP_Settings__c();
        setting.Name = 'cipsit';
        setting.VitalSearchNumberOfYears__c = 5;
        setting.serviceCategory__c = 'A';
        setting.AuthProviderName__c = 'VA_SSOi';
        setting.baseUrl__c = 'https://va-vet--cipsit.my.salesforce.com';
        setting.token__c = 'aPdk3dPmQQhBCjWPIjY9YRNwaZNKwnU1WFtiqnQr';
        setting.VistaNoteLineCharacterLimit__c = 80.0;
        setting.TXCPipeSymbolReplacement__c = '-';
        insert setting;

        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1][0];
        UserRole role = new UserRole(Name = 'Tester');
        //String unique = 'Test' + String.valueOf(Integer.valueOf(math.rint(math.random()*1000000)));

        User moi = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1][0];

        System.runAs(moi) {
            insert role;

            u = new User(
                firstname = 'firstName',
                lastName = 'lastName',
                email = 'abc@testcip.org',
                Username = 'abc@testcip.org',
                EmailEncodingKey = 'ISO-8859-1',
                Alias = 'abc',
                TimeZoneSidKey = 'America/Los_Angeles',
                LocaleSidKey = 'en_US',
                LanguageLocaleKey = 'en_US',
                ProfileId = p.Id,
                UserRoleId = role.Id
            );
            insert u;

            Group TopQ = new Group(Name = 'CIP_TopekaTest', DeveloperName = 'CIP_TopekaTest', Type = 'Queue');
            insert TopQ;

            Group TopPG = new Group(Name = 'CIP_TopekaTest', DeveloperName = 'CIP_TopekaTest', Type = 'Regular');
            insert TopPG;

            GroupMember gmPG = new GroupMember(GroupId = TopQ.Id, UserOrGroupId = TopPG.Id);
            insert gmPG;

            QueueSobject qso = new QueueSobject(QueueId = TopQ.Id, SobjectType = 'Triage__c');
            insert qso;

            //Group g = [SELECT Id FROM Group WHERE DeveloperName = 'CIP_Topeka' AND type != 'Queue' LIMIT 1][0];
            GroupMember gm = new GroupMember(GroupId = TopPG.Id, UserOrGroupId = u.Id);
            insert gm;

            ua = new CIP_UserAttribute__c(
                LocalSiteId__c = '984',
                User__c = u.Id
                //Name = 'TEST'
            );

            insert ua;
        }
        System.runAs(u) {
            tri = new Triage__c(
                First_Name__c = 'ONE',
                Last_Name__c = 'AMPLTESTPATIENT',
                Gender__c = 'Male',
                Date_of_Birth__c = Date.newInstance(1916, 7, 14),
                Triage_Status__c = 'Intake Complete',
                Check_In_Date_Time__c = System.now(),
                SSN__c = '308048718',
                Patient_Local_Pid__c = '78',
                Facility_Id__c = '984',
                Location__c = '2289',
                E_M_Code__c = '99211^OFFICE O/P EST MINIMAL PROB',
                Progress_Note__c = '1986',
                Reason__c = 'Reason To Update'
            );
            insert tri;
        }
    }

    @isTest
    static void testMpiPatientSearch() {
        User u = [SELECT Id FROM User WHERE Username = 'abc@testcip.org' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            // Set mock callout class
            string bod = '{"vets":[{"firstName": "Jack","lastName": "Jones", "ssn":"308048718", "gender": "M","dob": "19441117"},{"firstName": "Kelly","lastName": "Kars","gender": "F","dob": "19481117"}]}';
            string stringCallout = 'mpiSearch';
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator(stringCallout));
            //CIP_UserAttribute__c cua = [SELECT Id FROM CIP_UserAttribute__c WHERE User__c = :userInfo.getUserId() LIMIT 1];

            // Call method to test. This causes a fake response to be sent from the class that implements HttpCalloutMock.
            CipTriageHandler.ResponseWrap respwrap = CipTriageHandler.mpiPatientSearch(bod);
            Test.stopTest();
            System.assertequals(respwrap.status, '200', 'ResponseWrap didnot return 200');
        }
    }

    @isTest
    static void testCreateTriage() {
        User u = [SELECT Id FROM User WHERE Username = 'abc@testcip.org' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            String triage;

            triage = CipTriageHandler.createTriage(
                '{"icn":"1012668137V030567","firstName":"ONE","lastName":"AMPLTESTPATIENT","gender":"M", "medicalCenterFacilities":[{"facilityId":"984","personId":"78"}],"ssn":"308048718","dob":"07-14-1916"}',
                'Intake Complete'
            );
            Test.stopTest();
            System.assert(triage != null, 'Triage record not created');
        }
    }

    @isTest
    static void testPatientFlagMessages() {
        User u = [SELECT Id FROM User WHERE Username = 'abc@testcip.org' LIMIT 1];
        Triage__c tri = [SELECT Id FROM Triage__c WHERE Last_Name__c = 'AMPLTESTPATIENT' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('flagMessages'));
            CipTriageHandler.PatientMessagesResponseWrap response1 = CipTriageHandler.patientFlagMessages(tri.Id);
            CipTriageHandler.PatientMessagesResponseWrap response2 = CipTriageHandler.patientFlagMessages(tri.Id);
            Test.stopTest();
            System.assert(String.isNotBlank(String.valueOf(response1)), 'Patient flags not returned 1');
            System.assert(String.isNotBlank(String.valueOf(response2)), 'Patient flags not returned 2');
        }
    }

    @isTest
    static void testHistoricVitals() {
        User u = [SELECT Id FROM User WHERE Username = 'abc@testcip.org' LIMIT 1];
        Triage__c tri = [SELECT Id FROM Triage__c WHERE Last_Name__c = 'AMPLTESTPATIENT' LIMIT 1];
        System.runAs(u) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('historicVitals'));
            CipTriageHandler.VitalsResponseWrap response1 = CipTriageHandler.historicVitals(tri.Id);
            CipTriageHandler.VitalsResponseWrap response2 = CipTriageHandler.historicVitals(tri.Id);
            Test.stopTest();
            System.assert(String.isNotBlank(String.valueOf(response1)), 'Historic Vitals not returned 2');
            System.assert(String.isNotBlank(String.valueOf(response2)), 'Historic Vitals not returned 2');
        }
    }

    @isTest
    static void testWriteNote() {
        User u = [SELECT Id FROM User WHERE Username = 'abc@testcip.org' LIMIT 1];
        Triage__c tri = [
            SELECT
                Id,
                Nurse_Notes__c,
                TXC_Results__c,
                Mode_of_Arrival__c,
                Accompanied_By__c,
                Reason_for_Visit__c,
                Mental_Health_Screening__c,
                Reason__c,
                Outside_US_30_Days__c,
                Signs_of_Abuse__c,
                Feels_Safe__c,
                Suicidal_Homicidal__c,
                Facility_Id__c,
                Patient_Local_Pid__c,
                Response__c,
                Encounter_String__c,
                First_Name__c,
                Last_Name__c,
                Progress_Note__c,
                E_M_Code__c,
                Location__c,
                ICD10_code__c
            FROM Triage__c
            WHERE Last_Name__c = 'AMPLTESTPATIENT'
            LIMIT 1
        ];
        List<Triage__c> triageList = new List<Triage__c>();
        List<String> noteIdList = new List<String>();

        System.runAs(u) {
            triageList.add(tri);
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('SaveNoteAndEncounter'));
            //Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('writeNote'));
            noteIdList = CipTriageHandler.writeNote(triageList);
            Test.stopTest();
        }
        System.assert(!noteIdList.isEmpty(), 'Note Id is not returned');
    }

    @isTest
    static void testGetEncounterString() {
        User u = [SELECT Id FROM User WHERE Username = 'abc@testcip.org' LIMIT 1];
        Triage__c tri = [
            SELECT Id, Progress_Note__c, Location__c, First_Name__c, Last_Name__c, Facility_Id__c, Patient_Local_Pid__c, E_M_Code__c, ICD10_code__c
            FROM Triage__c
            WHERE Last_Name__c = 'AMPLTESTPATIENT'
            LIMIT 1
        ];
        String encounterString;

        System.runAs(u) {
            Test.startTest();
            Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator('SaveNoteAndEncounter'));
            encounterString = CipTriageHandler.getEncounterString(tri);
            Test.stopTest();
        }
        system.assertEquals(encounterString, '2289;3210824.131819;A');
    }

    @isTest
    static void testGetIAMToken() {
        Test.startTest();
        String IAMToken = CipTriageHandler.getIAMToken('Refresh');
        Test.stopTest();
        system.assertEquals(IAMToken, 'aPdk3dPmQQhBCjWPIjY9YRNwaZNKwnU1WFtiqnQr');
    }

    @isTest
    static void testParseNoteText() {
        String unparsedText = 'Nurse Notes\n\tnull\n\nSymptom Triage Note\nSat, 25 Sep 2021 20:35:17 +0000 UTC\n\nDemographics\n\t61 y/o Male\n\nResults\n\tCC: Black Tongue &#124; Duration 4 Hours\n\tNurse assigned 5-level Triage Class: 2\n\tSystem suggested 5-level Triage Class: 2\n\nAlert\n\n\t1)  This is a HIGHER COMPLEXITY patient.\n\n\nPositive Responses\n\tHPI: confusion, onset since the jaw injury\n\tHPI: jaw injury, within past 2 days\n\tHPI: tongue swelling\n\nVerbal Instructions\n\tBlack Tongue Home Care\n\nWeb Instructions:	https://vha-pip.dshisystems.net/pi.htm?k=TEABhT4gXAAAAAAB2GTONC9DtFuYs\n\nReason for Visit\n\tnull\n\nMode of Arrival\n\tnull\n\nAccompanied By\n\tnull\n\nLogistical Response\n\nnull';
        Test.startTest();
        String parsedString = CipTriageHandler.parseNoteText(unparsedText);
        Test.stopTest();
        system.assertEquals(
            parsedString,
            'Nurse Notes\n\tnull\n\nSymptom Triage Note\nSat, 25 Sep 2021 20:35:17 +0000 UTC\n\nDemographics\n\t61 y/o Male\n\nResults\n\tCC: Black Tongue &#124; Duration 4 Hours\n\tNurse assigned 5-level Triage Class: 2\n\tSystem suggested 5-level Triage Class: 2\n\nAlert\n\n\t1)  This is a HIGHER COMPLEXITY patient.\n\n\nPositive Responses\n\tHPI: confusion, onset since the jaw injury\n\tHPI: jaw injury, within past 2 days\n\tHPI: tongue swelling\n\nVerbal Instructions\n\tBlack Tongue Home Care\n\nWeb Instructions:\t\nhttps://vha-pip.dshisystems.net/pi.htm?k=TEABhT4gXAAAAAAB2GTONC9DtFuYs\n\nReason for Visit\n\tnull\n\nMode of Arrival\n\tnull\n\nAccompanied By\n\tnull\n\nLogistical Response\n\nnull\n'
        );
    }
}
