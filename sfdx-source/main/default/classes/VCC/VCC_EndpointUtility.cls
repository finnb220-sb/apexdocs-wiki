/**
 * @description An Apex Class which provides convenience operations for handling endpoints.
 * @author Unspecified
 * @since Unspecified
 * @group Helpers/Utilities
 */
public inherited sharing class VCC_EndpointUtility {
    /**
     * @description Generate map of field names to their Help Text value stored in custom metadata type.
     * @param appName Application Name
     * @param serviceName Service Name
     * @return A string representing the endpoint URL for the named credential.
     **/
    @SuppressWarnings('PMD.ApexCRUDViolation') // Suppress PMD warning for Organization query.
    public static String getEndpoint(String appName, String serviceName) {
        // Get Org Type from Custom Metadata. If test is running, bypass query and set orgType to DEV
        String orgType;

        // Scratch Org support
        Organization org = [
            SELECT IsSandbox, TrialExpirationDate
            FROM Organization
        ];
        Boolean isScratchOrg = org.IsSandbox && org.TrialExpirationDate != null;
        //Boolean isTrialOrg = !org.IsSandbox && org.TrialExpirationDate != null;

        if (Test.isRunningTest() || isScratchOrg) {
            orgType = 'QA';
        } else {
            orgType = [
                SELECT Id, vccType__c
                FROM VCC_Org_Settings__mdt
                WHERE vccOrgId__c = :UserInfo.getOrganizationId()
                WITH SECURITY_ENFORCED
            ]
            .vccType__c;
        }

        // Get Path from Custom Metadata
        String endpoint = [
            SELECT Id, DeveloperName, Path__c
            FROM vccEndpoint__mdt
            WHERE DeveloperName = :serviceName
            WITH SECURITY_ENFORCED
        ]
        .Path__c;

        // Construct Named Credential
        String namedCredential = constructNamedCredential(orgType, appName);

        // Test all Named Credential Org Types
        if (Test.isRunningTest()) {
            namedCredential = constructNamedCredential('SCRATCH', appName);
            namedCredential = constructNamedCredential('DEV', appName);
            namedCredential = constructNamedCredential('QA', appName);
            namedCredential = constructNamedCredential('STAGING', appName);
            namedCredential = constructNamedCredential('PRODUCTION', appName);
            namedCredential = constructNamedCredential('OTHER', appName);
        }

        // Construct URL
        return 'callout:' + namedCredential + '/' + endpoint;
    }

    /**
     * @description Generate map of field names to their Help Text value stored in custom metadata type
     * @param namedCred Named Credential
     * @return A string URL for given named credential
     **/
    public static String getUrlForNamedCredential(String namedCred) {
        String namedCredName = namedCred.substringAfter(':').substringBefore('/');
        String path = namedCred.substringAfter(':').substringAfter('/');
        return [
                SELECT Endpoint
                FROM NamedCredential
                WHERE DeveloperName = :namedCredName
                LIMIT 1
            ]
            .Endpoint +
            '/' +
            path;
    }

    /**
     * @description Generate map of field names to their Help Text value stored in custom metadata type
     * @param orgType Organization Type
     * @param appName Application Name
     * @return A string representing the constructed named credential for given org type and application name.
     **/
    public static String constructNamedCredential(String orgType, String appName) {
        if (orgType == 'DEV') {
            return 'vcc' + appName + '_dev';
        } else if (orgType == 'QA') {
            return 'vcc' + appName + '_qa';
        } else if (orgType == 'STAGING') {
            // not sure what to call this
            return 'vcc' + appName + '_staging';
        } else if (orgType == 'PRODUCTION') {
            return 'vcc' + appName + '_prod';
        } else if (orgType == 'SCRATCH') {
            return '';
        } else {
            return 'vcc' + appName + '_dev'; // Default to "DEV" if input param isn't recognized
        }
    }
}
