@IsTest
public with sharing class VCC_MpiPackageConnectorTest {
    @IsTest
    static void it_constructs_with_empty_constructor() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_MpiPackageConnector(), 'Expected non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_constructs_with_non_empty_constructor() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_MpiPackageConnector(new VCC_MpiPackageConnector.Traits()), 'Expected non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    public class Helper {
        public VCC_Stub patientSearchImplStub = new VCC_Stub(VCC_MpiPackagePatientSearch.class);
        public VCC_Stub saveFormImplStub = new VCC_Stub(VCC_MpiPackageSaveForm.class);
        public VCC_Stub setCorrelationImplStub = new VCC_Stub(VCC_MpiPackageSetCorrelation.class);
        public VCC_Stub getIdentityFieldMappingImplStub = new VCC_Stub(VCC_MpiPackageGetFieldMapping.class);

        public VCC_MpiPackageConnector.Traits getStubbedTraits() {
            VCC_MpiPackageConnector.Traits packageTraits = new VCC_MpiPackageConnector.Traits();
            packageTraits.getIdentityFieldMappingImpl = (VCC_MpiPackageGetFieldMapping) getIdentityFieldMappingImplStub.instance;
            packageTraits.patientSearchImpl = (VCC_MpiPackagePatientSearch) patientSearchImplStub.instance;
            packageTraits.saveFormImpl = (VCC_MpiPackageSaveForm) saveFormImplStub.instance;
            packageTraits.setCorrelationImpl = (VCC_MpiPackageSetCorrelation) setCorrelationImplStub.instance;
            return packageTraits;
        }
    }

    @IsTest
    static void it_can_call_all_methods() {
        Helper testHelper = new Helper();
        VCC_MpiPackageConnector mpiPackageConnector = new VCC_MpiPackageConnector(testHelper.getStubbedTraits());

        testHelper.patientSearchImplStub.setReturnValue('mpiPatientSearch', null);
        testHelper.saveFormImplStub.setReturnValue('saveForm', null);
        testHelper.setCorrelationImplStub.setReturnValue('setCorrelation', null);
        testHelper.getIdentityFieldMappingImplStub.setReturnValue('getCustomMetadataMpiFieldMapping', null);

        Test.startTest();
        try {
            mpiPackageConnector.mpiPatientSearch('reqBody');
            mpiPackageConnector.saveForm('objectApiName', 'mpiSalesforceInsertFieldMap', 'mpiVetRecord', 'userName');
            mpiPackageConnector.setCorrelation((SObject) new Account(), 'mpiSalesforceFieldName', 'mpiVetRecord', 'userId', 'userName');
            mpiPackageConnector.getIdentityFieldMapping();
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();

        testHelper.patientSearchImplStub.assertInvoked('mpiPatientSearch');
        testHelper.saveFormImplStub.assertInvoked('saveForm');
        testHelper.setCorrelationImplStub.assertInvoked('setCorrelation');
        testHelper.getIdentityFieldMappingImplStub.assertInvoked('getCustomMetadataMpiFieldMapping');
    }
}
