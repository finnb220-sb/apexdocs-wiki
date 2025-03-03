/**
 * @description       : Class used to test the NTSP_FacilityManagerController Apex class
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
@isTest
public class NTSP_FacilityManagementController_Test {
    /**
     * @description Method to create test data for unit tests
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @TestSetup
    static void makeData() {
        final Profile baseProfile = [SELECT Id FROM Profile WHERE Name = 'VAVET Base Profile'];

        Integer randomInt = Integer.valueOf(math.rint(math.random() * 1000000));

        final User admin = new User(
            Email = NTSP_TestDataFactory.testEmail,
            EmailEncodingKey = NTSP_TestDataFactory.testEncoding,
            LastName = 'NTSP Admin',
            Alias = 'admin',
            LanguageLocaleKey = NTSP_TestDataFactory.testLocale,
            LocaleSidKey = NTSP_TestDataFactory.testLocale,
            ProfileId = baseProfile.Id,
            TimeZoneSidKey = NTSP_TestDataFactory.testTZ,
            UserName = 'admin' + randomInt + '@ntsp.com'
        );

        insert admin;

        final Id adminPM = [SELECT Id, MasterLabel FROM PermissionSetGroup WHERE MasterLabel = 'NTSP IT'].Id;

        // final PermissionSetAssignment psa = new PermissionSetAssignment(AssigneeId = admin.Id, PermissionSetGroupId = adminPM);

        // insert psa;

        NTSP_TestDataFactory.mockPermGroupAssignment(admin.Id, adminPM);

        final User standard = new User(
            Email = NTSP_TestDataFactory.testEmail,
            EmailEncodingKey = NTSP_TestDataFactory.testEncoding,
            LastName = 'NTSP Standard',
            Alias = 'stan',
            LanguageLocaleKey = NTSP_TestDataFactory.testLocale,
            LocaleSidKey = NTSP_TestDataFactory.testLocale,
            ProfileId = baseProfile.Id,
            TimeZoneSidKey = NTSP_TestDataFactory.testTZ,
            UserName = 'standard' + randomInt + '@ntsp.com'
        );

        insert standard;
    }

    /**
     * @description Method to test the canAccessButton method in the NTSP_FacilityManagerController class
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    public static void canAccessButtonTest() {
        final User admin = [SELECT Id FROM User WHERE LastName = 'NTSP Admin' LIMIT 1];
        Boolean canAccessAdmin = false;
        Boolean canAccessStandard = false;

        System.runAs(admin) {
            canAccessAdmin = NTSP_FacilityManagementController.canAccessButton();
        }

        final User standard = [SELECT Id FROM User WHERE LastName = 'NTSP Standard' LIMIT 1];

        System.runAs(standard) {
            canAccessStandard = NTSP_FacilityManagementController.canAccessButton();
            System.assertEquals(canAccessAdmin && !canAccessStandard, true, 'Excpected return value is false');
        }
    }

    /**
     * @description Method to test the fetchNTSPSite method in the NTSP_FacilityManagerController class
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    public static void fetchNTSPSiteTest() {
        NTSP_TestDataFactory.createLocations();
        final List<Schema.Location> locList = [SELECT Id FROM Location LIMIT 1];
        final List<NTSP_Facility__c> facList = NTSP_FacilityManagementController.fetchNTSPSite(locList[0].Id);
        System.assertEquals(facList.size(), 1, 'The expected related facility was not retrieved.');
    }
}
