@isTest
@SuppressWarnings('PMD.MethodNamingConventions')
public with sharing class VCC_AddPatientControllerTest {
    private static String username = 'apc';

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
        return [SELECT Id, MVIICN__c, Username FROM User WHERE Username LIKE :username + '%'];
    }

    // ---------------------------------- STUBBED TESTING --------------------------------------

    // @IsTest
    // static void test_template(){
    //     VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
    //     VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

    //     Test.startTest();
    //     try{
    //         // System.Assert.fail('Expected an exception.');
    //     } catch (Exception e){
    //         // System.Assert.fail('Unexpected exception: '+e.getMessage()+'\n'+e.getStackTraceString());
    //     }
    //     Test.stopTest();
    // }

    @IsTest
    static void searchMpi_returns_a_result_err() {
        VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
        VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

        AuraHandledException mockException = new AuraHandledException('test');
        addPatientModuleStub.setException('searchMpi', mockException);

        Test.startTest();
        try {
            VCC_Result searchMpiResult = VCC_AddPatientController.searchMpi(new Map<String, Object>());
            System.Assert.areEqual(true, VCC_Result.isErr(searchMpiResult), 'Expected true from isErr');
            System.Assert.isInstanceOfType(VCC_Result.asErr(searchMpiResult).value, VCC_AddPatientController.ControllerError.class, 'Expected a controller error');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        addPatientModuleStub.assertInvoked('searchMpi');
    }

    @IsTest
    static void searchMpi_runs_successfully_stubbed() {
        VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
        VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

        MPIDynamicPersonSearchController.ResponseWrap mockResponse = new MPIDynamicPersonSearchController.ResponseWrap(
            '',
            '',
            '',
            JSON.serialize(
                new List<Object>{
                    new Map<String, Object>{ // bad
                        'personType' => 'test',
                        'dod' => 'test',
                        'medicalCenterFacilities' => new List<String>{}
                    },
                    new Map<String, Object>{ // bad
                        'personType' => 'test',
                        'dod' => null,
                        'medicalCenterFacilities' => new List<String>{}
                    },
                    new Map<String, Object>{ // good
                        'personType' => 'PAT',
                        'medicalCenterFacilities' => new List<String>{ 'test' },
                        'dod' => null
                    },
                    null
                }
            )
        );
        addPatientModuleStub.setReturnValue('searchMpi', mockResponse);

        Test.startTest();
        try {
            VCC_Result searchMpiResult = VCC_AddPatientController.searchMpi(new Map<String, Object>());
            System.Assert.areEqual(true, VCC_Result.isOk(searchMpiResult), 'Expected isOk to return true');
            VCC_AddPatientController.SearchMpiResponse searchMpiResponse = (VCC_AddPatientController.SearchMpiResponse) VCC_Result.asOk(searchMpiResult).value;
            System.Assert.areEqual(1, searchMpiResponse.allData.size(), 'Expected one element in allData');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        addPatientModuleStub.assertInvoked('searchMpi');
    }

    @IsTest
    static void searchCrm_returns_a_result_err() {
        VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
        VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

        AuraHandledException mockException = new AuraHandledException('test');
        addPatientModuleStub.setException('searchMpi', mockException);

        Test.startTest();
        try {
            VCC_Result searchCrmResult = VCC_AddPatientController.searchCrm(new Map<String, Object>());
            System.Assert.areEqual(true, VCC_Result.isErr(searchCrmResult), 'Expected true from isErr');
            System.Assert.isInstanceOfType(VCC_Result.asErr(searchCrmResult).value, VCC_AddPatientController.ControllerError.class, 'Expected a controller error');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        addPatientModuleStub.assertInvoked('searchCrm');
    }

    @IsTest
    static void searchCrm_runs_successfully_stubbed() {
        VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
        VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

        VCC_AddPatientModule.SearchCrmResult mockResponse = new VCC_AddPatientModule.SearchCrmResult();
        addPatientModuleStub.setReturnValue('searchCrm', mockResponse);

        Test.startTest();
        try {
            VCC_Result searchCrmResult = VCC_AddPatientController.searchCrm(new Map<String, Object>());
            System.Assert.areEqual(true, VCC_Result.isOk(searchCrmResult), 'Expected isOk to return true');
            System.Assert.isInstanceOfType(VCC_Result.asOk(searchCrmResult).value, VCC_AddPatientController.SearchCrmResponse.class, 'Expected correct data type');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        addPatientModuleStub.assertInvoked('searchCrm');
    }

    @IsTest
    static void addVeteran_returns_a_result_err() {
        VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
        VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

        AuraHandledException mockException = new AuraHandledException('test');
        addPatientModuleStub.setException('addVeteran', mockException);

        Test.startTest();
        try {
            VCC_Result addVeteranResult = VCC_AddPatientController.addVeteran(new Map<String, Object>());
            System.Assert.isTrue(VCC_Result.isErr(addVeteranResult), 'Expected isErr to be true');
            System.Assert.isInstanceOfType(VCC_Result.asErr(addVeteranResult).value, VCC_AddPatientController.ControllerError.class, 'Expected a controller error');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        addPatientModuleStub.assertInvoked('addVeteran');
    }

    @IsTest
    static void addVeteran_runs_successfully_stubbed() {
        VCC_Stub addPatientModuleStub = new VCC_Stub(VCC_AddPatientModule.class);
        VCC_AddPatientController.addPatientModule = (VCC_AddPatientModule) addPatientModuleStub.instance;

        VCC_AddPatientModule.AddVeteranResult mockResponse = new VCC_AddPatientModule.AddVeteranResult();
        addPatientModuleStub.setReturnValue('addVeteran', mockResponse);

        Test.startTest();
        try {
            VCC_Result addVeteranResult = VCC_AddPatientController.addVeteran(new Map<String, Object>());
            System.Assert.areEqual(true, VCC_Result.isOk(addVeteranResult), 'Expected isOk to return true');
            VCC_AddPatientController.AddVeteranResponse addVeteranResponse = (VCC_AddPatientController.AddVeteranResponse) VCC_Result.asOk(addVeteranResult).value;
            System.Assert.isNotNull(addVeteranResponse, 'Expected non-null value');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        addPatientModuleStub.assertInvoked('addVeteran');
    }
    // ------------------------------- FULL END-TO-END --------------------------------

    @IsTest
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    static void searchMpi_end_to_end() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_MPISearchSingleVet');
        mock.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, mock);
        Test.startTest();
        for (User u : getTestUsers()) {
            System.runAs(u) {
                try {
                    VCC_AddPatientController.searchMpi(new Map<String, Object>());
                } catch (Exception e) {
                    System.Assert.fail('Unexpected exception: ' + u.Username + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
                }
            }
        }
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    static void searchCrm_by_tax_id_end_to_end() {
        //this value comes from VCC_MPISearchSingleVet static resource and is an account in the QA env's PHIL KUBICKI
        Account testAcc = new Account(
            LastName = 'KUBICKI',
            HealthCloudGA__TaxId__c = '101383042',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        insert testAcc;

        //req'd because SOSL
        Test.setFixedSearchResults(new List<Id>{ testAcc.Id });

        Test.startTest();
        for (User u : getTestUsers()) {
            System.runAs(u) {
                try {
                    VCC_Result searchCrmResult = VCC_AddPatientController.searchCrm(new Map<String, Object>{ 'ssn' => '101383042' });
                    System.Assert.areEqual(true, VCC_Result.isOk(searchCrmResult), 'Expected result to be OK');
                    VCC_AddPatientController.SearchCrmResponse searchCrmResponse = (VCC_AddPatientController.SearchCrmResponse) VCC_Result.asOk(searchCrmResult).value;
                    System.Assert.isNotNull(searchCrmResponse, 'Expected non-null value for searchCrmResponse.');
                    System.Assert.isTrue(searchCrmResponse.accountList.size() > 0, 'Expected one result.');
                    System.Assert.areEqual(testAcc?.Id, searchCrmResponse?.accountList[0]?.Id, 'Expected to find matching account Id.');
                } catch (Exception e) {
                    System.Assert.fail('Unexpected exception: ' + u.Username + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
                }
            }
        }
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    static void searchCrm_by_other_end_to_end() {
        //this value comes from VCC_MPISearchSingleVet static resource and is an account in the QA env's PHIL KUBICKI
        Account testAcc = new Account(
            LastName = 'KUBICKI',
            RecordTypeId = Account.getSObjectType().getDescribe().getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId()
        );
        insert testAcc;

        Test.startTest();
        for (User u : getTestUsers()) {
            System.runAs(u) {
                try {
                    VCC_Result searchCrmResult = VCC_AddPatientController.searchCrm(new Map<String, Object>{ 'lastName' => 'KUBICKI' });
                    System.Assert.areEqual(true, VCC_Result.isOk(searchCrmResult), 'Expected result to be OK');
                    VCC_AddPatientController.SearchCrmResponse searchCrmResponse = (VCC_AddPatientController.SearchCrmResponse) VCC_Result.asOk(searchCrmResult).value;
                    System.Assert.isNotNull(searchCrmResponse, 'Expected non-null value for searchCrmResponse.');
                    System.Assert.isTrue(searchCrmResponse.accountList.size() > 0, 'Expected one result.');
                    System.Assert.areEqual(testAcc?.Id, searchCrmResponse?.accountList[0]?.Id, 'Expected to find matching account Id.');
                } catch (Exception e) {
                    System.Assert.fail('Unexpected exception: ' + u.Username + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
                }
            }
        }
        Test.stopTest();
    }

    @IsTest
    @SuppressWarnings('PMD.OperationWithLimitsInLoop')
    static void addVeteran_end_to_end() {
        Test.startTest();
        for (User u : getTestUsers()) {
            System.runAs(u) {
                System.debug(u.Username);
                Savepoint testSavePoint = Database.setSavepoint();
                try {
                    VCC_Result addVetResult = VCC_AddPatientController.addVeteran(new Map<String, Object>{ 'icn' => '1234', 'address' => 'test', 'lastName' => 'test' });
                    System.Assert.areEqual(true, VCC_Result.isOk(addVetResult), 'Expected result to be OK');
                    VCC_AddPatientController.AddVeteranResponse addVetResponse = (VCC_AddPatientController.AddVeteranResponse) VCC_Result.asOk(addVetResult).value;
                } catch (Exception e) {
                    System.Assert.fail('Unexpected exception: ' + u.Username + '\n' + e.getMessage() + '\n' + e.getStackTraceString());
                }
                Database.rollback(testSavePoint);
            }
        }
        Test.stopTest();
    }
}
