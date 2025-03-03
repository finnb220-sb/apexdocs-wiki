/**
 * @author VAHC Liberty IT
 * @since 8/5/2023
 * @description Class that holds apex methods to be used in LWC/Aura components
 * @group Controllers
 */

public with sharing class VCC_AnnouncementController {
    @AuraEnabled
    /**
     * @description gets active Announcements
     * @return List<Announcement__c>
     */
    public static List<Announcement__c> getActiveAnnouncements() {
        return VCC_AnnouncementService.getActiveAnnouncements();
    }
}
