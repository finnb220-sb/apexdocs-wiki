@isTest
public with sharing class VCC_AddPatientModuleTest {
    // @IsTest
    // static void test_template(){
    //     VCC_Stub accountSelectorStub = new VCC_Stub(VCC_AccountSelector.class);
    //     VCC_Stub mpiPackageConnectorStub = new VCC_Stub(VCC_MpiPackageConnector.class);

    //     VCC_AddPatientModule addPatientModule = new VCC_AddPatientModule(
    //         (VCC_AccountSelector) accountSelectorStub.instance,
    //         (VCC_MpiPackageConnector) mpiPackageConnectorStub.instance,
    //     );

    //     Test.startTest();
    //     try{

    //     } catch (Exception e){
    // System.Assert.fail('Unexpected exception: '+e.getMessage()+'\n'+e.getStackTraceString());
    //     }
    //     Test.stopTest();

    // }

    public class Helper {
        VCC_Stub accountSelectorStub = new VCC_Stub(VCC_AccountSelector.class);
        VCC_Stub mpiPackageConnectorStub = new VCC_Stub(VCC_MpiPackageConnector.class);

        public VCC_AddPatientModule getStubbed() {
            return new VCC_AddPatientModule((VCC_AccountSelector) this.accountSelectorStub.instance, (VCC_MpiPackageConnector) this.mpiPackageConnectorStub.instance);
        }

        public VCC_AddPatientModule getUnStubbed() {
            return new VCC_AddPatientModule();
        }
    }

    @IsTest
    static void its_properties_return_the_stubbed_instances() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        Test.startTest();
        try {
            System.Assert.isTrue(addPatientModule.accountSelector === testHelper.accountSelectorStub.instance, 'Expected to find stubbed class');
            System.Assert.isTrue(addPatientModule.mpiPackageConnector === testHelper.mpiPackageConnectorStub.instance, 'Expected to find stubbed class');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void its_properties_return_non_null_values() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getUnStubbed();

        Test.startTest();
        try {
            System.Assert.isNotNull(addPatientModule.accountSelector, 'Expected to find non-null value');
            System.Assert.isNotNull(addPatientModule.mpiPackageConnector, 'Expected to find non-null value');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void addVeteran_rolls_back_database_on_exception() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        testHelper.accountSelectorStub.setException('selectByICN', (Exception) new AuraHandledException('test'));
        Account testAcc = new Account(LastName = 'TestAcc');

        Test.startTest();
        try {
            Savepoint sp = Database.setSavepoint();
            insert testAcc;

            addPatientModule.addVeteran(new Map<String, Object>{}, sp);

            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isTrue([SELECT Id FROM Account WHERE Id = :testAcc.Id LIMIT 1].size() == 0, 'Expected to find no records.');
        }
        Test.stopTest();

        testHelper.accountSelectorStub.assertInvoked('selectByICN');
        testHelper.mpiPackageConnectorStub.assertNotInvoked('saveForm');
        testHelper.mpiPackageConnectorStub.assertNotInvoked('setCorrelation');
    }

    @IsTest
    static void addVeteran_returns_early_when_a_matching_account_is_found() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        Account testAcc = new Account(LastName = 'TestAcc');
        insert testAcc;
        testHelper.accountSelectorStub.setReturnValue('selectByICN', new List<Account>{ testAcc });

        Test.startTest();
        try {
            VCC_AddPatientModule.AddVeteranResult addVetResult = addPatientModule.addVeteran(new Map<String, Object>{}, Database.setSavepoint());
            System.Assert.areEqual(true, addVetResult.patientExists, 'Extected property to be true');
            System.Assert.areEqual(testAcc.Id, addVetResult.accountId, 'Expected matching account Id');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        testHelper.accountSelectorStub.assertInvoked('selectByICN');
        testHelper.mpiPackageConnectorStub.assertNotInvoked('saveForm');
        testHelper.mpiPackageConnectorStub.assertNotInvoked('setCorrelation');
    }

    @IsTest
    static void addVeteran_creates_an_account_and_returns() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        VA_Identity__c vaid = new VA_Identity__c();
        insert vaid;

        testHelper.accountSelectorStub.setReturnValue('selectByICN', null);
        testHelper.mpiPackageConnectorStub.setReturnValue('saveForm', vaid);
        testHelper.mpiPackageConnectorStub.setReturnValue('setCorrelation', null);
        testHelper.mpiPackageConnectorStub.setReturnValue('getIdentityFieldMapping', new MPIDynamicPersonSearchController.MpiFieldMappingWrap());

        Test.startTest();
        try {
            VCC_AddPatientModule.AddVeteranResult addVetResult = addPatientModule.addVeteran(
                new Map<String, Object>{ 'icn' => '1234', 'lastName' => 'test', 'firstName' => 'test' },
                Database.setSavepoint()
            );
            System.Assert.areEqual(false, addVetResult.patientExists, 'Expected property to be false');
            System.Assert.isNotNull(addVetResult.accountId, 'Expected non-null value for accountId');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        testHelper.accountSelectorStub.assertInvoked('selectByICN');
        testHelper.mpiPackageConnectorStub.assertInvoked('saveForm');
        testHelper.mpiPackageConnectorStub.assertInvoked('setCorrelation');
        testHelper.mpiPackageConnectorStub.assertInvoked('getIdentityFieldMapping');
    }

    @IsTest
    static void searchCrm_searches_by_tax_id() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        Account testAcct = new Account();
        testHelper.accountSelectorStub.setReturnValue('addSObjectFields', null);
        testHelper.accountSelectorStub.setReturnValue('selectByTaxId', new List<Account>{ testAcct });

        Test.startTest();
        try {
            VCC_AddPatientModule.SearchCrmResult searchCrmResult = addPatientModule.searchCrm(new Map<String, Object>{ 'ssn' => 'test' });
            System.Assert.areEqual(testAcct, searchCrmResult.accountList[0], 'Expected mock value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        testHelper.accountSelectorStub.assertInvoked('selectByTaxId');
        testHelper.accountSelectorStub.assertNotInvoked('selectAccountsBySearchQuery');
    }

    @IsTest
    static void searchCrm_searches_by_search_query() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        Account testAcct = new Account();
        testHelper.accountSelectorStub.setReturnValue('addSObjectFields', null);
        testHelper.accountSelectorStub.setReturnValue('selectAccountsBySearchQuery', new List<Account>{ testAcct });

        Test.startTest();
        try {
            VCC_AddPatientModule.SearchCrmResult searchCrmResult = addPatientModule.searchCrm(new Map<String, Object>{});
            System.Assert.areEqual(testAcct, searchCrmResult.accountList[0], 'Expected mock value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        testHelper.accountSelectorStub.assertNotInvoked('selectByTaxId');
        testHelper.accountSelectorStub.assertInvoked('selectAccountsBySearchQuery');
    }

    @IsTest
    static void searchMpi_runs() {
        Helper testHelper = new Helper();
        VCC_AddPatientModule addPatientModule = testHelper.getStubbed();

        testHelper.mpiPackageConnectorStub.setReturnValue('mpiPatientSearch', new MPIDynamicPersonSearchController.ResponseWrap('', '', ''));

        Test.startTest();
        try {
            System.Assert.isNotNull(addPatientModule.searchMpi(new Map<String, Object>{ 'test' => 'test' }));
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        testHelper.mpiPackageConnectorStub.assertInvoked('mpiPatientSearch');
    }
}
