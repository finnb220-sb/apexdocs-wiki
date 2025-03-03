/**
 * @description Test class for VCR_ClinicGroupRepo
 * @author Booz Allen Hamilton
 * @since 5/2/2024
 * @see VCR_ClinicGroupRepo
 */
@IsTest
@TestVisible
private class VCR_ClinicGroupRepoTest {
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
    private static VATEST_MockedMethod getMockedMethodSearchClinicGroups() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature('searchClinicGroups', new List<Type>{ String.class, String.class, String.class })
        );
    }

    @TestVisible
    private static VATEST_MockedMethod getMockedMethodGetClinicGroup() {
        return new VATEST_MockedMethod(
            new VATEST_MethodSignature(
                'getClinicGroupByIen',
                new List<Type>{ String.class, String.class, String.class }
            )
        );
    }

    private static VTC_PatientService createPatientService(
        String methodName,
        Map<String, Object> args,
        Object returnValue
    ) {
        return (VTC_PatientService) new VATEST_StubBuilder(VTC_PatientService.class)
            .mockingMethodCall('call')
            .withParameterTypes(String.class, Map<String, Object>.class)
            .withParameterValues(methodName, args)
            .returning(returnValue)
            .defineStub();
    }

    @IsTest
    static void permSearchClinicGroupsPositive() {
        String mockSiteId = '999';
        String mockGroupName = 'test';
        String mockApplicationName = 'VAHC';

        VTC_RecordModel mockReturnValue = new VTC_RecordModel();

        VCR_ClinicGroupRepo.patientService = createPatientService(
            'search_clinic_groups',
            new Map<String, Object>{
                'siteId' => mockSiteId,
                'searchString' => mockGroupName,
                'application' => mockApplicationName
            },
            mockReturnValue
        );

        VTC_RecordModel returnedValue;
        System.runAs(msaUser) {
            Test.startTest();
            returnedValue = (new VCR_ClinicGroupRepo())
                .searchClinicGroups(mockSiteId, mockGroupName, mockApplicationName);
            Test.stopTest();
        }

        Assert.isTrue(
            returnedValue === mockReturnValue,
            'Expected returnedValue and mockReturnValue to reference the same object'
        );
    }

    @IsTest
    static void permMapSearchClinicGroupsArgsPositive() {
        String mockSiteId = '999';
        String mockGroupName = 'test';
        String mockApplicationName = 'SOME_APPLICATION';

        Map<String, Object> mappedArgs;
        System.runAs(msaUser) {
            Test.startTest();
            mappedArgs = (new VCR_ClinicGroupRepo())
                .mapSearchClinicGroupsArgs(mockSiteId, mockGroupName, mockApplicationName);
            Test.stopTest();
        }

        Assert.isNotNull(mappedArgs, 'Expected non-null result from mapSearchClinicGroupsArgs');
        Assert.areEqual(
            mockSiteId,
            mappedArgs.get('siteId'),
            'Expected value in variable "mockSiteId" to be mapped to "siteId"'
        );
        Assert.areEqual(
            mockGroupName,
            mappedArgs.get('searchString'),
            'Expected value in variable "mockGroupName" to be mapped to "searchString"'
        );
        Assert.areEqual(
            mockApplicationName,
            mappedArgs.get('application'),
            'Expected value in variable "mockApplicationName" to be mapped to "application"'
        );
    }

    @IsTest
    static void permGetClinicGroupByIenPositive() {
        String mockGroupIen = 'mockIen';
        String mockSiteId = 'mockSiteId';
        String mockApplicationName = 'mockApplication';

        VTC_RecordModel mockReturnValue = new VTC_RecordModel();
        VCR_ClinicGroupRepo.patientService = createPatientService(
            'get_clinic_group',
            new Map<String, Object>{
                'siteId' => mockSiteId,
                'groupIen' => mockGroupIen,
                'application' => mockApplicationName
            },
            mockReturnValue
        );

        VTC_RecordModel returnedValue;
        System.runAs(msaUser) {
            Test.startTest();
            returnedValue = (new VCR_ClinicGroupRepo())
                .getClinicGroupByIen(mockSiteId, mockGroupIen, mockApplicationName);
            Test.stopTest();
        }

        Assert.isTrue(
            returnedValue === mockReturnValue,
            'Expected return value to be reference to the same place as mockReturnValue'
        );
    }

    @IsTest
    static void permMapGetClinicGroupArgsPositive() {
        String mockGroupIen = 'mockIen';
        String mockSiteId = 'mockSiteId';
        String mockApplicationName = 'mockApplication';

        Map<String, Object> mappedArgs;
        System.runAs(msaUser) {
            Test.startTest();
            mappedArgs = (new VCR_ClinicGroupRepo())
                .mapGetClinicGroupArgs(mockSiteId, mockGroupIen, mockApplicationName);
            Test.stopTest();
        }

        Assert.isNotNull(mappedArgs, 'Expected non-null result from mapGetClinicGroupArgs');
        Assert.areEqual(
            mockSiteId,
            mappedArgs.get('siteId'),
            'Expected value in variable "mockSiteId" to be mapped to "siteId"'
        );
        Assert.areEqual(
            mockGroupIen,
            mappedArgs.get('groupIen'),
            'Expected value in variable "mockGroupIen" to be mapped to "searchString"'
        );
        Assert.areEqual(
            mockApplicationName,
            mappedArgs.get('application'),
            'Expected value in variable "mockApplicationName" to be mapped to "application"'
        );
    }
}
