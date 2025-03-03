/**
 * @description Repository class for the PC_Case__c object to hold its respective query and DML logic.
 * @author      Booz Allen Hamilton
 */
public inherited sharing class PC_PrcCaseRepo extends VTC_BaseRepo {
    private static final Map<String, Schema.SObjectField> PC_CASE_FIELD_MAP = PC_Case__c.SobjectType.getDescribe(
            Schema.SObjectDescribeOptions.DEFERRED
        )
        .fields.getMap();

    /**
     * @description Constructor function for PC_PrcCaseRepo. Calls super constructor which sets this.sObjectType to 'PC_Case__c'
     */
    public PC_PrcCaseRepo() {
        super(PC_Case__c.sObjectType);
    }

    /**
     * @description  retrieves a list of open PC Cases owned by the provided user in SF
     * @param userId SF User Id of the owner for the PC Cases to retrieve
     * @return       `List<PC_Case__c>` list of Open PC Cases owned by the provided user
     */
    public List<PC_Case__c> getOpenPrcCasesOwnedByUser(Id userId) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'recordTypeId' => this.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
            'userId' => userId
        };
        String selectClause = 'SELECT Id, Specialist_Notes__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE RecordTypeId = :recordTypeId AND OwnerId = :userId AND Closed__c = FALSE ';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_Case__c>) this.fetch(query, bindParams);
    }

    /**
     * @description  retrieves the oldest open PC Case owned by the provided user in SF
     * @param userId User Id of the owner for the PC Cases
     * @return       `List<PC_Case__c>` list of Open PC Cases owned by the provided user
     */
    public List<PC_Case__c> getOldestOpenPrcCaseOwnedByUser(Id userId) {
        Map<String, Object> bindParams = new Map<String, Object>{
            'recordTypeId' => this.recordTypeConstant.fromDeveloperName('Provider_Connect_Case').Id,
            'userId' => userId
        };

        String selectClause = 'SELECT Id, Name, Specialty__c, PCP__c, Case_Details__c, CreatedDate, Specialist_Notes__c';
        if (this.isFieldReadableByRunningUser('Patient_Account__c')) {
            selectClause += ', Patient_Account__c, Patient_Account__r.Name';
        }
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE RecordTypeId = :recordTypeId AND OwnerId = :userId AND Status__c = \'Open\'';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' Order By CreatedDate ASC LIMIT 1';
        return (List<PC_Case__c>) this.fetch(query, bindParams);
    }

    /**
     * @description gets a list of PrC Cases where related Case Feedback Answers are needed
     * @param userId User Id of logged in person
     * @return 'List<PC_Case__c>' list of PrC Case to be evaluated
     */
    public List<PC_Case__c> getRecentlyClosedCasesForUser(Id userId) {
        String selectClause = 'SELECT Id,Name,CreatedDate,Specialty__c,Channel__c,OwnerId,CreatedById';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE CreatedDate = LAST_N_DAYS:60 AND (OwnerId = :userId OR CreatedById = :userId) AND Closed__c = TRUE AND Status__c != \'Cancelled\' AND Training_Case__c = FALSE';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<PC_Case__c>) this.fetch(query, new Map<String, Object>{ 'userId' => userId });
    }

    /**
     * @description     checks if the running user has read access to the provided field on the PrC Case object
     * @param fieldName API name of the field to check
     * @return          `Boolean` true if the running user has read access to the field
     */
    private Boolean isFieldReadableByRunningUser(String fieldName) {
        return PC_CASE_FIELD_MAP.containsKey(fieldName) &&
            PC_CASE_FIELD_MAP.get(fieldName).getDescribe().isAccessible();
    }
}
