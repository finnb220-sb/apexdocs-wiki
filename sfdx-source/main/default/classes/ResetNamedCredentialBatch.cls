/**
 * Author:Jaren Yach
 *  Created Date 05/06/2022
 *  Purpose: This class is used to clear out named credential values
 *  in a sandbox to prevent production credential values from being used
 *
 *  Without sharing is used because this needs to run in a system context.
 */
public without sharing class ResetNamedCredentialBatch implements Database.Batchable<SObject>, Database.AllowsCallouts {
    public Database.QueryLocator start(Database.BatchableContext context) {
        return Database.getQueryLocator([SELECT Id, MasterLabel, Endpoint FROM NamedCredential WHERE NamespacePrefix = NULL]);
    }

    public void execute(Database.BatchableContext context, List<NamedCredential> nameCredentials) {
        //Only run this class in Sandbox when not in test context.  We don't want to be changing
        //named credentials in production.  NamedCredentialService is tested on it's own
        if (!Test.isRunningTest()) {
            for (NamedCredential rec : nameCredentials) {
                resetNamedCredentialForSandbox(rec);
            }
        }
    }

    public void finish(Database.BatchableContext context) {
        DTCUtils.sendCompletedBatchJobEmail(context.getJobId());
    }

    /**
     * Resets the NamedCredential
     * @param rec
     */
    @TestVisible
    private void resetNamedCredentialForSandbox(NamedCredential rec) {
        //Only update NamedCredential if this is a sandbox
        if (DTCUtils.getOrgInfo().IsSandbox) {
            Map<String, Object> namedCredentialRequest = new Map<String, Object>();
            namedCredentialRequest.put('authProvider', null);
            namedCredentialRequest.put('awsAccessKey', null);
            namedCredentialRequest.put('awsAccessSecret', null);
            namedCredentialRequest.put('awsRegion', null);
            namedCredentialRequest.put('awsService', null);
            namedCredentialRequest.put('certificate', null);
            namedCredentialRequest.put('endpoint', rec.Endpoint + '.test');
            namedCredentialRequest.put('jwtAudience', null);
            namedCredentialRequest.put('jwtFormulaSubject', null);
            namedCredentialRequest.put('jwtIssuer', null);
            namedCredentialRequest.put('jwtSigningCertificate', null);
            namedCredentialRequest.put('jwtValidityPeriodSeconds', null);
            namedCredentialRequest.put('label', rec.MasterLabel);
            namedCredentialRequest.put('oauthRefreshToken', null);
            namedCredentialRequest.put('oauthScope', null);
            namedCredentialRequest.put('oauthToken', null);
            namedCredentialRequest.put('outboundNetworkConnection', null);
            namedCredentialRequest.put('password', null);
            namedCredentialRequest.put('principalType', 'Anonymous');
            namedCredentialRequest.put('protocol', 'NoAuthentication');
            namedCredentialRequest.put('urls', null);
            namedCredentialRequest.put('username', null);

            Map<String, Object> metadataObject = new Map<String, Object>();
            metadataObject.put('Metadata', namedCredentialRequest);

            SalesforceToolingApi toolingApi = new SalesforceToolingApi();
            toolingApi.setURL('/sobjects/NamedCredential/' + rec.Id).setRequestBody(metadataObject).doPatch();
        }
    }

    /**
     * Easy way to run this batch job
     *
     * @return Job Id
     */
    public static String run() {
        return Database.executeBatch(new ResetNamedCredentialBatch(), 1);
    }
}
