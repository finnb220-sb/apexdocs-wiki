/**
 * Author:Jaren Yach
 *  Created Date 05/04/2022
 *  Purpose: Unit test class for DeleteCustomSettingsBatch
 */
@IsTest
private class DeleteCustomSettingsBatchTest {
    @IsTest
    static void testDelete() {
        // Create a new mock provider
        MockProvider mock = new MockProvider();

        // Create mock instances
        DTCSandboxRefreshClearSettingSelector mockSelector = (DTCSandboxRefreshClearSettingSelector) mock.createMock(DTCSandboxRefreshClearSettingSelector.class);

        // Create a mock injector
        Injector mockInjector = (Injector) mock.createMock(Injector.class);

        // Setup the Injector to return the mock injector
        Injector.mockInjector = mockInjector;

        // Assign Mock Classes
        mock.setMock().mockReturnValue(mockInjector.instantiate('DTCSandboxRefreshClearSettingSelector'), mockSelector);

        List<DTC_Sandbox_Refresh_Clear_Custom_Setting__mdt> configRecords = new List<DTC_Sandbox_Refresh_Clear_Custom_Setting__mdt>();

        DTC_Sandbox_Refresh_Clear_Custom_Setting__mdt mockSettingRecord = new DTC_Sandbox_Refresh_Clear_Custom_Setting__mdt();
        mockSettingRecord.Label = 'Account';
        mockSettingRecord.DeveloperName = 'Account';
        mockSettingRecord.Api_Object_Name__c = 'Account';
        configRecords.add(mockSettingRecord);

        // Mock return values
        mock.setMock().mockReturnValue(mockSelector.getAllRecords(), configRecords);

        //Using Account as the sobject because don't know which custom settings are in org
        Account a = new Account();
        a.Name = 'Test';
        Database.SaveResult result = Database.insert(a, false);

        Test.startTest();
        DeleteCustomSettingsBatch.run();
        Test.stopTest();

        if (result.isSuccess()) {
            System.assertEquals(0, [SELECT COUNT() FROM Account]);
        }
    }
}
