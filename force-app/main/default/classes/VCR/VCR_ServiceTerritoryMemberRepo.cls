/**
 * @author Booz Allen Hamilton
 * @since 5/23/24
 * @description Repository class to handle all CRUD for VCR_ServiceTerritoryMember standard object
 *
 * @see VTC_BaseRepo
 * @see VCC_AppointmentUtilQueueable
 * @see VCR_ServiceTerritoryMemberRepoTest
 */
public inherited sharing class VCR_ServiceTerritoryMemberRepo extends VTC_BaseRepo {
    /**
     * @description Default ctr to create an instance of a Repository class to handle CRUD operations for
     *  the ServiceTerritoryMember object.
     *  Sets default fields that we wish to retrieve on each fetch/query
     */
    public VCR_ServiceTerritoryMemberRepo() {
        super(ServiceTerritoryMember.SObjectType);
        this.defaultSelectFields.addAll(
            new Set<String>{
                'ServiceTerritoryId',
                'ServiceTerritory.Name',
                'ServiceTerritory.IsActive',
                'ServiceTerritory.OperatingHoursId',
                'ServiceResourceId',
                'ServiceResource.Name',
                'ServiceResource.IsActive',
                'ServiceResource.RelatedRecordId',
                'EffectiveStartDate',
                'EffectiveEndDate',
                'OperatingHoursId'
            }
        );
    }

    /**
     * @description Retrieve ServiceTerritoryMember records for the given set of VISN Names (ServiceTerritory records)
     *
     * @param visnNames  `List<String>` List of VISN names for which we retrieve & return ServiceTerritoryMember matches
     *
     * @return `Database.QueryLocator` Locator for iterating over the result set in chunks to safely handle limits
     */
    public Database.QueryLocator fetchMembersByVisnNames(List<String> visnNames) {
        if (visnNames == null || visnNames.isEmpty()) {
            // Invalid  input - throw an exception
            throw new IllegalArgumentException(
                'Required list of VISN Names to search by must be provided. To specify all VISNs, use fetchMembersForAllVISNs().'
            );
        }
        String whereClause = ' AND ServiceTerritory.Name IN:queryArg';
        return fetchMembersForSomeOrAllVisns(visnNames, whereClause);
    }

    /**
     * @description Retrieve ServiceTerritoryMember records for the given set of VISN Ids (ServiceTerritory records)
     *
     * @param visnIds  `List<Id>` List of unique VISN Ids for which we retrieve & return ServiceTerritoryMember matches
     *
     * @return `Database.QueryLocator` Locator for iterating over the result set in chunks to safely handle limits
     */
    public Database.QueryLocator fetchMembersByVisnIds(List<Id> visnIds) {
        if (visnIds == null || visnIds.isEmpty()) {
            // Invalid  input - throw an exception
            throw new IllegalArgumentException(
                'Required list of VISN Ids to search by must be provided. To specify all VISNs, use fetchMembersForAllVISNs().'
            );
        }
        String whereClause = ' AND ServiceTerritoryId IN:queryArg';
        return fetchMembersForSomeOrAllVisns(visnIds, whereClause);
    }

    /**
     * @description Fetch ServiceTerritoryMember records for all active VISNs in the system
     *
     * @return `Database.QueryLocator` Locator for iterating over the result set in chunks to safely handle limits
     */
    public Database.QueryLocator fetchMembersForAllVisns() {
        return fetchMembersForSomeOrAllVisns(null, '');
    }

    /**
     * @description Build and return the Query for finding all ServiceTerritoryMember records for all active VISNs in the system.
     * For use with iterating over a results set using VCR_SerializableQueryLocatorChunk (manual chunking of records for a
     * Queueable instance as QueryLocator is not serializable and cannot be used to pass from one queueable instance to another)
     *
     * @return `String` A SOQL query string that can be executed
     */
    public String getQueryForAllVISNs() {
        return this.calculateSelectClause(this.defaultSelectFields) +
            ' ' +
            this.calculateFromClause() +
            ' WHERE ServiceTerritory.IsActive = TRUE AND ServiceResource.IsActive = TRUE';
    }

    /**
     * @description Build and return the Query for finding all ServiceTerritoryMember records for all active VISNs for the current
     * user's Timezone in the system.
     * For use with iterating over a results set using VCR_SerializableQueryLocatorChunk (manual chunking of records for a
     * Queueable instance as QueryLocator is not serializable and cannot be used to pass from one queueable instance to another)
     *
     * @return `String` A SOQL query string that can be executed
     */
    public String getQueryForAllVISNsInUserTimezone() {
        return this.calculateSelectClause(this.defaultSelectFields) +
            ' ' +
            this.calculateFromClause() +
            ' WHERE ServiceTerritory.IsActive = TRUE AND ServiceResource.IsActive = TRUE ' +
            ' AND ServiceTerritory.OperatingHours.TimeZone = :queryArg';
    }

    /**
     * @description Build and return the Query for finding all ServiceTerritoryMember records for a given list of VISN Names in the system.
     * For use with iterating over a results set using VCR_SerializableQueryLocatorChunk (manual chunking of records for a
     * Queueable instance as QueryLocator is not serializable and cannot be used to pass from one queueable instance to another)
     * ASSUMPTION: Query bind argument is 'queryArg'
     *
     * @return `String` A SOQL query string that can be executed
     */
    public String getQueryForNamedVISNs() {
        return this.calculateSelectClause(this.defaultSelectFields) +
            ' ' +
            this.calculateFromClause() +
            ' WHERE ServiceTerritory.IsActive = TRUE AND ServiceResource.IsActive = TRUE AND ServiceTerritory.Name IN:queryArg';
    }

    /**
     * @description Build and return the Query for finding all ServiceTerritoryMember records for a given list of VISN Ids in the system.
     * For use with iterating over a results set using VCR_SerializableQueryLocatorChunk (manual chunking of records for a
     * Queueable instance as QueryLocator is not serializable and cannot be used to pass from one queueable instance to another)
     * ASSUMPTION: Query bind argument is 'queryArg'
     *
     * @return `String` A SOQL query string that can be executed
     */
    public String getQueryForVISNIds() {
        return this.calculateSelectClause(this.defaultSelectFields) +
            ' ' +
            this.calculateFromClause() +
            ' WHERE ServiceTerritory.IsActive = TRUE AND ServiceResource.IsActive = TRUE AND ServiceTerritoryId IN:queryArg';
    }

    /**
     * @description Retrieve ServiceTerritoryMember records using the standard where clause (ServiceTerritory and
     * ServiceMember are active) plus the additional criteria in addlWhereClause. queryArg provides bind variables.
     *
     *  @param queryArg `Object` Provides bind variables, if any, to use for populating query with dynamic values
     * @param addlWhereClause  `String` Additional criteria to query by
     *
     * @return `Database.QueryLocator` Locator for iterating over the result set in chunks to safely handle limits
     */
    private Database.QueryLocator fetchMembersForSomeOrAllVisns(Object queryArg, String addlWhereClause) {
        String queryString = this.calculateSelectClause(this.defaultSelectFields);
        queryString += ' ' + this.calculateFromClause();
        queryString += ' WHERE ServiceTerritory.IsActive = TRUE AND ServiceResource.IsActive = TRUE';
        queryString += addlWhereClause;
        queryString += ' ORDER BY ServiceTerritory.Name';
        Database.QueryLocator queryLocator = Database.getQueryLocatorWithBinds(
            queryString,
            new Map<String, Object>{ 'queryArg' => queryArg },
            System.AccessLevel.USER_MODE
        );
        return queryLocator;
    }
}
