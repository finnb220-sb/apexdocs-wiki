/**
 * @author Booz Allen Hamilton
 * @since May 2024
 * @description Repository for ServiceResource object.
 *
 * @see VTC_BaseRepo
 * @see VCR_ServiceResourceRepoTest
 */
public virtual inherited sharing class VCR_ServiceResourceRepo extends VTC_BaseRepo {
    /**
     * @description Map of RecordTypes by Name for re-use
     */
    private final Map<String, RecordTypeInfo> recordTypesByName = ServiceResource.SObjectType
        .getDescribe(SObjectDescribeOptions.DEFERRED)
        .getRecordTypeInfosByDeveloperName();

    /**
     * @description PC Resource RecordType Id as it is used in multiple places
     */
    private final Id pcResourceRecordTypeId = Schema.SObjectType.ServiceResource.getRecordTypeInfosByDeveloperName()
        .get('PC_Resource')
        .getRecordTypeId();

    /**
     * @description Default constructor - setup repo for ServiceResource
     */
    public VCR_ServiceResourceRepo() {
        super(ServiceResource.SObjectType);
    }

    /**
     * @description  grabs the ServiceResource related to the provided users for VAHC Medical Provider
     *     record type
     * @param userIds list of user Ids to match on the Service Resource's RelatedRecordId field
     * @return       `List<ServiceResource>` ServiceResource for given User Ids
     */
    public List<ServiceResource> fetchServiceResourcesForMPsByUserId(List<Id> userIds) {
        Id mdProviderRecTypeId = recordTypesByName.get('VCC_Medical_Provider').getRecordTypeId();

        Map<String, Object> bindParams = new Map<String, Object>{
            'userIds' => new Set<Id>(userIds),
            'mdProviderRecTypeId' => mdProviderRecTypeId
        };
        String selectClause = this.getQueryString();
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE IsActive = true AND RelatedRecordId IN :userIds AND RecordTypeId = :mdProviderRecTypeId';
        String orderByClause = 'ORDER BY RelatedRecordId';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return (List<ServiceResource>) this.fetch(query, bindParams);
    }

    /**
     * @description  grabs the ServiceResource related to the provided user if it has a PC_Location
     * @param userId user Id to match on the Service Resource's RelatedRecordId field
     * @return       `List<ServiceResource>` ServiceResource with a PC_Location related to the user
     */
    public List<ServiceResource> getServiceResourceWithLocation(Id userId) {
        Id pcResourceRecordTypeId = recordTypesByName.get('PC_Resource').getRecordTypeId();

        Map<String, Object> bindParams = new Map<String, Object>{
            'pcResourceRecordTypeId' => pcResourceRecordTypeId,
            'userId' => userId
        };

        String selectClause = 'SELECT Id, RelatedRecordId, PC_Location__c';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ResourceType = \'A\' AND IsActive = true AND RecordTypeId = :pcResourceRecordTypeId AND RelatedRecordId = :userId AND PC_Location__c != NULL';
        String orderByClause = 'ORDER BY CreatedDate DESC';
        String limitClause = 'LIMIT 1';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause + ' ' + limitClause;
        return (List<ServiceResource>) this.fetch(query, bindParams);
    }

    /**
     * @description  grabs the ServiceResource related to the provided user if it has a PC_Location
     * @param skillSet Lis of skill name
     * @param locationIds List of host location id
     * @return       `List<ServiceResource>` ServiceResource with required skill and location
     */
    public List<ServiceResource> getServiceResourceWithLocation(Set<String> skillSet, Set<Id> locationIds) {
        Id pcResourceRecordTypeId = recordTypesByName.get('PC_Resource').getRecordTypeId();

        Map<String, Object> bindParams = new Map<String, Object>{
            'pcResourceRecordTypeId' => this.pcResourceRecordTypeId,
            'skillSet' => skillSet,
            'locationIds' => locationIds
        };

        String selectClause = 'Select Id,Name,PC_Assigned_Specialty__c,PC_Location__c,LocationId,RelatedRecordId';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE ResourceType = \'A\' AND IsActive = true AND RecordTypeId = :pcResourceRecordTypeId AND PC_Assigned_Specialty__c = :skillSet AND PC_Location__c = :locationIds';
        String orderByClause = 'ORDER BY CreatedDate DESC';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause + ' ' + orderByClause;
        return (List<ServiceResource>) this.fetch(query, bindParams);
    }

    /**
     * @description method calculates the SELECT clause for the SOQL query.
     * @return {String} The standard FROM clause for the SOQL query.
     */
    @TestVisible
    private String getQueryString() {
        return 'SELECT CreatedById,' +
            '        CreatedDate,' +
            '        Id,' +
            '        LastModifiedById,' +
            '        LastModifiedDate,' +
            '        Name,' +
            '        OwnerId,' +
            '        SystemModstamp,' +
            '        AccountId,' +
            '        RelatedRecordId';
    }
}
