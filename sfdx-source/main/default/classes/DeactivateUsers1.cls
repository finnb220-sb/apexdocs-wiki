/**
 * Author:Jaren Yach
 *  Created Date 04/27/2022
 *  Purpose: This modifies the original DeactivateUsers class written by Jaya Dabbara on 01/25/2017.  The Below code is for sending emails to
 *  users who will be deactivated because they haven't logged in for 90 days or were created 90 days ago and never logged in.  It will also
 *  send 'warning' emails to users at day 76 (2 weeks before deactivation).  The actual deactivation of the user account happens in the
 *  DeactivateUsers2 class due to the DML error noted below when trying to do the email and user update in the same transaction.
 */
public class DeactivateUsers1 implements Database.Batchable<SObject>, Database.Stateful, Schedulable {
    //75 days, instead of 76 is used here to query all records that meet the warning date since it is a datetime field.  Only users with a date of 76 days > today
    //will receive a warning email.
    public static final User_Deactivation_Configuration__mdt USERCONFIG = User_Deactivation_Configuration__mdt.getInstance('Default');
    public Datetime pastSeventyFiveDaysDate = Date.today().addDays(-Integer.valueOf(USERCONFIG.Warning_Days__c));
    public Datetime pastSeventyFiveDaysDateTime = Date.today().addDays(-Integer.valueOf(USERCONFIG.Warning_Days__c));

    //Set of Ids of users to deactivate, this will be passed into DeactivateUsers2
    private Set<Id> userIdsToDeactivate;

    //Used for asserting unit tests, since unable to assert email invocations in batch context
    @TestVisible
    private static List<Messaging.SingleEmailMessage> testEmailsSent = new List<Messaging.SingleEmailMessage>();

    //This is the query to obtain all records that need to be evaluated for a warning message or deactivation.  Any changes here should be made in Deactivate2.  Where not WHAM permission sets
    String query;

    public DeactivateUsers1() {
        userIdsToDeactivate = new Set<Id>();
    }

    //Get the full list of user records that may receive warning messages or be deactivated
    public Database.QueryLocator start(Database.BatchableContext bc) {
        //SecRisk-00317, do not deactivate or warn users that are in the permission sets
        UserDeactivationWhitelistSelector whiteListSelector = (UserDeactivationWhitelistSelector) Injector.getInjector().instantiate('UserDeactivationWhitelistSelector');
        Set<String> permissionSetApiNamesToIgnore = new Set<String>();
        for (User_Deactivation_Whitelist__mdt rec : whiteListSelector.getAllRecords()) {
            permissionSetApiNamesToIgnore.add(rec.Api_Name__c);
        }

        query = 'SELECT Name, FirstName, LastName, LastLoginDate, CreatedDate, Deactivation_Date__c, Reactivation_Date__c, Id,Email From User';
        query += ' WHERE IsActive = true AND User_Type__c = null AND Profile.Name != null';
        query += ' AND ((CreatedDate <=:pastSeventyFiveDaysDateTime AND LastLoginDate = null) OR (LastLoginDate <=:pastSeventyFiveDaysDate))';
        query += ' AND Profile.UserLicense.Name != \'Guest User License\'';

        if (permissionSetApiNamesToIgnore.size() > 0) {
            query += ' AND Id NOT IN (SELECT AssigneeId From PermissionSetAssignment WHERE PermissionSet.Name in:permissionSetApiNamesToIgnore)';
        }

        if (Test.isRunningTest()) {
            //Prevents No more than one executeBatch can be called from within a testmethod
            //https://help.salesforce.com/s/articleView?language=en_US&type=1&id=000330685
            Id currentUserId = UserInfo.getUserId();
            query += ' AND CreatedById =:currentUserId';
        }

        query += ' Order By LastLoginDate LIMIT 4500';
        return Database.getQueryLocator(query);
    }

    //Process each batch of records.  200 is the default
    public void execute(Database.BatchableContext bc, List<User> scope) {
        List<User> warningList = new List<User>();
        List<User> deactivateList = new List<User>();
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();
        Datetime maxDate;
        List<Datetime> compareDate = new List<Datetime>();
        Integer dateDiff;

        //Assign the first day warning emails get sent
        Set<Integer> warningDaysToSendEmail = new Set<Integer>{ Integer.valueOf(USERCONFIG.Email_Warning_Days__c) };
        //Holds userId to number of days since last login
        Map<Id, Integer> userIdToLastLoginDays = new Map<Id, Integer>();

        Integer warningDays = Integer.valueOf(USERCONFIG.Email_Warning_Days__c);
        Integer deactivationDays = Integer.valueOf(USERCONFIG.Deactivation_Days__c);
        Integer repeatWarningDays = Integer.valueOf(USERCONFIG.Days_To_Repeat_Warning_Email__c);
        //Calculate the next warning days that an email would get sent out
        do {
            warningDays += repeatWarningDays;
            //Add next days that warning email get sent
            warningDaysToSendEmail.add(warningDays);
        } while (warningDays + repeatWarningDays < deactivationDays);

        //Loop through each user record passed into the batch
        for (User u : scope) {
            //Compare the current date against the max value of Last Login Date, Created Date or Reactivation Date
            //Deactivate if >=90 Days or send warning emails if warningDaysToSendEmail contains dateDiff
            compareDate.add(u.CreatedDate);
            if (u.LastLoginDate != null) {
                compareDate.add(u.LastLoginDate);
            }
            if (u.Reactivation_Date__c != null) {
                compareDate.add(u.Reactivation_Date__c);
            }
            compareDate.sort();
            maxDate = compareDate[compareDate.size() - 1];
            dateDiff = (maxDate.date()).daysBetween(System.today());

            if (dateDiff >= Integer.valueOf(USERCONFIG.Deactivation_Days__c)) {
                deactivateList.add(u);
            } else if (warningDaysToSendEmail.contains(dateDiff)) {
                warningList.add(u);
                userIdToLastLoginDays.put(u.Id, dateDiff);
            }
            compareDate.clear();
        }

        //Send warning emails
        if (warningList.size() > 0) {
            String orgUrl = DTCUtils.getOrgUrl();
            for (User usr : warningList) {
                //Calculate days since last login and when the user will be deactivated
                Integer daysSinceLastLogin = userIdToLastLoginDays.get(usr.Id);
                Integer numberOfDaysUntilDeactivated = Integer.valueOf(USERCONFIG.Deactivation_Days__c) - daysSinceLastLogin;
                Date deactivationDate = Date.today().addDays(numberOfDaysUntilDeactivated);

                String warningParagraph1 = String.format(
                    Label.WarningEmail,
                    new List<Object>{ daysSinceLastLogin, deactivationDate.format(), '<a href="' + orgUrl + '">' + orgUrl + '</a>' }
                );
                String warningParagraph2 = Label.SalesforceDetails;
                String warningParagraph3 = Label.VA_Integrated_Enterprise_Workflow_Solution;
                String warningParagraph4 = Label.VA_Intranet_Website;

                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSenderDisplayName(USERCONFIG.From_Email_Address__c);
                mail.setTargetObjectId(usr.Id);
                mail.setSaveAsActivity(false);
                mail.setSubject(Label.WarningEmailSubject);
                mail.setHtmlBody(
                    usr.FirstName +
                        ',' +
                        '<br/>' +
                        '<br/>' +
                        warningParagraph1 +
                        '<br/>' +
                        '<br/>' +
                        warningParagraph2 +
                        '<br/>' +
                        '<br/>' +
                        warningParagraph3 +
                        '<br/>' +
                        '<br/>' +
                        warningParagraph4
                );
                emailsToSend.add(mail);
            }
        }

        //Send deactivation emails and deactivate the users.
        if (deactivateList.size() > 0) {
            String deactivateParagraph1 = Label.DeactivationEmail;
            String deactivateParagraph2 = Label.SalesforceDetails;
            String deactivateParagraph3 = Label.VA_Integrated_Enterprise_Workflow_Solution;
            String deactivateParagraph4 = Label.VA_Intranet_Website;
            for (User usr : deactivateList) {
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setSenderDisplayName(USERCONFIG.From_Email_Address__c);
                mail.setTargetObjectId(usr.Id);
                mail.setSaveAsActivity(false);
                mail.setSubject(Label.DeactivationEmailSubject);
                mail.setHtmlBody(
                    usr.FirstName +
                        ',' +
                        '<br/>' +
                        '<br/>' +
                        deactivateParagraph1 +
                        '<br/>' +
                        '<br/>' +
                        deactivateParagraph2 +
                        '<br/>' +
                        '<br/>' +
                        deactivateParagraph3 +
                        '<br/>' +
                        '<br/>' +
                        deactivateParagraph4
                );
                emailsToSend.add(mail);
                userIdsToDeactivate.add(usr.Id);
            }
        }

        if (emailsToSend.size() > 0) {
            List<Messaging.SendEmailResult> results = Messaging.sendEmail(emailsToSend, false);

            //If we are running a unit test add successful emails to list to allow for assertions
            if (Test.isRunningTest()) {
                for (Integer i = 0; i < results.size(); i++) {
                    Messaging.SendEmailResult result = results[i];
                    if (result.isSuccess()) {
                        testEmailsSent.add(emailsToSend[i]);
                    }
                }
            }
        }
    }

    public void finish(Database.BatchableContext bc) {
        try {
            //Batch Chain to call this class to update the user in a separate transaction from the email (above).  The reason being that the email kicks off a bunch
            //of downstream workflows - one where the email meets the rule condition and performs a DML operation.  This caused a DML error on the update to the user
            //record, hence we broke this out into a separate class which will then run the update in a separate batch transaction.  Trying to use queueable, @future,
            //disabling triggers for the user running it - nothing else worked.  Preferably, we'd send the email and do the user update in one class. Note:  Only
            //call the 2nd batch if there are users to deactivate

            if (!Test.isRunningTest() && userIdsToDeactivate.size() > 0) {
                DeactivateUsers2 uu = new DeactivateUsers2(userIdsToDeactivate);
                Database.executeBatch(uu);
            }
        } catch (Exception e) {
        } finally {
            DTCUtils.sendCompletedBatchJobEmail(bc.getJobId());
        }
    }

    //This is the required execute method for the schedulable implementation
    public void execute(SchedulableContext ctx) {
        Database.executeBatch(new DeactivateUsers1());
    }
}
