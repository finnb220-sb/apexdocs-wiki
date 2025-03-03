# How to free up storage space

** Modified SOQLs from [How to free up storage space.docx](https://boozallen.sharepoint.com/:w:/r/teams/LITS-CCC/_layouts/15/Doc.aspx?sourcedoc=%7B19D8B7C0-21A0-4226-A192-BFB8F190E5D6%7D&file=How%20to%20free%20up%20storage%20space.docx&action=default&mobileredirect=true)

Use case: When trying to create a record a storage limit exceeded error is displayed and any new records cannot be created. 

## Steps to resolve: 

Setup > Developer Console > Debug > Open Execute Anonymous Window > enter one of the lines below > Execute

<br><br>
<!-- 
// ### Step 1
-->
** Note: All lines should be executed separately **

-   `Delete [Select Id From LogEntry__c WHERE CreatedDate != LAST_N_DAYS:5 ORDER BY CreatedDate DESC Limit 10000];`
    Run this script 2 times

-   `Delete [Select Id From Logger__c WHERE CreatedDate != LAST_N_DAYS:5 ORDER BY CreatedDate DESC Limit 10000];`

-   `Delete [Select Id From VAF_Phone_Number__c Limit 10000];`

-   `Delete [Select Id From VCC_Recent_View__c Where CreatedDate < TODAY Limit 10000];`

-   `Delete [Select Id From VCC_Vista_User__c Where CreatedBy.Name != 'VA Health Connect Integration User' or LastModifiedBy.Name != 'VA Health Connect Integration User' ORDER BY CreatedDate ASC Limit 10000];`
    Run this script as many times as needed
    <br> Please note any records created and/or updated for the additional signer's functionality of a progress note will need to be created and/or updated.

-   `DELETE [select id, Name from IAM_SSOi_Vista_Instance_to_User_DUZ__c where not (name like 'mock%') limit 10000];`
    Run this until all records that don't start with Mock are removed 

<br><br>
<!-- 
### Step 2

1. Using the data tool of choice (dataloader, dataloader io, Salesforce reports, etc.), export all the `VCC_Vista_User__c` records

1. 🚨 Delete all VistA users except for Ivo, Ryan Mills, Lisa M, Ruben, April Singleton and Mathieu.
   Or run the below script
-->
<!-- ```java
Integer i = 0;

while (i != 3){
	// Creates 4 total queue jobs, each with a delay to start 1 minute after the previous job so they actually delete the right stuff
	Id jobId = System.enqueueJob(new CICD_DeleteVistaUsersQueueable(), i);
	System.debug(jobId);
	i++;
}
``` -->
