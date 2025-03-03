/**
 * Author:Jaren Yach
 *  Created Date 05/04/2022
 *  Purpose: This class is to remove .invalid from the email field for users
 *  that have been white listed.
 *
 *  Without sharing is used because this needs to run in a system context.
 */
public without sharing class RevertInvalidEmailsBatch implements Database.Batchable<SObject> {
    private Set<Id> userIds;
    public RevertInvalidEmailsBatch() {
        userIds = new Set<Id>();
        DTCSandboxRefreshUserWhiteListSelector config = (DTCSandboxRefreshUserWhiteListSelector) Injector.getInjector().instantiate('DTCSandboxRefreshUserWhiteListSelector');
        for (DTC_Sandbox_Refresh_User_Whitelist__mdt rec : config.getAllRecords()) {
            userIds.add(rec.UserId__c);
        }
    }

    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, Email, ProfileId FROM User WHERE Id IN :this.userIds AND IsActive = TRUE]);
    }

    public void execute(Database.BatchableContext context, List<User> users) {
        Profile sysAdminProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        List<User> usersToUpdate = new List<User>();
        DTCSandboxRefreshSettingSelector settingSelector = (DTCSandboxRefreshSettingSelector) Injector.getInjector().instantiate('DTCSandboxRefreshSettingSelector');
        DTC_Sandbox_Refresh_Setting__mdt setting = settingSelector.getSettingForOrg();
        for (User u : users) {
            u.Email = u.Email.removeEndIgnoreCase('.invalid');
            if (u.ProfileId != sysAdminProfile.Id && setting.Update_To_System_Admin_Profile__c) {
                u.ProfileId = sysAdminProfile.Id;
            }
            usersToUpdate.add(u);
        }

        if (usersToUpdate.size() > 0) {
            //Attempt update on records that can be updated
            List<Database.SaveResult> results = Database.update(usersToUpdate, false);
        }
    }

    public void finish(Database.BatchableContext context) {
        DTCUtils.sendCompletedBatchJobEmail(context.getJobId());
    }

    /**
     * Easy way to run this batch job
     *
     * @return Job Id
     */
    public static String run() {
        return Database.executeBatch(new RevertInvalidEmailsBatch());
    }
}
