/**
 * @description Test class for PC_FeedItemRepo.
 * @author      Booz Allen
 * @since       2024
 * @see         PC_FeedItemRepo
 * @see         VCR_FeedItemRepo
 */
@IsTest
private class PC_FeedItemRepoTest {
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
        PC_FeedItemRepo repo;
        System.runAs(FLP_USER) {
            repo = new PC_FeedItemRepo();
        }
        Test.stopTest();

        Assert.isNotNull(repo, 'Expected constructor to properly instantiate a PC_FeedItemRepo class object');
        Assert.isTrue(
            String.valueOf(repo).containsIgnoreCase('VTC_BaseRepo.sObjectType=FeedItem'),
            'Expected the SObject type to be FeedItem'
        );
    }
}
