/**
 * @description This repository is for the External VA Links custom metadata records
 * @author Booz Allen Hamilton
 * @since 05/2024
 */
public virtual inherited sharing class VCR_ExternalVaLinksRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_ExternalVaLinksRepo. Calls super constructor which sets this.sObjectType to
     * External_VA_Link__mdt and adds additional fields on query return
     */
    public VCR_ExternalVaLinksRepo() {
        super(External_VA_Link__mdt.sObjectType);
        this.defaultSelectFields.addAll(
            new Set<String>{ 'Audience__c', 'Sort_Order__c', 'URL__c', 'DeveloperName', 'MasterLabel' }
        );
    }

    /**
     * @description retrieves all of the External VA Links that match the audience criteria
     * @param audiences - list of audiences
     * @param limitCount - the limit at the end of the query
     * @return List<External_VA_Link__mdt> - list of External VA Link records matching the criteria
     */
    public List<External_VA_Link__mdt> getVALinksFromAudience(List<String> audiences, Integer limitCount) {
        String listElements = '\'' + String.join(audiences, '\',\'') + '\'';

        String selectClause = 'SELECT Audience__c, Sort_Order__c, URL__c, DeveloperName, MasterLabel ';
        String fromClause = 'FROM External_VA_Link__mdt ';
        String whereClause = 'WHERE Audience__c IN (' + listElements + ') ';
        String orderClause = 'ORDER BY Sort_Order__c ASC ';
        String limitClause = 'LIMIT ' + String.valueOf(limitCount);
        String query = selectClause + fromClause + whereClause + orderClause + limitClause;

        return this.fetch(query);
    }
}
