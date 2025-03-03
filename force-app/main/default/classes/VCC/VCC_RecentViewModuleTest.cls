@IsTest
public with sharing class VCC_RecentViewModuleTest {
    @IsTest
    static void isValidRecentViewTypeTest() {
        VCC_RecentViewModule recentViewModule = (VCC_RecentViewModule) VCC_ModuleService.getModule(VCC_RecentViewModule.class);

        Test.startTest();
        Assert.isTrue(recentViewModule.isValidRecentViewType(VCC_RecentViewModule.TYPE_IN_PATIENT), 'Expected true. If picklist values have changed, this may need to be updated.');
        Assert.isFalse(recentViewModule.isValidRecentViewType('some value that\'s not valid'), 'Expected false.');
        Test.stopTest();
    }

    @IsTest
    static void validateRecentViewTypeTestSad() {
        VCC_RecentViewModule recentViewModule = (VCC_RecentViewModule) VCC_ModuleService.getModule(VCC_RecentViewModule.class);

        VCC_RecentViewModule.RecentViewModuleException expectedException;
        String expectedMessage = recentViewModule.INVALID_VIEW_TYPE_MSG;

        Test.startTest();

        try {
            recentViewModule.validateRecentViewType('some value that\'s not valid');
        } catch (VCC_RecentViewModule.RecentViewModuleException caughtException) {
            expectedException = caughtException;
        }

        Test.stopTest();

        Assert.isNotNull(expectedException, 'Expected to catch an exception.');
        Assert.areEqual(expectedMessage, expectedException.getMessage(), 'Expected correct exception message.');
    }

    @IsTest
    static void validateRecentViewTypeTestHappy() {
        VCC_RecentViewModule recentViewModule = (VCC_RecentViewModule) VCC_ModuleService.getModule(VCC_RecentViewModule.class);

        Exception unexpectedException;

        Test.startTest();

        try {
            recentViewModule.validateRecentViewType(VCC_RecentViewModule.TYPE_IN_PATIENT);
        } catch (Exception caughtException) {
            unexpectedException = caughtException;
        }

        Test.stopTest();

        Assert.isNull(unexpectedException, 'Expected no exception. If picklist values have changed, this needs updating.');
    }

    @IsTest
    static void insertNewRecentViewTest() {
        VCC_RecentViewModule recentViewModule = (VCC_RecentViewModule) VCC_ModuleService.getModule(VCC_RecentViewModule.class);

        Account account = new Account(LastName = 'test');
        insert account;

        Exception unexpectedException;
        VCC_Recent_View__c recentView;

        Test.startTest();

        try {
            recentView = recentViewModule.insertNewRecentView(account.Id, VCC_RecentViewModule.TYPE_IN_PATIENT);
            recentViewModule.acknowledgeRecentView(recentView.Id, VCC_RecentViewModule.TYPE_IN_PATIENT);
        } catch (Exception caughtException) {
            unexpectedException = caughtException;
        }

        Test.stopTest();

        Assert.isNull(unexpectedException, 'Expected no exception.');
        Assert.isNotNull(recentView, 'Expected a new recent view record. If picklist values have changed, this likely needs updating.');
    }
}
