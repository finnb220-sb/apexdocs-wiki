/**
 * @description Test class for PC_ChatPushEventRepo
 * @author      Booz Allen
 * @since       2024
 * @see         PC_ChatPushEventRepo
 */
@IsTest
private class PC_ChatPushEventRepoTest {
    private final static User FLP_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            FLP_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_FLP_Users')
                .build(true);
        }
    }

    @IsTest
    static void unitTestConstructorPositive() {
        Test.startTest();
        PC_ChatPushEventRepo repo;
        System.runAs(FLP_USER) {
            repo = new PC_ChatPushEventRepo();
        }
        Test.stopTest();

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a PC_ChatPushEventRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=PC_Chat_Push_Event__c'),
            'Expected the SObject type to be PC_Chat_Push_Event__c'
        );
    }
}
