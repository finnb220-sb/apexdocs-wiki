/**
 * @description Test class for VCC_ClinicGroupSearchController
 * @author Booz Allen Hamilton
 * @since 5/1/2024
 * @see VCC_ClinicGroupSearchController
 */
@IsTest
@TestVisible
private class VCC_ClinicGroupSearchControllerTest {
    /**
     * @description memoized msaUser
     */
    private static User msaUser {
        get {
            return msaUser = msaUser ??
                new VATEST_UserBuilder()
                    .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
                    .withPermissionSet('VAHC_Scheduling_User')
                    .withUserProfile('VAVET Base Profile')
                    .withStandardData()
                    .build(true);
        }
        set;
    }

    @TestVisible
    private static VATEST_Stub stubClinicGroupRepo(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub clinicGroupRepoStub = new VATEST_Stub(VCR_ClinicGroupRepo.class, mockedMethods);
        VCC_ClinicGroupSearchController.clinicGroupRepo = (VCR_ClinicGroupRepo) clinicGroupRepoStub.createStub();
        return clinicGroupRepoStub;
    }

    @IsTest
    static void permClinicGroupRepoAttributePositive() {
        VCR_ClinicGroupRepo testClinicGroupRepo = new VCR_ClinicGroupRepo();
        System.runAs(msaUser) {
            Test.startTest();
            VCC_ClinicGroupSearchController.clinicGroupRepo = testClinicGroupRepo;
            Assert.areEqual(
                testClinicGroupRepo,
                VCC_ClinicGroupSearchController.clinicGroupRepo,
                'Expected attribute to contain repo created in this test method.'
            );
            Test.stopTest();
        }
    }

    @IsTest
    static void permSearchClinicGroupsPositive() {
        String mockSiteId = '999';
        String mockGroupName = 'grp';
        VTC_RecordModel mockReturnValue = new VTC_RecordModel();
        VATEST_MockedMethod searchClinicGroupsMockedMethod = VCR_ClinicGroupRepoTest.getMockedMethodSearchClinicGroups()
            .withParameterValues(
                new List<Object>{ mockSiteId, mockGroupName, VCC_ClinicGroupSearchController.VAHC_APPLICATION_NAME }
            )
            .returning(mockReturnValue);
        stubClinicGroupRepo(new List<VATEST_MockedMethod>{ searchClinicGroupsMockedMethod });

        List<VTC_Record> returnedList;
        System.runAs(msaUser) {
            Test.startTest();
            returnedList = VCC_ClinicGroupSearchController.searchClinicGroups(mockSiteId, mockGroupName);
            Test.stopTest();
        }

        Assert.areEqual(
            mockReturnValue.records,
            returnedList,
            'Expected returned list to match the mocked/stubbed value.'
        );
        searchClinicGroupsMockedMethod.assertMockedMethodWasCalled();
    }

    @IsTest
    static void permSearchClinicGroupsNullResponseNegative() {
        String mockSiteId = '999';
        String mockGroupName = 'grp';
        VATEST_MockedMethod searchClinicGroupsMockedMethod = VCR_ClinicGroupRepoTest.getMockedMethodSearchClinicGroups()
            .withParameterValues(
                new List<Object>{ mockSiteId, mockGroupName, VCC_ClinicGroupSearchController.VAHC_APPLICATION_NAME }
            )
            .returning((Object) null);
        stubClinicGroupRepo(new List<VATEST_MockedMethod>{ searchClinicGroupsMockedMethod });

        List<VTC_Record> returnedList;
        System.runAs(msaUser) {
            Test.startTest();
            returnedList = VCC_ClinicGroupSearchController.searchClinicGroups(mockSiteId, mockGroupName);
            Test.stopTest();
        }

        Assert.isNull(returnedList, 'Expected null return value');
        searchClinicGroupsMockedMethod.assertMockedMethodWasCalled();
    }

    @IsTest
    static void permGetClinicGroup() {
        String mockSiteId = '999';
        String mockGroupIen = '123';

        VATEST_MockedMethod getClinicGroupMockedMethod = VCR_ClinicGroupRepoTest.getMockedMethodGetClinicGroup()
            .withParameterValues(
                new List<Object>{ mockSiteId, mockGroupIen, VCC_ClinicGroupSearchController.VAHC_APPLICATION_NAME }
            )
            .returning(new VTC_CHROResourceGroupModel(new VTC_CHROGetClinicGroupRS()));
        stubClinicGroupRepo(new List<VATEST_MockedMethod>{ getClinicGroupMockedMethod });

        VTC_Record clinicGroup;
        System.runAs(msaUser) {
            Test.startTest();
            clinicGroup = VCC_ClinicGroupSearchController.getClinicGroup(mockSiteId, mockGroupIen);
            Test.stopTest();
        }

        Assert.isNotNull(clinicGroup, 'Expected return value from getClinicGroup');
    }
}
