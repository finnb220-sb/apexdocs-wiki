/**
 * @description Test class for the PC_CaseListController.
 * @author      Booz Allen
 * @see         PC_CaseListController
 **/
@IsTest
public class PC_CaseListControllerTest {
    private final static User SPECIALIST_USER;
    private final static User FLP_USER;

    static {
        SPECIALIST_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('PrC_Specialist_Users')
            .build(true);

        FLP_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('PrC_FLP_Users')
            .build(true);
    }

    /**
     * @description Method to positively test getOldestOpenPrcCaseOwnedByUser method
     **/

    @IsTest
    public static void unitReturnOldestPrcCasePositive() {
        //Create the fake PC User in memory
        PC_Case__c testCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(
            new PC_Case__c(
                Id = VATEST_IdFactory.get(Type.forName('PC_Case__c')),
                Specialist_Notes__c = '',
                Status__c = 'Open'
            )
        );

        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('getOldestOpenPrcCaseOwnedByUser', Id.class)
            .withParameterValues(SPECIALIST_USER.Id)
            .returning(new List<PC_Case__c>{ testCase })
            .defineStub();

        PC_CaseListController.prcCaseRepo = mockedCaseRepo;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            PC_CaseListController.getOpenPcCase();
            Test.stopTest();
        }

        Assert.isTrue(
            testCase.status__c == 'Open',
            'Expected 1 opened PrC Case while executing unitReturnOldestPrcCasePositive()'
        );
    }

    /**
     * @description Method to negatively test getOldestOpenPrcCaseOwnedByUser method
     **/
    @IsTest
    public static void unitReturnOldestPrcCaseNegative() {
        PC_PrcCaseRepo mockedCaseRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            .mockingMethodCall('getOldestOpenPrcCaseOwnedByUser', Id.class)
            .withParameterValues(FLP_USER.Id)
            .throwingException(new QueryException('Failed to return the user\'s PrC Case'))
            .defineStub();

        PC_CaseListController.prcCaseRepo = mockedCaseRepo;
        String auraExceptionMessage;

        System.runAs(FLP_USER) {
            Test.startTest();
            try {
                PC_CaseListController.getOpenPcCase();
            } catch (AuraHandledException caughtException) {
                auraExceptionMessage = caughtException.getMessage();
            }

            Test.stopTest();
        }

        Assert.areEqual(
            'Failed to return the user\'s PrC Case',
            auraExceptionMessage,
            'Expected Aura Exception to be thrown'
        );
    }
}
