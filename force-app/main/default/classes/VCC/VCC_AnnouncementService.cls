/**
 * @author VAHC Liberty IT
 * @since 8/5/2023
 * @description Class that holds apex methods to get Announcements
 * @group Controllers
 */

public with sharing class VCC_AnnouncementService {
    /**
     * @description gets active Announcements
     * @return List<Announcement__c>
     */
    public static List<Announcement__c> getActiveAnnouncements() {
        return new VCC_AnnouncementSelector().selectActiveAnnouncement();
    }
}
