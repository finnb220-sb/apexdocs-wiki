/**
 * @description Repository class for the PrC_User__c object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since
 */
public inherited sharing class PC_PrcUserRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_PrcUserRepo. Calls super constructor which sets this.sObjectType to 'PC_User__c'
     */
    public PC_PrcUserRepo() {
        super(PC_User__c.sObjectType);
    }

    /**
     * @description  Retrieves the PC_User__c record related the the current running user
     *
     * @param userId the salesforce user Id of the current running user
     * @param selectFieldsSet appends fields to the SELECT statement dynamically
     * @return       `List<PC_User__c>` List of PrC User records returned by the query (Will only be one or zero records)
     */
    private List<PC_User__c> fetchPrcUserByUserId(Id userId, Set<String> selectFieldsSet) {
        String selectClause = 'SELECT ' + String.join(selectFieldsSet, ', ');
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE User_ID__c = :userId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' Order By CreatedDate DESC LIMIT 1';
        return (List<PC_User__c>) this.fetch(query, new Map<String, Object>{ 'userId' => userId });
    }

    //
    /**
     * @description  Sends in a list of default select statement fields to the main PC_User__c fetch method

     * @param userId the salesforce user Id of the current running user
     * @return       `List<PC_User__c>` List of PrC User records returned by the query (Will only be one or zero records)
     */
    public List<PC_User__c> fetchPrcUserByUserId(Id userId) {
        /** NOTE: Please only add fields that exist directly on the PC_User object
         *  This method is used by upsertPrcUser() and some spanning fields will interfere with the upsert DML
         */
        Set<String> defaultFields = new Set<String>{
            'Id',
            'User_ID__c',
            'Latitude__c',
            'Longitude__c',
            'Current_Location__c',
            'Location_Address2__c'
        };

        return this.fetchPrcUserByUserId(userId, defaultFields);
    }

    /**
     * @description           Sends in a list of specific select statement fields to the main PC_User__c fetch method
     * @param userId          the salesforce user Id of the current running user
     * @param selectFieldsSet list of fields to use in the SELECT statement
     * @return                `List<PC_User__c>` List of PrC User records returned by the query (Will only be one or zero records)
     */
    public List<PC_User__c> fetchPrcUserByUserIdWithSelectFields(Id userId, Set<String> selectFieldsSet) {
        return this.fetchPrcUserByUserId(userId, selectFieldsSet);
    }

    /**
     * @description   Upserts the PC_User__c record, but checks for a pre-existing PC_User__c for the same sf User Id prior to upsert to help prevent duplicates
     * @param prcUser PC_User__c to be upserted (generally the running user's respective PC_User__c record)
     * @return        `PC_User__c` PC_User record post-upsert
     */
    public PC_User__c upsertPrcUser(PC_User__c prcUser) {
        //check for existing PC_User__c with the same User_ID__c to prevent duplicates
        if (String.isBlank(prcUser.Id)) {
            List<PC_User__c> existingPrcUserWithUserID = this.fetchPrcUserByUserId(prcUser.User_ID__c);
            prcUser.Id = existingPrcUserWithUserID.size() > 0 ? existingPrcUserWithUserID[0].Id : prcUser.Id;
        }

        this.doUpsert(prcUser);

        return prcUser;
    }
}
