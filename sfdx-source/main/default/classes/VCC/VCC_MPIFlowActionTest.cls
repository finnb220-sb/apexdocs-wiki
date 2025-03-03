/**
 * @description       : VCC_MPIFlowActionTest Apex Test Class
 * @author            : Booz Allen Hamilton
 * @date              : 03-22-2024
 **/
@IsTest
private class VCC_MPIFlowActionTest {
    private static final User VAVET_BASE_USER;
    private static final User SYS_ADMIN_USER;

    static {
        VAVET_BASE_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_Medical_Provider')
            .withStandardData()
            .build(true);

        SYS_ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Inserting test user
     */
    @TestSetup
    static void makeData() {
        //Create Account Data
        Id personAccountRecordTypeId = Account.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
            .getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();

        Account newPersonAccount = new Account();
        newPersonAccount.MVI_External_Id__pc = '1012881470V086192';
        newPersonAccount.RecordTypeId = personAccountRecordTypeId;
        System.runAs(SYS_ADMIN_USER) {
            VATEST_SObjectFactory.createSObject(newPersonAccount, 'VATEST_SObjectFactory.AccountDefaults', true);
        }

    }

    /**
     * @description  Test method for null response from MPI Callout
     */
    @IsTest
    static void funcNullResponseFromMPICalloutAction() {
        Account acct = [SELECT Id FROM Account LIMIT 1];

        List<VCC_MPIFlowAction.FlowInput> flowInputs = new List<VCC_MPIFlowAction.FlowInput>();
        VCC_MPIFlowAction.FlowInput flowInput = new VCC_MPIFlowAction.FlowInput();
        flowInput.recordId = acct.Id;
        flowInputs.add(flowInput);

        VCC_MPIFlowAction.response = null;

        System.runAs(VAVET_BASE_USER) {
            Assert.areEqual(0, VCC_MPIFlowAction.calloutToMPI(flowInputs).size(), 'Response was not null');
        }
    }

    /**
     * @description  Test method for when a response is received from the MPI Callout
     */
    @isTest
    static void funcDataResponseFromMPICalloutAction() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        List<VCC_MPIFlowAction.FlowInput> flowInputs = new List<VCC_MPIFlowAction.FlowInput>();
        VCC_MPIFlowAction.FlowInput flowInput = new VCC_MPIFlowAction.FlowInput();
        flowInput.recordId = acct.Id;
        flowInputs.add(flowInput);

        StaticResource resource = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MPI_VAProfile' LIMIT 1];
        VCC_MPIFlowAction.response = (VCC_MPIParser) JSON.deserialize(resource.Body.toString(), VCC_MPIParser.class);

        System.runAs(VAVET_BASE_USER) {
            List<VCC_MPIFlowAction.FlowOutput> outputs = new List<VCC_MPIFlowAction.FlowOutput>(
                VCC_MPIFlowAction.calloutToMPI(flowInputs)
            );
            Assert.isTrue(outputs.size() > 0, 'Bad response returned');
        }
    }

    /**
     * @description  Test method for when a response is received from the MPI Callout
     */
    @IsTest
    static void funcDataBranchesIsNullFromMPICalloutAction() {
        Account acct = [SELECT Id FROM Account LIMIT 1];
        List<VCC_MPIFlowAction.FlowInput> flowInputs = new List<VCC_MPIFlowAction.FlowInput>();
        VCC_MPIFlowAction.FlowInput flowInput = new VCC_MPIFlowAction.FlowInput();
        flowInput.recordId = acct.Id;
        flowInputs.add(flowInput);

        StaticResource resource = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MPI_VAProfile' LIMIT 1];
        String response = resource.Body.toString();
        String stringToRemove = response.substringBetween('"serviceBranches": [', ']');
        VCC_MPIFlowAction.response = (VCC_MPIParser) JSON.deserialize(
            resource.Body.toString().replace(stringToRemove, ''),
            VCC_MPIParser.class
        );

        System.runAs(VAVET_BASE_USER) {
            List<VCC_MPIFlowAction.FlowOutput> outputs = new List<VCC_MPIFlowAction.FlowOutput>(
                VCC_MPIFlowAction.calloutToMPI(flowInputs)
            );
            Assert.isTrue(outputs.size() > 0, 'Bad response returned');
        }
    }
}
