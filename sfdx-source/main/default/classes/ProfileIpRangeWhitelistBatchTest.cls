@IsTest
private class ProfileIpRangeWhitelistBatchTest {
    @IsTest
    static void testRunJob() {
        Boolean exceptionReached = false;
        // Create a new mock provider
        MockProvider mock = new MockProvider();

        // Create mock instances
        OrganizationSelector mockOrganizationSelector = (OrganizationSelector) mock.createMock(OrganizationSelector.class);
        ProfileIpWhitelistSettingSelector mockProfileIpWhitelistSettingSelector = (ProfileIpWhitelistSettingSelector) mock.createMock(ProfileIpWhitelistSettingSelector.class);
        DTCSandboxRefreshSettingSelector mockSettingSelector = (DTCSandboxRefreshSettingSelector) mock.createMock(DTCSandboxRefreshSettingSelector.class);

        // Create a mock injector
        Injector mockInjector = (Injector) mock.createMock(Injector.class);

        // Setup the Injector to return the mock injector
        Injector.mockInjector = mockInjector;

        // Assign Mock Classes
        mock.setMock().mockReturnValue(mockInjector.instantiate('OrganizationSelector'), mockOrganizationSelector);
        mock.setMock().mockReturnValue(mockInjector.instantiate('ProfileIpWhitelistSettingSelector'), mockProfileIpWhitelistSettingSelector);
        mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshSettingSelector'), mockSettingSelector);
        mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshSettingSelector'), mockSettingSelector);

        // Mock Organization Values
        Map<String, Object> genericOrgRec = new Map<String, Object>();
        genericOrgRec.put('IsSandbox', true);
        Organization orgRec = (Organization) JSON.deserialize(JSON.serialize(genericOrgRec), Organization.class);
        mock.setMock().mockReturnValue(mockOrganizationSelector.getRecord(), orgRec);

        // Mock DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt Values
        List<DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt> configRecords = new List<DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt>();
        DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt mockSettingRecord = new DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt();
        mockSettingRecord.Label = 'System Administrator';
        mockSettingRecord.DeveloperName = 'System_Administrator';
        mockSettingRecord.ProfileId__c = UserInfo.getProfileId();
        configRecords.add(mockSettingRecord);
        mock.setMock().mockReturnValue(mockProfileIpWhitelistSettingSelector.getAllRecords(), configRecords);

        // Mock DTC_Sandbox_Refresh_Setting__mdt record
        DTC_Sandbox_Refresh_Setting__mdt mockRefreshSettingRecord = new DTC_Sandbox_Refresh_Setting__mdt();
        mockRefreshSettingRecord.Label = 'Default';
        mockRefreshSettingRecord.DeveloperName = 'Default';
        mockRefreshSettingRecord.Run_Ip_Range_Whitelist__c = true;
        mock.setMock().mockReturnValue(mockSettingSelector.getSettingForOrg(), mockRefreshSettingRecord);

        //Tooling API Mock
        String toolingResponseJson =
            '{"totalSize":1,"size":1,"records":[{"Name":"System Administrator","Id":"' +
            UserInfo.getProfileId() +
            '","FullName":"Admin"}],"queryLocator":null,"nextRecordsUrl":null,"entityTypeName":"Profile"}';
        CalloutRequestMock toolingApiResponse = new CalloutRequestMock(200, 'OK', toolingResponseJson, null);

        //Metadata API Mock
        String metadataReponseXml = '<?xml version="1.0" encoding="UTF-8"?><soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns="http://soap.sforce.com/2006/04/metadata"><soapenv:Body><updateMetadataResponse><result><fullName>Admin</fullName><success>true</success></result></updateMetadataResponse></soapenv:Body></soapenv:Envelope>';
        CalloutRequestMock metadataResponse = new CalloutRequestMock(200, 'OK', metadataReponseXml, null);

        //Assign Mock HTTP callouts
        Map<String, HttpCalloutMock> mockCallouts = new Map<String, HttpCalloutMock>();
        String toolingApiUrl =
            Url.getSalesforceBaseUrl().toExternalForm() +
            '/services/data/v54.0/tooling/query/?q=SELECT+Id%2CName%2CFullName+FROM+Profile+where+Id+in%28%27' +
            UserInfo.getProfileId() +
            '%27%29';
        mockCallouts.put(toolingApiUrl, toolingApiResponse);
        String metadataApiUrl = Url.getSalesforceBaseUrl().toExternalForm() + '/services/Soap/m/' + SalesforceRestApi.API_VERSION;
        mockCallouts.put(metadataApiUrl, metadataResponse);
        HttpCalloutMock multiCalloutMock = new MultiCalloutRequestMock(mockCallouts);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);

        Test.startTest();
        try {
            SandboxRefreshAdminController.runProfileIpRange();
        } catch (Exception ex) {
            exceptionReached = true;
        }
        Test.stopTest();
        //Updating IP Range is not something we can assert.  Assert that we didn't get an exception thrown.
        System.assertEquals(false, exceptionReached);
    }
}
