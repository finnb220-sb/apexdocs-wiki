/**
 * @description Repository class for StaticResource
 * @author Booz Allen Hamilton
 * @since 04/25/2024
 * @see VCR_StaticResourceRepoTest
 */
public inherited sharing class VCR_StaticResourceRepo extends VTC_BaseRepo {
    /**
     * @description no-arg constructor, specifies SObjectType to parent VTC_Repo
     */
    public VCR_StaticResourceRepo() {
        super(StaticResource.sObjectType);
        this.defaultSelectFields.addAll(new List<String>{ 'Name', 'Body' });
    }

    /**
     * @description Fetch a static resource by exact name match
     * @param staticResourceName
     * @return `StaticResource`
     */
    public List<StaticResource> fetchByName(String staticResourceName) {
        return this.fetch(
            this.calculateSelectClause(this.defaultSelectFields) +
                ' ' +
                this.calculateFromClause() +
                ' WHERE Name = :name',
            new Map<String, Object>{ 'name' => staticResourceName }
        );
    }
}
