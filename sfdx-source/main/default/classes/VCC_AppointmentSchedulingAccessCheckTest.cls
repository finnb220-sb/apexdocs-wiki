/**
 * @description test class for VCC_AppointmentSchedulingAccessCheck
 * @author Booz Allen Hamilton
 * @see `VCC_AppointmentSchedulingAccessCheck`
 */
@IsTest
public with sharing class VCC_AppointmentSchedulingAccessCheckTest {
    final static User MSA_USER = new VATEST_UserBuilder()
        .withPermissionSet('VCC_Advanced_Medical_Support_Assistant')
        .withPermissionSet('VAHC_Scheduling_User')
        .withUserProfile('VAVET Base Profile')
        .withStandardData()
        .build(true);

    /**
     * @description constructs a stub for VCR_ClinicRepo
     * @param args a `Map<String, Object>` containing the arguments to pass to the stubbed method
     * @param stubClinicRecord the stubbed record to return
     * @return `VCR_ClinicRepo` the constructed stub
     */
    private static VCR_ClinicRepo stubClinicRepo(Map<String, Object> args, VTC_Clinic stubClinicRecord) {
        VCR_ClinicRepo stubClinicRepo = (VCR_ClinicRepo) new VATEST_StubBuilder(VCR_ClinicRepo.class)
            .mockingMethodCall('getClinicByIEN', Map<String, Object>.class)
            .withParameterValues(args)
            .returning((VTC_Record) stubClinicRecord)
            .defineStub();
        return stubClinicRepo;
    }

    /**
     * @description constructs a stub for VCR_IAMSSOiVistaInstToUserDUZRepo and places it in VTC_RepoFactory.reposByObjName 'IAM_SSOi_Vista_Instance_to_User_DUZ__c'
     * @param mockedMethods a `List<VATEST_MockedMethod>` containing methods to mock
     * @return `VATEST_Stub` the constructed stub
     */
    public static VATEST_Stub stubVistaInstanceToUserDuzRepo(List<VATEST_MockedMethod> mockedMethods) {
        VATEST_Stub vistaInstanceToUserDuzRepoStub = new VATEST_Stub(
            VCR_IAMSSOiVistaInstToUserDUZRepo.class,
            mockedMethods
        );
        VTC_RepoFactory.reposByObjName.put(
            'IAM_SSOi_Vista_Instance_to_User_DUZ__c',
            (VCR_IAMSSOiVistaInstToUserDUZRepo) vistaInstanceToUserDuzRepoStub.createStub()
        );
        return vistaInstanceToUserDuzRepoStub;
    }

    /**
     * @description stub all repo's in VCC_AppointmentSchedulingAccessCheck
     * @param mockUserId ID of the User who's appointment scheduling access is being checked
     * @param mockUserDuz the IAM_SSOi_Vista_Instance_to_User_DUZ__c record to return from VCR_IAMSSOiVistaInstToUserDUZRepo.fetchByUserId()
     * @justification test helper method, didn't want to waste time creating an args class
     */
    public static void doStubbing(String mockUserId, IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz) {
        VATEST_MockedMethod fetchByUserIdMockedMethod = (new VATEST_MockedMethod(
                new VATEST_MethodSignature('fetchByUserId', new List<Type>{ Id.class })
            ))
            .withParameterValues(new List<Object>{ mockUserId })
            .returning(new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>{ mockUserDuz });

        stubVistaInstanceToUserDuzRepo(new List<VATEST_MockedMethod>{ fetchByUserIdMockedMethod });
    }

    /**
     * @description testing the no-arg empty constructor
     */
    @IsTest
    static void unitNoArgConstructorPositive() {
        VCC_AppointmentSchedulingAccessCheck schedulingAccessCheck;
        System.runAs(MSA_USER) {
            Test.startTest();
            schedulingAccessCheck = new VCC_AppointmentSchedulingAccessCheck();
            Test.stopTest();
        }
        Assert.isNotNull(schedulingAccessCheck, 'Expected non-null value from no-arg constructor');
        Assert.isNull(
            schedulingAccessCheck.siteId,
            'Expected no-arg constructor to initialize siteId to null because the empty no-arg constructor was used'
        );
        Assert.isNull(
            schedulingAccessCheck.clinicIen,
            'Expected no-arg constructor to initialize clinicIen to null because the empty no-arg constructor was used'
        );
        Assert.isNull(
            schedulingAccessCheck.userId,
            'Expected no-arg constructor to initialize userId to null because the empty no-arg constructor was used'
        );
    }

    /**
     * @description testing the two-arg constructor insuring it picks up the
     * running user Id and initializes site ID and clinic IEN to the correct values
     */
    @IsTest
    static void unitRunningUserConstructorPositive() {
        VCC_AppointmentSchedulingAccessCheck schedulingAccessCheck;
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        System.runAs(MSA_USER) {
            Test.startTest();
            schedulingAccessCheck = new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, clinicRepoStub);
            Test.stopTest();
        }
        Assert.isNotNull(schedulingAccessCheck, 'Expected non-null value from no-arg constructor');
        Assert.areEqual(
            mockSiteId,
            schedulingAccessCheck.siteId,
            'Expected running user constructor to initialize siteId to value in mockSiteId because it was passed into the constructor'
        );
        Assert.areEqual(
            mockClinicIen,
            schedulingAccessCheck.clinicIen,
            'Expected running user constructor to initialize clinicIen to value in mockClinicIen because it was passed into the constructor'
        );
        Assert.areEqual(
            MSA_USER.Id,
            schedulingAccessCheck.userId,
            'Expected running user constructor to initialize userId to the ID of the running user (in this case MSA_USER.Id)'
        );
    }

    /**
     * @description testing the three-arg constructor where user ID is specified and checks that
     * the values giving make it into their associated properties
     */
    @IsTest
    static void unitWithUserIdConstructorPositive() {
        VCC_AppointmentSchedulingAccessCheck schedulingAccessCheck;
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        Id mockUserId = VATEST_IdFactory.get(User.class);
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );

        System.runAs(MSA_USER) {
            Test.startTest();
            schedulingAccessCheck = new VCC_AppointmentSchedulingAccessCheck(
                mockSiteId,
                mockClinicIen,
                mockUserId,
                clinicRepoStub
            );
            Test.stopTest();
        }
        Assert.isNotNull(schedulingAccessCheck, 'Expected non-null value from no-arg constructor');
        Assert.areEqual(
            mockSiteId,
            schedulingAccessCheck.siteId,
            'Expected running user constructor to initialize siteId to value in mockSiteId because it was passed into the constructor'
        );
        Assert.areEqual(
            mockClinicIen,
            schedulingAccessCheck.clinicIen,
            'Expected running user constructor to initialize clinicIen to value in mockClinicIen because it was passed into the constructor'
        );
        Assert.areEqual(
            mockUserId,
            schedulingAccessCheck.userId,
            'Expected running user constructor to initialize userId to value in mockUserId because it was passed into the constructor'
        );
    }

    /**
     * @description testing the constructor with a missing site id. ensuring the correct exception is thrown with the correct exception message
     */
    @IsTest
    static void unitWithUserIdConstructorNullSiteIdNegative() {
        String mockSiteId = null;
        String mockClinicIen = 'clinicIen';
        Id mockUserId = VATEST_IdFactory.get(User.class);
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, mockUserId, clinicRepoStub);
                Assert.fail('Expected an IllegalArgumentException to be thrown because siteId was null');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_AppointmentSchedulingAccessCheck.MISSING_SITE_ID_MESSAGE,
                    illegalArgumentException.getMessage(),
                    'Expected the exception message to be equal to the string stored at ' +
                    'VCC_AppointmentSchedulingAccessCheck.MISSING_SITE_ID_MESSAGE because the siteId is missing'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description testing the constructor with a missing clinic IEN. ensuring the correct exception is thrown with the correct exception message
     */
    @IsTest
    static void unitWithUserIdConstructorNullClinicIenNegative() {
        String mockSiteId = 'siteId';
        String mockClinicIen = null;
        Id mockUserId = VATEST_IdFactory.get(User.class);
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen);
                Assert.fail('Expected an IllegalArgumentException to be thrown because clinicIen was null.');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_AppointmentSchedulingAccessCheck.MISSING_CLINIC_IEN_MESSAGE,
                    illegalArgumentException.getMessage(),
                    'Expected the exception message to be equal to the string stored at ' +
                    'VCC_AppointmentSchedulingAccessCheck.MISSING_CLINIC_IEN_MESSAGE because the clinicIen is missing'
                );
            }
            Test.stopTest();
        }
    }
    /**
     * @description testing the constructor with a missing VCR_ClinicRepo. ensuring the correct exception is thrown with the correct exception message
     */
    @IsTest
    private static void unitWithUserIdConstructorNullClinicRepoNegative() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        Id mockUserId = VATEST_IdFactory.get(User.class);
        VCR_ClinicRepo clinicRepoStub = null;
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, mockUserId, clinicRepoStub);
                Assert.fail('Expected an IllegalArgumentException to be thrown because clinicRepoStub was null.');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_AppointmentSchedulingAccessCheck.MISSING_CLINIC_REPO_MESSAGE,
                    illegalArgumentException.getMessage(),
                    'Expected the exception message to be equal to the string stored at ' +
                    'VCC_AppointmentSchedulingAccessCheck.MISSING_CLINIC_REPO_MESSAGE because the clinicRepo is missing'
                );
            }
            Test.stopTest();
        }
    }
    /**
     * @description testing the constructor with a missing user ID. ensuring the correct exception is thrown with the correct exception message
     */
    @IsTest
    static void unitWithUserIdConstructorNullUserIdNegative() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        Id mockUserId = null;
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        System.runAs(MSA_USER) {
            Test.startTest();
            try {
                new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, mockUserId, clinicRepoStub);
                Assert.fail('Expected an IllegalArgumentException to be thrown because userId was null.');
            } catch (IllegalArgumentException illegalArgumentException) {
                Assert.areEqual(
                    VCC_AppointmentSchedulingAccessCheck.MISSING_USER_ID_MESSAGE,
                    illegalArgumentException.getMessage(),
                    'Expected the exception message to be equal to the string stored at ' +
                    'VCC_AppointmentSchedulingAccessCheck.MISSING_USER_ID_MESSAGE because the userId is missing'
                );
            }
            Test.stopTest();
        }
    }

    /**
     * @description tests that the VCC_AppointmentSchedulingAccessCheck.VCC_Result passed into saveAndReturn() is set to property/attribute
     * accessCheck.savedResult and also returned
     */
    @IsTest
    static void unitSaveAndReturnPositive() {
        VCC_AppointmentSchedulingAccessCheck.VCC_Result mockAccessCheckResult = VCC_AppointmentSchedulingAccessCheck.VCC_Result.DENIED;

        VCC_AppointmentSchedulingAccessCheck accessCheck = new VCC_AppointmentSchedulingAccessCheck();
        VCC_AppointmentSchedulingAccessCheck.VCC_Result returnedResult;
        System.runAs(MSA_USER) {
            Test.startTest();
            returnedResult = accessCheck.saveAndReturn(mockAccessCheckResult);
            Test.stopTest();
        }

        Assert.areEqual(
            mockAccessCheckResult,
            returnedResult,
            'Expected returnedResult to equal mockAccessCheckResult because mockAccessCheckResult was ' +
            'passed as the argument to saveAndReturn and should have been returned'
        );
        Assert.areEqual(
            mockAccessCheckResult,
            accessCheck.savedResult,
            'Expected accessCheck.savedResult to equal mockAccessCheckResult because mockAccessCheckResult' +
            ' was passed as an argument to saveAndReturn and should have been assigned to accessCheck.saveResult'
        );
    }

    /**
     * @description positive stubbed test for the method getUserDuz(). given two IAM_SSOi_Vista_Instance_to_User_DUZ__c records
     * this test ensures that the user DUZ returned is from the record whose VistA_Instance__c field value matches that of the local 'mockSiteId' variable.
     */
    @IsTest
    static void unitGetUserDuzPositive() {
        Id mockUserId = VATEST_IdFactory.get(User.class);
        String mockSiteId = 'siteId';
        String mockUserDuz = 'duz';

        VCC_AppointmentSchedulingAccessCheck apptSchedulingAccessCheck = new VCC_AppointmentSchedulingAccessCheck();
        apptSchedulingAccessCheck.userId = mockUserId;
        apptSchedulingAccessCheck.siteId = mockSiteId;

        VATEST_MockedMethod fetchByUserIdMockedMethod = (new VATEST_MockedMethod(
                new VATEST_MethodSignature('fetchByUserId', new List<Type>{ Id.class })
            ))
            .withParameterValues(new List<Object>{ mockUserId })
            .returning(
                new List<IAM_SSOi_Vista_Instance_to_User_DUZ__c>{
                    new IAM_SSOi_Vista_Instance_to_User_DUZ__c(VistA_Instance__c = '123', DUZ__c = 'abc'),
                    new IAM_SSOi_Vista_Instance_to_User_DUZ__c(VistA_Instance__c = mockSiteId, DUZ__c = mockUserDuz)
                }
            );

        stubVistaInstanceToUserDuzRepo(new List<VATEST_MockedMethod>{ fetchByUserIdMockedMethod });

        String userDuz;
        System.runAs(MSA_USER) {
            Test.startTest();
            userDuz = apptSchedulingAccessCheck.getUserDuz();
            Test.stopTest();
        }

        Assert.areEqual(
            mockUserDuz,
            userDuz,
            'Expected mock return value in mockUserDuz variable to be returned because, ' +
            'of the two stubbed to be returned, the mockUserDuz belonged to the record whose VistA_Instance__c matched the mockSiteId'
        );
    }

    /**
     * @description positive stubbed test that ensures the VTC_Clinic object returned from the repo is
     * the same one returned from the method
     */
    @IsTest
    static void unitGetClinicPositive() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        VCC_AppointmentSchedulingAccessCheck apptSchedulingAccessCheck = new VCC_AppointmentSchedulingAccessCheck(
            mockSiteId,
            mockClinicIen,
            clinicRepoStub
        );

        VTC_Clinic returnedClinic;
        System.runAs(MSA_USER) {
            Test.startTest();
            returnedClinic = apptSchedulingAccessCheck.getClinic();
            Test.stopTest();
        }

        Assert.isTrue(
            mockReturnClinic === returnedClinic,
            'Expected returnedClinic to be a reference to the same object in ' +
            'memory as mockReturnClinic because it was stubbed to be returned'
        );
    }

    /**
     * @description testing that when the clinic is not marked as prohibited via the "prohibitAccess" flag being "false"
     * the returned result is ALLOWED
     */
    @IsTest
    static void unitGetResultNotProhibitedPositive() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            VistA_Instance__c = mockSiteId,
            DUZ__c = 'duz'
        );
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        mockReturnClinic.prohibitAccess = false;
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );

        doStubbing(MSA_USER.Id, mockUserDuz);

        VCC_AppointmentSchedulingAccessCheck.VCC_Result accessResult;
        System.runAs(MSA_USER) {
            Test.startTest();
            accessResult = (new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, clinicRepoStub))
                .getResult();
            Test.stopTest();
        }

        Assert.areEqual(
            VCC_AppointmentSchedulingAccessCheck.VCC_Result.ALLOWED,
            accessResult,
            'Expected access result of ALLOWED because "prohibitAccess" boolean flag on VTC_Clinic is set to "false"'
        );
    }

    /**
     * @description testing that when access is prohibited to the clinic and the clinic has no privileged users
     * the returned result is DENIED
     */
    @IsTest
    static void unitGetResultEmptyPrivilegedUserListPositive() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            VistA_Instance__c = mockSiteId,
            DUZ__c = 'duz'
        );
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        mockReturnClinic.prohibitAccess = true;
        mockReturnClinic.privilegedUsers = new List<VTC_PrivilegedUser>{};
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );

        doStubbing(MSA_USER.Id, mockUserDuz);

        VCC_AppointmentSchedulingAccessCheck.VCC_Result accessResult;
        System.runAs(MSA_USER) {
            Test.startTest();
            accessResult = (new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, clinicRepoStub))
                .getResult();
            Test.stopTest();
        }

        Assert.areEqual(
            VCC_AppointmentSchedulingAccessCheck.VCC_Result.DENIED,
            accessResult,
            'Expected access result of DENIED because "prohibitAccess" boolean flag on VTC_Clinic ' +
            'is set to "true" and the clinic has no privileged users'
        );
    }

    /**
     * @description testing that when access to a clinic is prohibited and the user DUZ *is not* found in the privileged user list
     * the returned value is DENIED
     */
    @IsTest
    static void unitGetResultNotOnPrivilegedUserListPositive() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            VistA_Instance__c = mockSiteId,
            DUZ__c = 'duz'
        );
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        mockReturnClinic.prohibitAccess = true;
        mockReturnClinic.privilegedUsers = new List<VTC_PrivilegedUser>{ new VTC_PrivilegedUser() };
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        doStubbing(MSA_USER.Id, mockUserDuz);

        VCC_AppointmentSchedulingAccessCheck.VCC_Result accessResult;
        System.runAs(MSA_USER) {
            Test.startTest();
            accessResult = (new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, clinicRepoStub))
                .getResult();
            Test.stopTest();
        }

        Assert.areEqual(
            VCC_AppointmentSchedulingAccessCheck.VCC_Result.DENIED,
            accessResult,
            'Expected access result of DENIED because "prohibitAccess" boolean flag on VTC_Clinic ' +
            'is set to "true" and a its list of privilegedUsers did not contain the value in mockUserDuz'
        );
    }

    /**
     * @description testing that when access to a clinic is prohibited and the user DUZ *is* found in the privileged user list
     * the returned result is ALLOWED
     */
    @IsTest
    static void unitGetResultIsOnPrivilegedUserListPositive() {
        String mockSiteId = 'siteId';
        String mockClinicIen = 'clinicIen';
        IAM_SSOi_Vista_Instance_to_User_DUZ__c mockUserDuz = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
            VistA_Instance__c = mockSiteId,
            DUZ__c = 'duz'
        );
        VTC_Clinic mockReturnClinic = new VTC_Clinic();
        VTC_PrivilegedUser mockPrivilegedUser = new VTC_PrivilegedUser();
        mockPrivilegedUser.ien = mockUserDuz.DUZ__c;
        mockReturnClinic.prohibitAccess = true;
        mockReturnClinic.privilegedUsers = new List<VTC_PrivilegedUser>{ mockPrivilegedUser };
        VCR_ClinicRepo clinicRepoStub = stubClinicRepo(
            new Map<String, Object>{
                VCC_AppointmentSchedulingAccessCheck.SITE_ID_KEY => mockSiteId,
                VCC_AppointmentSchedulingAccessCheck.CLINIC_IEN_KEY => mockClinicIen,
                VCC_AppointmentSchedulingAccessCheck.APPLICATION_KEY => 'VAHC'
            },
            mockReturnClinic
        );
        doStubbing(MSA_USER.Id, mockUserDuz);

        VCC_AppointmentSchedulingAccessCheck.VCC_Result accessResult;
        System.runAs(MSA_USER) {
            Test.startTest();
            accessResult = (new VCC_AppointmentSchedulingAccessCheck(mockSiteId, mockClinicIen, clinicRepoStub))
                .getResult();
            Test.stopTest();
        }

        Assert.areEqual(
            VCC_AppointmentSchedulingAccessCheck.VCC_Result.ALLOWED,
            accessResult,
            'Expected access result of ALLOWED because "prohibitAccess" boolean flag on VTC_Clinic ' +
            'is set to "true" and a its list of privilegedUsers contained the value in mockUserDuz'
        );
    }

    /**
     * @description testing that when a savedResult exists, it is returned before any repo access or callouts
     * This test will fail if the callout executes because its not mocked
     */
    @IsTest
    static void unitGetResultMockSavedResultPositive() {
        VCC_AppointmentSchedulingAccessCheck.VCC_Result mockSavedAccessResult = VCC_AppointmentSchedulingAccessCheck.VCC_Result.ALLOWED;

        VCC_AppointmentSchedulingAccessCheck accessCheck = new VCC_AppointmentSchedulingAccessCheck();
        accessCheck.savedResult = mockSavedAccessResult;

        VCC_AppointmentSchedulingAccessCheck.VCC_Result accessResult;
        System.runAs(MSA_USER) {
            Test.startTest();
            accessResult = accessCheck.getResult();
            Test.stopTest();
        }

        Assert.areEqual(
            mockSavedAccessResult,
            accessResult,
            'Expected mockSavedAccessResult to match the returned result because it was set before getResult() was called'
        );
    }
}
