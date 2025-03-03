@IsTest
private class ResetNamedCredentialBatchTest {
    @IsTest
    static void testResetNamedCredentialForSandbox() {
        Boolean exceptionReached = false;
        // Create a new mock provider
        MockProvider mock = new MockProvider();

        // Create mock instances
        OrganizationSelector mockSelector = (OrganizationSelector) mock.createMock(OrganizationSelector.class);

        // Create a mock injector
        Injector mockInjector = (Injector) mock.createMock(Injector.class);

        // Setup the Injector to return the mock injector
        Injector.mockInjector = mockInjector;

        // Assign Mock Classes
        mock.setMock().mockReturnValue(mockInjector.instantiate('OrganizationSelector'), mockSelector);

        // Mock return values
        Map<String, Object> genericOrgRec = new Map<String, Object>();
        genericOrgRec.put('IsSandbox', true);
        Organization orgRec = (Organization) JSON.deserialize(JSON.serialize(genericOrgRec), Organization.class);
        mock.setMock().mockReturnValue(mockSelector.getRecord(), orgRec);

        //Mock HTTP Callout
        CalloutRequestMock fakeResponse = new CalloutRequestMock(204, 'No Content', '', null);
        Test.setMock(HttpCalloutMock.class, fakeResponse);

        //Make NC generic since fields are not writeable
        Map<String, Object> genericNc = new Map<String, Object>();
        genericNc.put('MasterLabel', 'Foo');
        genericNc.put('Id', UserInfo.getUserId());
        genericNc.put('Endpoint', 'https://www.salesforce.com');
        NamedCredential nc = (NamedCredential) JSON.deserialize(JSON.serialize(genericNc), NamedCredential.class);

        try {
            SandboxRefreshAdminController.runNamedCredentials();
            new ResetNamedCredentialBatch().resetNamedCredentialForSandbox(nc);
        } catch (Exception ex) {
            exceptionReached = true;
        }
        System.assertEquals(false, exceptionReached);
    }
}
