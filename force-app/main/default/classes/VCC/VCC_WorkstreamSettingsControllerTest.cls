/**
 * @description Test class for VCC_WorkstreamSettingsController
 */
@IsTest
private with sharing class VCC_WorkstreamSettingsControllerTest {
    /**
     * @description A known permission set group for Pharmacy users
     */
    private static final String PSG_PHARMACY = 'VCC_Pharmacy_I';
    /**
     * @description A known permission set group for MSA users
     */
    private static final String PSG_MSA = 'VAHC_MSA_Administrative_Officer';
    /**
     * @description A known permission set group for VCV users
     * - Note that some VCV PSG names also contain text that fulfills "MSA" condition (by design). Using this VCV PSG ensures it's truly a "VCV" scenario.
     */
    private static final String PSG_VCV = 'VCC_VCV_Appointment_Viewer_Administrator';
    /**
     * @description A known permission set group for RN users
     */
    private static final String PSG_RN = 'VCC_Registered_Nurse';

    /**
     * @description Inserts a user with VAVET Base Profile, assigns specified permission set group to the user, and returns the user.
     * @param permissionSetGroupName `String` The API name of a permission set group
     * @return `User` A user to used in System.runAs() command
     */
    private static User makeUserWithPermissionSetGroup(String permissionSetGroupName) {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet(permissionSetGroupName)
            .withStandardData()
            .build(true);
    }
    /**
     * @description Inserts a user with VAVET Base Profile, assigns VCC_Pharmacy_I permission set group to the user, and returns the user.
     * @return `User`
     */
    private static User getPharmacyTestUser() {
        return makeUserWithPermissionSetGroup(PSG_PHARMACY);
    }

    /**
     * @description Gets coverage on empty constructor
     */
    @IsTest
    private static void constructorTest() {
        VCC_WorkstreamSettingsController workstreamSettingsController = null;
        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            workstreamSettingsController = new VCC_WorkstreamSettingsController();
        }
        Test.stopTest();

        Assert.isNotNull(workstreamSettingsController, 'Expected class to be initialized.');
    }

    /**
     * @description Validates that passing 'imaging' to the dataType argument will give a result matching config data for the Pharmacy workstream, Imaging data type.
     */
    @IsTest
    private static void getSettingsTest() {
        VCC_WorkstreamSettingsController.VCC_Model result = null;
        VCC_Workstream_Setting_Sort_Config__mdt pharmacyImagingSortConfig = null;
        VCC_Workstream_Settings__mdt pharmacySetting = null;

        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            result = VCC_WorkstreamSettingsController.getSettings(VCR_WorkstreamSettingsRepo.DATATYPE_IMAGING);
            pharmacyImagingSortConfig = VCC_Workstream_Setting_Sort_Config__mdt.getInstance('Pharmacy_Imaging');
            pharmacySetting = VCC_Workstream_Settings__mdt.getInstance('Pharmacy');
        }
        Test.stopTest();

        Assert.isNotNull(result, 'Expected that the result object instantiates');
        if (pharmacyImagingSortConfig != null) {
            //if pharmacyImagingSortConfig exists, confirm that we found it's values from getSettingsInMemory()
            Assert.areEqual(
                pharmacyImagingSortConfig.VCC_Sort_By__c,
                result.sortBy,
                'Expected result.sortBy to match ' +
                    pharmacyImagingSortConfig.VCC_Sort_By__c +
                    '. Actual: ' +
                    result.sortBy
            );
            Assert.areEqual(
                pharmacyImagingSortConfig.VCC_Sort_Direction__c,
                result.sortDirection,
                'Expected result.sortBy to match ' +
                    pharmacyImagingSortConfig.VCC_Sort_Direction__c +
                    '. Actual: ' +
                    result.sortDirection
            );

            //check end and start dates to be in correct format
            String expectedStartDate = Date.today()
                .addMonths(-(Integer) pharmacySetting.VCC_Imaging_Duration__c)
                .format();
            Assert.areEqual(
                expectedStartDate,
                result.startDate,
                'Calling getSettings did not return expected startDate of ' +
                    expectedStartDate +
                    '. Actual: ' +
                    result.startDate
            );

            Assert.areEqual(
                Date.today().format(),
                result.endDate,
                'Calling getSettings did not return expected endDate of ' +
                    Date.today().format() +
                    '. Actual: ' +
                    result.endDate
            );
        }
    }

    /**
     * @description Validates that passing 'problems' to the dataType argument will give a result matching config data for the Pharmacy workstream, Problems data type.
     * - This also achieves coverage on VCC_WorkstreamSettingsController.getSettings(dataType)
     */
    @IsTest
    private static void getSettingsInMemoryTest() {
        VCC_WorkstreamSettingsController.VCC_Model result = null;
        VCC_Workstream_Setting_Sort_Config__mdt pharmacyProblemsSortConfig = null;
        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            result = new VCC_WorkstreamSettingsController()
                .getSettingsInMemory(VCR_WorkstreamSettingsRepo.DATATYPE_PROBLEMS);
            pharmacyProblemsSortConfig = VCC_Workstream_Setting_Sort_Config__mdt.getInstance('Pharmacy_Problems');
        }
        Test.stopTest();

        Assert.isNotNull(result, 'Expected that the result object instantiates');
        if (pharmacyProblemsSortConfig != null) {
            //if pharmacyProblemsSortConfig exists, confirm that we found it's values from getSettingsInMemory()
            Assert.areEqual(
                pharmacyProblemsSortConfig.VCC_Sort_By__c,
                result.sortBy,
                'Expected result.sortBy to match ' +
                    pharmacyProblemsSortConfig.VCC_Sort_By__c +
                    '. Actual: ' +
                    result.sortBy
            );
            Assert.areEqual(
                pharmacyProblemsSortConfig.VCC_Sort_Direction__c,
                result.sortDirection,
                'Expected result.sortBy to match ' +
                    pharmacyProblemsSortConfig.VCC_Sort_Direction__c +
                    '. Actual: ' +
                    result.sortDirection
            );
        }
    }

    /**
     * @description Validates that when not passing an HDR Data Type argument, the resulting VCC_Workstream_Settings__mdt record will not have any child MDT records
     */
    @IsTest
    private static void getWorkstreamSettingsTest() {
        VCC_Workstream_Settings__mdt record = null;
        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            record = VCC_WorkstreamSettingsController.getWorkstreamSettings();
        }
        Test.stopTest();

        Assert.isNotNull(record, 'Expected that the record object instantiates');
        Assert.areEqual(
            VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy.name(),
            record.DeveloperName,
            'Expected record.DeveloperName to match Pharmacy enum name because ran as Pharmacy user'
        );
        Assert.areEqual(
            0,
            record.VCC_Workstream_Setting_Sort_Configs__r?.size(),
            'Expected null or empty related list because it only used getInstance instead of a SOQL query'
        );
    }

    /**
     * @description Validates that for a null VCC_Workstream_Settings__mdt argument, pickDurationValue will read the value from the VCC_Workstream_Settings__mdt.Default record
     */
    @IsTest
    private static void pickDurationValueTestDefault() {
        Integer result = null;
        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            result = VCC_WorkstreamSettingsController.pickDurationValue(
                null,
                VCR_WorkstreamSettingsRepo.DATATYPE_ALLERGIES
            );
        }
        Test.stopTest();

        Assert.isNotNull(
            result,
            'Expected non-null duration result because of fall back to reading defaultSettings when provided settings are null'
        );
        Assert.areEqual(
            VCC_WorkstreamSettingsController.defaultSettings.VCC_Allergies_Adverse_Reactions_Duration__c,
            result,
            'Expected result to match value of default VCC_Allergies_Adverse_Reactions_Duration__c value'
        );
    }

    /**
     * @description Validates that for a null user Id the resulting VCC_Enum.VCC_WorkstreamSettingsTypeEnum will be null
     */
    @IsTest
    private static void determineWorkstreamSettingTypeForUserIdTestNull() {
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum result = null;
        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            result = VCC_WorkstreamSettingsController.determineWorkstreamSettingTypeForUserId(null);
        }
        Test.stopTest();

        Assert.isNull(result, 'Expected enum result to be null when not providing a user Id');
    }

    /**
     * @description Validates that for a user with known MSA permission set group, their resulting VCC_Enum.VCC_WorkstreamSettingsTypeEnum will be MSA
     */
    @IsTest
    private static void determineWorkstreamSettingTypeForUserIdTestMSA() {
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum result = null;
        Test.startTest();
        System.runAs(makeUserWithPermissionSetGroup(PSG_MSA)) {
            result = VCC_WorkstreamSettingsController.determineWorkstreamSettingTypeForUserId(UserInfo.getUserId());
        }
        Test.stopTest();

        Assert.areEqual(
            VCC_Enum.VCC_WorkstreamSettingsTypeEnum.MSA,
            result,
            'Expected enum result to be ' +
                VCC_Enum.VCC_WorkstreamSettingsTypeEnum.MSA.name() +
                ' when not providing a user Id'
        );
    }

    /**
     * @description Validates that for a user with known RN permission set group, their resulting VCC_Enum.VCC_WorkstreamSettingsTypeEnum will be RN
     */
    @IsTest
    private static void determineWorkstreamSettingTypeForUserIdTestRN() {
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum result = null;
        Test.startTest();
        System.runAs(makeUserWithPermissionSetGroup(PSG_RN)) {
            result = VCC_WorkstreamSettingsController.determineWorkstreamSettingTypeForUserId(UserInfo.getUserId());
        }
        Test.stopTest();

        Assert.areEqual(
            VCC_Enum.VCC_WorkstreamSettingsTypeEnum.RN,
            result,
            'Expected enum result to be ' +
                VCC_Enum.VCC_WorkstreamSettingsTypeEnum.RN.name() +
                ' when not providing a user Id'
        );
    }

    /**
     * @description Validates that for a user with known VCV permission set group, their resulting VCC_Enum.VCC_WorkstreamSettingsTypeEnum will be VCV
     */
    @IsTest
    private static void determineWorkstreamSettingTypeForUserIdTestVCV() {
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum result = null;
        Test.startTest();
        System.runAs(makeUserWithPermissionSetGroup(PSG_VCV)) {
            result = VCC_WorkstreamSettingsController.determineWorkstreamSettingTypeForUserId(UserInfo.getUserId());
        }
        Test.stopTest();

        Assert.areEqual(
            VCC_Enum.VCC_WorkstreamSettingsTypeEnum.VCV,
            result,
            'Expected enum result to be ' +
                VCC_Enum.VCC_WorkstreamSettingsTypeEnum.VCV.name() +
                ' when not providing a user Id'
        );
    }

    /**
     * @description Covers and validates the first 2 overloads of VCC_WorkstreamSettingsController.VCC_Model constructor
     */
    @IsTest
    private static void modelConstructorsTest() {
        VCC_WorkstreamSettingsController.VCC_Model result = null;
        Test.startTest();
        System.runAs(getPharmacyTestUser()) {
            result = new VCC_WorkstreamSettingsController.VCC_Model('some type', Datetime.now(), Datetime.now(), 1);
        }
        Test.stopTest();

        Assert.isNotNull(result, 'Expected class to be initialized.');
        Assert.areEqual(
            Date.today().format(),
            result.endDate,
            'Expected model.endDate (String) to match today\'s date. Actual: ' + result.endDate
        );
    }
}
