/**
 * @description Class for Phone Directory Search
 * @author      Booz Allen Hamilton
 */
public with sharing class VCC_PhoneDirectorySearchController {
    public List<VCC_Softphone_Directory__c> searchResults { get; set; }
    public String searchKey { get; set; }
    public String searchMethod { get; set; }
    /**
     * @description Search method for Softphone Directory
     */
    public void search() {
        //use SOSL if configured to do so, otherwise use SOQL
        if (this.searchMethod != null && this.searchMethod.toLowerCase() == 'sosl') {
            this.searchResults = querySoftphoneDirectorySOSL(this.searchKey);
            return;
        }
        this.searchResults = querySoftphoneDirectorySOQL(this.searchKey);
    }
    /**
     * @description        SOQL Query for Softphone Directory Search
     * @param searchString Contains the search input from the user searching for a contact within the Softphone Directory by Name, Description, or Phone Number
     * @return             `List<VCC_Softphone_Directory__c>` Containing Results of the SOQL Query with the contact Name, Description, and Phone Number
     */
    public List<VCC_Softphone_Directory__c> querySoftphoneDirectorySOQL(String searchString) {
        List<VCC_Softphone_Directory__c> result = new List<VCC_Softphone_Directory__c>();
        if (searchString == null || String.isblank(searchString)) {
            return result;
        }
        String searchStringWC = '%' + searchString + '%';
        result = [
            SELECT Id, Name, Description__c, Phone_Number__c
            FROM VCC_Softphone_Directory__c
            WHERE
                Name LIKE :searchStringWC
                OR Description__c LIKE :searchStringWC
                OR Phone_Number__c LIKE :searchStringWC
            WITH SECURITY_ENFORCED
            ORDER BY Name
            LIMIT 50
        ];
        return result;
    }
    /**
     * @description        SOSL Query for Softphone Directory Search
     * @param searchString Contains the search input from the user searching for a contact within the Softphone Directory by Name, Description, or Phone Number
     * @return             `List<VCC_Softphone_Directory__c>` Containing Results of the SOSL Query with the contact Name, Description, and Phone Number
     */
    public List<VCC_Softphone_Directory__c> querySoftphoneDirectorySOSL(String searchString) {
        List<VCC_Softphone_Directory__c> result = new List<VCC_Softphone_Directory__c>();

        if (searchString == null || String.isBlank(searchString)) {
            return result;
        }

        String soslStringWC = String.escapeSingleQuotes(searchString);

        if (searchString.right(1) <> '*') {
            soslStringWC = soslStringWC + '*';
        }
        if (soslStringWC.replaceAll('[^a-zA-Z0-9\\s+]', '').length() > 1) {
            List<List<sObject>> records = [
                FIND :soslStringWC
                RETURNING VCC_Softphone_Directory__c(Name, Description__c, Phone_Number__c ORDER BY Name)
                WITH USER_MODE
                LIMIT 50
            ];
            result = records.get(0);
        }

        return result;
    }
}
