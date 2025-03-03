@SuppressWarnings('PMD.ApexSOQLInjection, sf:SOQLInjection')
@IsTest
/**
 * @description test class to cover Announcement Apex Classes
 * @author VAHC Liberty IT
 * @group Test Classes
 * @see VCC_AnnouncementControllerTest
 */
public with sharing class VCC_AnnouncementControllerTest {
    @IsTest
    private static void getActiveAnnouncements() {
        Test.startTest();
        VCC_AnnouncementController.getActiveAnnouncements();
        List<Schema.SObjectField> sobjectList = new VCC_AnnouncementSelector().getSObjectFieldList();
        new VCC_AnnouncementSelector().addSObjectFields(sobjectList);
        Schema.SObjectType sobjectType = new VCC_AnnouncementSelector().getSObjectType();

        Test.stopTest();
    }
}
