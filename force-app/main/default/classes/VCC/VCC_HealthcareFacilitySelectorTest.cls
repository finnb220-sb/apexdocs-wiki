@isTest
public with sharing class VCC_HealthcareFacilitySelectorTest {
    @TestSetup
    static void makeData() {
        Account a = new Account(Name = 'Test Account 1');
        insert a;
        insert new List<HealthcareFacility>{
            new HealthcareFacility(Name = 'Facility 1', VCC_Personas__c = 'MD', VCC_Site_Id__c = 983, AccountId = a.Id),
            new HealthcareFacility(Name = 'Facility 2', VCC_Personas__c = 'RN', VCC_Site_Id__c = 983, AccountId = a.Id),
            new HealthcareFacility(Name = 'Facility 3', VCC_Personas__c = 'RN', VCC_Site_Id__c = 984, AccountId = a.Id)
        };
    }

    @isTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_HealthcareFacilitySelector healthcareFacilitySel = new VCC_HealthcareFacilitySelector();
        Test.stopTest();

        Assert.isTrue(healthcareFacilitySel != null, 'Did not instantiate as expected.');
    }

    @isTest
    public static void addSObjectFieldsTest() {
        VCC_HealthcareFacilitySelector healthcareFacilitySel = new VCC_HealthcareFacilitySelector();

        Assert.isTrue(!healthcareFacilitySel.getSObjectFieldList().contains(HealthcareFacility.SystemModstamp), 'Selector already contains the field to test.');

        Test.startTest();
        healthcareFacilitySel.addSObjectFields(new List<SObjectField>{ HealthcareFacility.SystemModstamp });
        Test.stopTest();

        Assert.isTrue(healthcareFacilitySel.getSObjectFieldList().contains(HealthcareFacility.SystemModstamp), 'Selector did not add SObject field correctly.');
    }

    @isTest
    public static void selectByIdsTest() {
        VCC_HealthcareFacilitySelector healthcareFacilitySel = new VCC_HealthcareFacilitySelector();
        HealthcareFacility hcf = [
            SELECT Id
            FROM HealthcareFacility
            LIMIT 1
        ];

        Test.startTest();
        List<HealthcareFacility> hcfs = healthcareFacilitySel.selectByIds(new Set<Id>{ hcf.Id });
        Test.stopTest();

        Assert.isTrue(hcfs.size() == 1, 'Expected one record returned.');
    }

    @isTest
    public static void UnitSelectBySiteIdAndPersonaTestPositive() {
        VCC_HealthcareFacilitySelector healthcareFacilitySel = new VCC_HealthcareFacilitySelector();

        Test.startTest();
        List<HealthcareFacility> hcfs = healthcareFacilitySel.selectBySiteIdAndPersona(983, new Set<String>{ 'MD' });
        Test.stopTest();

        Assert.isTrue(hcfs.size() == 1, 'Expected one record returned.');
    }

    @isTest
    public static void UnitSelectBySiteIdAndPersonaTestNegative() {
        VCC_HealthcareFacilitySelector healthcareFacilitySel = new VCC_HealthcareFacilitySelector();

        Test.startTest();
        List<HealthcareFacility> hcfs = healthcareFacilitySel.selectBySiteIdAndPersona(983, new Set<String>{ 'PHARM' });
        Test.stopTest();

        Assert.isTrue(hcfs.size() == 0, 'Expected zero records returned.');
    }
}
