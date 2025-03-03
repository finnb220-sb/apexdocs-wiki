/**
 * @description This repository class provides specialized data retrieval functionality
 *              for the IAM_SSOi_Vista_Instance_to_User_DUZ__c object by extending the
 *              VTC_BaseRepo. It includes methods to fetch records based on the current
 *              user's ID and mock SSO settings, ensuring efficient data management
 *              and access control.
 * 
 *              The IAM_SSOi_Vista_Instance_to_User_DUZ__c object contains fields used 
 *              to facilitate user login into the CPRS/VistA external system. The fields 
 *              such as DUZ__c and VistA_Instance__c are crucial for mapping the Salesforce 
 *              user to their corresponding records in the VistA system.

 * @author Booz Allen
 */
public virtual inherited sharing class VCR_IAMSSOiVistaInstToUserDUZRepo extends VTC_BaseRepo {
    /**
     * @description Constructor for VCR_IAMSSOiVistaInstToUserDUZRepo
     *
     *              Initializes the repository with the IAM_SSOi_Vista_Instance_to_User_DUZ__c
     *              SObjectType and adds 'VistA_Instance__c' to the default selection fields.
     */

    public VCR_IAMSSOiVistaInstToUserDUZRepo() {
        this(false);
    }

    /**
     * @description Constructor for VCR_IAMSSOiVistaInstToUserDUZRepo
     *              Initializes the repository with the IAM_SSOi_Vista_Instance_to_User_DUZ__c
     *              SObjectType and adds 'VistA_Instance__c' to the default selection fields.
     *
     * @param blnAllowUnsafe If true (default), unsafe DML statements are not allowed & will result in an
     *  exception to that affect being thrown. If false, then the invoking code must provide valid
     *  justification for the need for unsafe DML.
     */
    public VCR_IAMSSOiVistaInstToUserDUZRepo(Boolean blnAllowUnsafe) {
        super(IAM_SSOi_Vista_Instance_to_User_DUZ__c.sObjectType, blnAllowUnsafe);
        this.defaultSelectFields.add('VistA_Instance__c');
    }

    /**
     * @description Fetches records from the IAM_SSOi_Vista_Instance_to_User_DUZ__c object where the User_Id__c matches the current user's ID.
     * This method constructs a SOQL query that selects the DUZ__c and VistA_Instance__c fields from the IAM_SSOi_Vista_Instance_to_User_DUZ__c object,
     * filtering the records where User_Id__c is equal to the current Salesforce user's ID as obtained through UserInfo.getUserId().
     * The method leverages the base repository's fetch method to execute the query in the context of the running user, ensuring that only accessible records are returned.
     * @param userId
     * @return An array of SObject records matching the query criteria. Each SObject can be cast to IAM_SSOi_Vista_Instance_to_User_DUZ__c to access specific fields.
     */
    public List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> fetchByUserId(Id userId) {
        Set<String> fieldsToSelect = new Set<String>(this.defaultSelectFields);
        fieldsToSelect.addAll(new List<String>{ 'Id', 'DUZ__c', 'User_Id__c', 'VistA_Instance__c' });

        String selectClause = this.calculateSelectClause(fieldsToSelect);
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE User_Id__c = :userId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;

        // Using the fetch method from the base class
        return this.fetch(query, new Map<String, Object>{ 'userId' => userId });
    }

    /**
     * @description Fetches a single IAM_SSOi_Vista_Instance_to_User_DUZ__c record for the user based on the current MOCK SSO setting.
     *
     * @param userId The Id of the user for whom the record is to be fetched.
     * @return SObject The IAM_SSOi_Vista_Instance_to_User_DUZ__c record if found, or null if not found.
     */
    public IAM_SSOi_Vista_Instance_to_User_DUZ__c fetchMockSSORecord(Id userId) {
        Set<String> fieldsToSelect = new Set<String>{ 'Id', 'DUZ__c', 'User_Id__c', 'VistA_Instance__c' };

        String selectClause = this.calculateSelectClause(fieldsToSelect);
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE User_Id__c = :userId AND Name LIKE \'mockSSO%\'';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' LIMIT 1';

        // Using the fetch method from the base class
        List<IAM_SSOi_Vista_Instance_to_User_DUZ__c> results = this.fetch(
            query,
            new Map<String, Object>{ 'userId' => userId }
        );

        if (results == null || results.isEmpty()) {
            return null;
        } else {
            return results[0];
        }
    }

    /**
     * @description Insert the given recordToInsert using SYSTEM_MODE as required by invoking code.
     *
     * @justification This insert MUST be executed in Unsafe mode (SYSTEM_MODE) due to a platform
     *  limitation. It is NOT possible to insert custom settings records without the Customize Application
     *  permission which we do not expect running user to have.
     *
     * @param recordToInsert `IAM_SSOi_Vista_Instance_to_User_DUZ__c` instance to insert in SYSTEM_MODE
     */
    public void performUnsafeInsert(IAM_SSOi_Vista_Instance_to_User_DUZ__c recordToInsert) {
        this.doCreateUnsafe(recordToInsert);
    }

    /**
     * @description Insert the given recordToUpdate using SYSTEM_MODE as required by invoking code.
     *
     * @justification This insert MUST be executed in Unsafe mode (SYSTEM_MODE) due to a platform
     *  limitation. It is NOT possible to update custom settings records without the Customize Application
     *  permission which we do not expect running user to have.
     *
     * @param recordToUpdate `IAM_SSOi_Vista_Instance_to_User_DUZ__c` instance to update in SYSTEM_MODE
     */
    public void performUnsafeUpdate(IAM_SSOi_Vista_Instance_to_User_DUZ__c recordToUpdate) {
        this.doUpdateUnsafe(recordToUpdate);
    }
}
