/**
 * @description This repository is for External Data Source object.
 * @author      Booz Allen
 */
public virtual with sharing class VCR_ExternalDataSourceRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_ExternalDataSourceRepo. Pulls the external source based on the DeveloperName
     **/
    public VCR_ExternalDataSourceRepo() {
        super(ExternalDataSource.sObjectType);
        this.defaultSelectFields = new Set<String>{ 'DeveloperName', 'Endpoint', 'Repository' };
    }

    /**
     * @description Method for fetching External Data Sources from the ExternalDataSource
     * @param developerName the unique identifier for the External Data Source
     * @return ExternalDataSource returns a single External Data Source based on the Developer Name.
     */
    public ExternalDataSource fetchExternalDataSourceUsingSystemMode(String developerName) {
        //! ExternalDataSource does not function as a SObject and could not be added to the permission set for the user. It was determined that a query utilizing System Mode was the best resolution for this use case.
        String whereClause = ' WHERE DeveloperName = :developerName LIMIT 1 ';
        String queryStr = String.join(
            new List<String>{
                this.calculateSelectClause(this.defaultSelectFields),
                this.calculateFromClause(),
                whereClause
            },
            ' '
        );
        Map<String, Object> bindParams = new Map<String, Object>{ 'developerName' => developerName };
        return (ExternalDataSource) Database.queryWithBinds(queryStr, bindParams, AccessLevel.SYSTEM_MODE)[0];
    }
}
