/**
 * @description test class for VCR_WorkstreamSettingsRepo
 * - MDT records in org are visible to apex unit tests
 * - Unit tests against custom metadata types can be written in such a way that when a unit test asserts the presence of a specific (known) MDT record, but that record doesn't exist (for whatever reason unrelated to the tested code), that unit test should still pass; it simply confirms the record is not present.
 */

@IsTest
private with sharing class VCR_WorkstreamSettingsRepoTest {
    private static final VCC_Workstream_Settings__mdt PHARMACYSETTINGS_RECORD = VCC_Workstream_Settings__mdt.getInstance(
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy.name()
    );
    private static final VCC_Workstream_Settings__mdt DEFAULTSETTINGS_RECORD = VCC_Workstream_Settings__mdt.getInstance(
        'Default'
    );
    private static final String CHILDRELATIONSHIP_SORTCONFIGS = 'VCC_Workstream_Setting_Sort_Configs__r';
    private static final VCC_Workstream_Setting_Sort_Config__mdt PHARMACYPROBLEM_SORT = VCC_Workstream_Setting_Sort_Config__mdt.getInstance(
        'Pharmacy_Problems'
    );
    private static final VCC_Workstream_Setting_Sort_Config__mdt PHARMACYIMAGING_SORT = VCC_Workstream_Setting_Sort_Config__mdt.getInstance(
        'Pharmacy_Imaging'
    );

    /**
     * @description Inserts a user with VAVET Base Profile, assigns VCC_Pharmacy_I permission set group to the user, and returns the user.
     * @return `User`
     */
    private static User getTestUser() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_Pharmacy_I')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Asserts structure of the memoized VCR_WorkstreamSettingsRepo.dataTypeSettingFieldMap
     * - Seeks to find the VCC_Workstream_Settings__mdt.VCC_Problems_Max__c field from the map.
     */
    @IsTest
    private static void dataTypeSettingFieldMapTest() {
        VCR_WorkstreamSettingsRepo.SettingFieldType fieldType = VCR_WorkstreamSettingsRepo.SettingFieldType.MAX;
        String dataType = VCR_WorkstreamSettingsRepo.DATATYPE_PROBLEMS;
        String expectedFieldName = VCC_Workstream_Settings__mdt.VCC_Problems_Max__c.getDescribe().getName();

        SObjectField field = null;
        String fieldName = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            field = VCR_WorkstreamSettingsRepo.dataTypeSettingFieldMap.get(fieldType).get(dataType);
            fieldName = field?.getDescribe()?.getName();
        }
        Test.stopTest();

        Assert.isNotNull(
            field,
            'Expected to find an SObjectField for field type ' + fieldType.name() + ' and dataType ' + dataType
        );
        Assert.areEqual(
            expectedFieldName,
            fieldName,
            'Expected to find the ' + expectedFieldName + ' field. Actual: ' + fieldName
        );
    }

    /**
     * @description Asserts we can fetch a VCC_Workstream_Settings__mdt record by name
     */
    @IsTest
    private static void fetchWorkstreamSettingTest() {
        VCC_Workstream_Settings__mdt record = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            record = new VCR_WorkstreamSettingsRepo()
                .fetchWorkstreamSetting(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy);
        }
        Test.stopTest();

        if (PHARMACYSETTINGS_RECORD == null) {
            Assert.isNull(record, 'Expected null result because PHARMACYSETTINGS_RECORD does not exist');
            return;
        }
        assertWorkstreamRecordExistsWithExpectedChildren(PHARMACYSETTINGS_RECORD, null, record);
    }

    /**
     * @description asserts that when a null value is passed to fetchWorkstreamSetting(), it returns the Default workstream setting record
     */
    @IsTest
    private static void fetchWorkstreamSettingNull() {
        VCC_Enum.VCC_WorkstreamSettingsTypeEnum nullEnumValue = null;
        VCC_Workstream_Settings__mdt record = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            record = new VCR_WorkstreamSettingsRepo().fetchWorkstreamSetting(nullEnumValue);
        }
        Test.stopTest();

        if (DEFAULTSETTINGS_RECORD == null) {
            Assert.isNull(record, 'Expected null result because DEFAULTSETTINGS_RECORD does not exist');
            return;
        }
        assertWorkstreamRecordExistsWithExpectedChildren(DEFAULTSETTINGS_RECORD, null, record);
    }

    /**
     * @description asserts that when fetching a workstream setting, the record will include a list of ALL child MDT records records
     * - In 1.19.0, this test expects to find the VCC_Workstream_Setting_Sort_Config__mdt.Pharmacy_Problems record, linked to the 'Pharmacy' workstream setting record, if it exists
     */
    @IsTest
    private static void fetchWithChildrenTest() {
        //build a map of expected lists of related MDT records for this test
        Map<String, List<SObject>> expectedChildrenMap = new Map<String, List<SObject>>{
            CHILDRELATIONSHIP_SORTCONFIGS => new List<SObject>()
        };
        if (PHARMACYPROBLEM_SORT != null) {
            expectedChildrenMap.get(CHILDRELATIONSHIP_SORTCONFIGS).add(PHARMACYPROBLEM_SORT);
        }
        if (PHARMACYIMAGING_SORT != null) {
            expectedChildrenMap.get(CHILDRELATIONSHIP_SORTCONFIGS).add(PHARMACYIMAGING_SORT);
        }

        VCC_Workstream_Settings__mdt recordWithAllChildren = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            recordWithAllChildren = new VCR_WorkstreamSettingsRepo()
                .fetchWithChildren(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy);
        }
        Test.stopTest();

        if (PHARMACYSETTINGS_RECORD == null) {
            Assert.isNull(recordWithAllChildren, 'Expected null result because PHARMACYSETTINGS_RECORD does not exist');
            return;
        }
        assertWorkstreamRecordExistsWithExpectedChildren(
            PHARMACYSETTINGS_RECORD,
            expectedChildrenMap,
            recordWithAllChildren
        );
    }

    /**
     * @description This is a helper method to implement all the config-data-dependent assertions against objects in the VCC_Workstream_Settings__mdt table and related tables.
     * - Various test methods in this test class all follow this pattern of only asserting that the repo retrieved data we know to exist.
     * @param expectedRecord `VCC_Workstream_Settings__mdt` a MDT record that we expect to find
     * @param expectedChildrenMap `Map<String, List<SObject>>` a map of expected children, where they keys are child relationship names, and the values are lists of expected MDT records to be found in those related lists
     * @param record `VCC_Workstream_Settings__mdt` the VCC_Workstream_Settings__mdt record we retrieved, hopefully with child MDT record(s) (types unknown at design-time) in related lists
     */
    private static void assertWorkstreamRecordExistsWithExpectedChildren(
        VCC_Workstream_Settings__mdt expectedRecord,
        Map<String, List<SObject>> expectedChildrenMap,
        VCC_Workstream_Settings__mdt record
    ) {
        //don't have expectedRecord, so record should be null, too
        if (expectedRecord == null) {
            Assert.isNull(record, 'Expected null result because expectedRecord does not exist');
            return;
        }

        //have expectedRecord, now validate record and its children.
        Assert.areEqual(
            expectedRecord.DeveloperName,
            record?.DeveloperName,
            'Expected retrieved record.DeveloperName to match provided value (' +
                expectedRecord.DeveloperName +
                '). Actual: ' +
                record?.DeveloperName
        );

        if (expectedChildrenMap != null) {
            //loop over relationship names, and validate we found at least the expected number of children MDT records in each related related list
            //also validate we actually found the children we were looking for (not just same number of children)
            for (String relationshipName : expectedChildrenMap.keySet()) {
                List<SObject> childrenInRelationship = record.getSObjects(relationshipName);
                List<SObject> expectedChildrenInRelationship = expectedChildrenMap.get(relationshipName) ??
                    new List<SObject>();
                Assert.isTrue(
                    (childrenInRelationship?.size() ?? 0) >= expectedChildrenInRelationship.size(),
                    'Expected to find at least ' +
                        expectedChildrenMap.get(relationshipName).size() +
                        ' child MDT records in the ' +
                        relationshipName +
                        ' list. Actual: ' +
                        (childrenInRelationship?.size() ?? 0)
                );
                for (SObject expectedChildRecord : expectedChildrenInRelationship) {
                    Assert.isTrue(
                        listHasRecordDeveloperName(
                            childrenInRelationship,
                            getMDTRecordDeveloperName(expectedChildRecord)
                        ),
                        'Expected to find record named ' +
                            getMDTRecordDeveloperName(expectedChildRecord) +
                            ' in ' +
                            relationshipName +
                            ' related list.'
                    );
                }
            }
        }
    }

    /**
     * @description Indicates if the given list of MDT records contains a record having the given DeveloperName value.
     * - This is a helper method for assertWorkstreamRecordExistsWithExpectedChildren()
     * @param records `List<SObject>` This should be a list of a uniform kind of MDT records
     * @param expectedDeveloperName `String` the DeveloperName value we hope to find
     *
     * @return `Boolean` returns True if it finds the record by DeveloperName
     */
    private static Boolean listHasRecordDeveloperName(List<SObject> records, String expectedDeveloperName) {
        Boolean result = false;
        if (records == null || records?.size() == 0 || expectedDeveloperName == null) {
            return result;
        }
        for (Integer index = 0; index < records.size() && result == false; index++) {
            String recordDeveloperName = getMDTRecordDeveloperName(records.get(index));
            result = recordDeveloperName != null && recordDeveloperName == expectedDeveloperName;
        }
        return result;
    }

    /**
     * @description Reads the 'DeveloperName' value from the given SObject, which should be a MDT record (any type of MDT)
     * - This is a helper method for assertWorkstreamRecordExistsWithExpectedChildren()
     * @param record `SObject` any type of MDT record
     *
     * @return `String` the given record's DeveloperName value, or null.
     */
    private static String getMDTRecordDeveloperName(SObject record) {
        Object recordDeveloperName = record?.get('DeveloperName');
        return recordDeveloperName != null ? (String) recordDeveloperName : null;
    }

    /**
     * @description Asserts that when fetching a workstream setting, the record will include a list of child MDT records records for the 'problems' HDR data type
     * - In 1.19.0, this test expects to find the VCC_Workstream_Setting_Sort_Config__mdt.Pharmacy_Problems record, linked to the 'Pharmacy' workstream setting record, if it exists
     */
    @IsTest
    private static void fetchWithChildrenTestProblems() {
        //build a map of expected lists of related MDT records for this test
        Map<String, List<SObject>> expectedChildrenMap = new Map<String, List<SObject>>{
            CHILDRELATIONSHIP_SORTCONFIGS => new List<SObject>()
        };
        if (PHARMACYPROBLEM_SORT != null) {
            expectedChildrenMap.get(CHILDRELATIONSHIP_SORTCONFIGS).add(PHARMACYPROBLEM_SORT);
        }

        VCC_Workstream_Settings__mdt recordWithProblemsChildren = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            recordWithProblemsChildren = new VCR_WorkstreamSettingsRepo()
                .fetchWithChildren(
                    VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy,
                    VCR_WorkstreamSettingsRepo.DATATYPE_PROBLEMS
                );
        }
        Test.stopTest();

        if (PHARMACYSETTINGS_RECORD == null) {
            Assert.isNull(
                recordWithProblemsChildren,
                'Expected null result because PHARMACYSETTINGS_RECORD does not exist'
            );
            return;
        }
        assertWorkstreamRecordExistsWithExpectedChildren(
            PHARMACYSETTINGS_RECORD,
            expectedChildrenMap,
            recordWithProblemsChildren
        );
    }

    /**
     * @description Validates query logic that, when no child MDT records match the provided hdrDataType (here, "fakeHDRDataType"), the related list(s) will be empty.
     */
    @IsTest
    private static void fetchWithChildrenTestNegative() {
        //for negative test, don't expect to find any children matching "fakeHDRDataType"
        Map<String, List<SObject>> expectedChildrenMap = new Map<String, List<SObject>>{
            CHILDRELATIONSHIP_SORTCONFIGS => new List<SObject>()
        };

        VCC_Workstream_Settings__mdt record = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            record = new VCR_WorkstreamSettingsRepo()
                .fetchWithChildren(VCC_Enum.VCC_WorkstreamSettingsTypeEnum.Pharmacy, 'fakeHDRDataType');
        }
        Test.stopTest();

        if (PHARMACYSETTINGS_RECORD == null) {
            Assert.isNull(record, 'Expected null result because PHARMACYSETTINGS_RECORD does not exist');
            return;
        }
        assertWorkstreamRecordExistsWithExpectedChildren(PHARMACYSETTINGS_RECORD, expectedChildrenMap, record);
    }

    /**
     * @description Validates logic to build sub query against VCC_Workstream_Setting_Sort_Config__mdt table
     */
    @IsTest
    private static void buildSortConfigSubQueryTest() {
        String testWhereClause = 'WHERE VCC_HDR_Data_Type__c = \'Allergies\'';
        String resultAllergy = null;
        String resultNoType = null;
        Test.startTest();
        System.runAs(getTestUser()) {
            resultAllergy = VCR_WorkstreamSettingsRepo.buildSortConfigSubQuery(
                VCR_WorkstreamSettingsRepo.DATATYPE_ALLERGIES
            );
            resultNoType = VCR_WorkstreamSettingsRepo.buildSortConfigSubQuery(null);
        }
        Test.stopTest();
        Assert.isTrue(
            resultAllergy.contains(testWhereClause),
            'Expected query built from \'allergies\' data type to have WHERE clause to contain \'Allergies\''
        );
        Assert.isTrue(
            !(resultNoType.contains('WHERE')),
            'Expected query built from null data type to NOT contain a WHERE clause.'
        );
    }
}
