@IsTest
private with sharing class VCC_MPI_HTTPTest {
    @IsTest
    private static void unitCreateRequestPositive() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            // try, catch block, and check for no error
            try {
                VCC_MPI_HTTP.createRequest('POST', '', 'vccMPIeCorrelateWithTraits');
            } catch (VCC_MPI_HTTP.MPIException e) {
                System.assert(e == null, 'There was no error');
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitCreateRequestNegative() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            try {
                VCC_MPI_HTTP.createRequest('POST', '', 'invalidEndPoint');
            } catch (VCC_MPI_HTTP.MPIException e) {
                System.assertEquals(e.getTypeName(), 'VCC_MPI_HTTP.MPIException', 'Known exception for test.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitDispatchRequestNegative() {
        User runAsUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TestDataFactory.assignPermissionSetByName(runAsUser, 'VAHC_Standard_VCC_User');
        System.runAs(runAsUser) {
            Test.startTest();
            try {
                HttpRequest req = VCC_MPI_HTTP.createRequest('POST', 'regression', 'vccMPIeCorrelateWithTraits');
                VCC_MPI_HTTP.dispatchRequest(req);
            } catch (VCC_MPI_HTTP.MPIException e) {
                System.assertEquals(e.getTypeName(), 'VCC_MPI_HTTP.MPIException', 'Known exception for test.');
            }
            Test.stopTest();
        }
    }
}
