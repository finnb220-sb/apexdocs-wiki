/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: abstract class for shared variables for Salesforce apis
 */
public inherited sharing abstract class BaseSalesforceApi {
    protected String sessionId;
    public BaseSalesforceApi(Boolean useVFPage) {
        if (useVFPage) {
            try {
                // Refer to the Page since LWC doesn't allow using UserInfo.getSessionId() when calling into org.
                PageReference vfPage = Page.DTCSession;
                String vfContent;
                //getContent() is not allow in unit test
                if (!Test.isRunningTest()) {
                    vfContent = vfPage.getContent().toString();
                } else {
                    vfContent = String.format('Start_Of_Session_Id{0}End_Of_Session_Id', new List<Object>{ UserInfo.getSessionId() });
                }
                // Find the position of Start_Of_Session_Id and End_Of_Session_Id
                Integer startP = vfContent.indexOf('Start_Of_Session_Id') + 'Start_Of_Session_Id'.length();
                Integer endP = vfContent.indexOf('End_Of_Session_Id');
                // Get the Session Id
                this.sessionId = vfContent.substring(startP, endP);
            } catch (Exception ex) {
                throw new CalloutException('Unable to access Session Id');
            }
        } else {
            this.sessionId = UserInfo.getSessionId();
        }
    }
}
