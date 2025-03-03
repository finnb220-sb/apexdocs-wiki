/**
 * @description The purpose of this class is to make two callouts to MPI via DIP to: <br>
 *   1.) Retrieve person information and <br> 2.) Create a correlation between a person in Salesforce and MPI.
 *   This batch class runs on the VA_Identity__c object. <br><br>
 *   After successful correlation, an account record is created with the data received from step 1. After successfull
 *   insert of the account the VA_Identity record is updated to 'complete' and populated with the same info from step 1.
 *   <br><br>
 *
 *   Instructions: 		This job should be scheduled to run nightly, after the Cerner data load completes.<br>
 *
 *   Constraints: 		As of June 2021, the MPI Correlate services accepts only one record per request (no lists).<br>
 *
 *   Testing:			To run this job on demand in a Sandbox, execute this code via Dev Console:
 *   Id batchJobId = Database.executeBatch(new VCC_BatchMPICorrelate(), 50);
 * @author Booz Allen Hamilton
 * @since June 13, 2021
 * @see VCC_BatchMPICorrelateTest
 * @see VCC_MpiRetrievebatch
 * @see VCC_BatchMPICorrelateHelper
 * @see VCC_BatchMPICorrelateScheduler
 * @group API - MPI
 */
public with sharing class VCC_BatchMPICorrelate implements Database.Batchable<SObject>, Database.AllowsCallouts {
    private final VCC_BatchMpiCorrelateHelper helper = new VCC_BatchMpiCorrelateHelper();
    private final List<VA_Identity__c> vaIdentitiesToUpdate = new List<VA_Identity__c>();
    private List<Account> accountListToInsert = new List<Account>();
    private final Map<String, VA_Identity__c> accountICNToIdentityRec = new Map<String, VA_Identity__c>();
    private final Map<String, VA_Identity__c> accountToIdentity = new Map<String, VA_Identity__c>();

    //    private List<VA_Identity__c> vaIdentitiesToUpdateWithError = new List<VA_Identity__c>();
    private final List<VA_Identity__c> vaIdentitiesReadyToUpdate = new List<VA_Identity__c>();

    private final Map<String, Account> accountIdsToAccountMap = new Map<String, Account>();
    private final Map<Id, Id> accountIdToContactId = new Map<Id, Id>();

    String query = '';

    /**
     * @description Default constructor
     */
    public VCC_BatchMPICorrelate() {
        query =
            'select Id, Last_Name__c, Cerner_specific_ICN__c, ICN__c ' +
            'from VA_Identity__c ' +
            'where MPI_Correlation_Status__c = \'New\' or MPI_Correlation_Status__c = \'Error\'';
    }

    /**
     * @description Batch start that initializes the repository for VA identity records and returns the result that the batch is interrested in.
     * @param batchContext Represents the parameter type of a batch job method and contains the batch job ID.
     * @return the record set returned by Database.getQueryLocator
     * @justification This batch requires system mode and therefore uses the unsafe version of the repository.
     */
    public Database.QueryLocator start(Database.BatchableContext batchContext) {
        VCR_VaIdentityRepo vaIdRepo = new VCR_VaIdentityRepo(true);
        return vaIdRepo.getQueryLocatorUnsafe(query);
    }

    /**
     * @description Batch execute that performs the callout to the MPI service
     * @param myBatchContext batchable context variable
     * @param scopeVAIdentity list of VA_Identity__c records
     */
    public void execute(Database.BatchableContext myBatchContext, List<VA_Identity__c> scopeVAIdentity) {
        List<String> cernerIdList = new List<String>();
        try {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);
            HttpResponse resp;

            for (VA_Identity__c identityVar : scopeVAIdentity) {
                //Part 1 - Call vetRetrieve (MPI Retrieve) API

                // additional datasets are BGS and EE(Eligibility Enrollment), eg.: 'datasets' => new List<String>{"BGS", "VA_PROFILE", "EE"}
                request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIeVetRetrieve'));
                cernerIdList.add(identityVar?.Cerner_specific_ICN__c);
                request.setBody(
                    JSON.serialize(
                        new Map<Object, Object>{
                            'userId' => 'VA-Vet VAHC CRM Batch Job',
                            'id' => identityVar.Cerner_specific_ICN__c,
                            'idType' => 'ICN',
                            'unattended' => true,
                            'showCorrelated' => false,
                            'datasets' => new List<String>{ 'VA_PROFILE', 'EE' }
                        } //new Map<Object, Object>
                    )
                );

                resp = (new Http()).send(request);
                String responseBody = resp.getBody();

                VCC_BatchMpiCorrelateHelper.HelperWrapper helperWrapper = new VCC_BatchMpiCorrelateHelper.HelperWrapper();
                helperWrapper.responseBody = responseBody;
                helperWrapper.identityVar = identityVar;
                helperWrapper.serviceRequest = request;
                helperWrapper.serviceResponse = resp;
                helperWrapper.accountListToInsert = accountListToInsert;

                VCC_BatchMpiCorrelateHelper.ReturnWrapper returnWrapper;
                returnWrapper = processCalloutResponse(helperWrapper);
                identityVar = returnWrapper.identityVar;
                accountListToInsert = returnWrapper.accountListToInsert;

                vaIdentitiesToUpdate.add(identityVar);
                accountToIdentity.put(identityVar.ICN__c, identityVar);
            }

            populateAccountToIdentityMap();

            //Inserting Accounts with AccountRepo
            List<Database.SaveResult> insertResults = new VCR_AccountRepo()
                .insertAccountsAllOrNoneFalse(accountListToInsert);

            processAccountInsertionResults(insertResults);

            List<Contact> contacts = new VCR_ContactRepo().getContactFromAccountSet(accountIdsToAccountMap.keySet());

            populateAccountIdToContactIdMap(contacts);

            populateContactFieldOnVaIdentityRecord();

            Set<VA_Identity__c> vaIdentitiesSetToUpdate = new Set<VA_Identity__c>(vaIdentitiesToUpdate);
            List<VA_Identity__c> vaIdentityUpdateList = new List<VA_Identity__c>(vaIdentitiesSetToUpdate);

            VCR_VaIdentityRepo vaIdentityRepo = new VCR_VaIdentityRepo();
            vaIdentityRepo.updateVAIdentitiesAllOrNoneFalse(vaIdentityUpdateList);

            //If correlation status is still new and an account has been created. Delete the account
            //if vaidentity icn is in account icn list then delete account id
            Set<String> listOfVaIdentityICNsToDelete = new Set<String>();

            for (VA_Identity__c iden : vaIdentityUpdateList) {
                if (iden.MPI_Correlation_Status__c == 'New') {
                    listOfVaIdentityICNsToDelete.add(iden.Cerner_specific_ICN__c);
                }
            }

            List<Account> accountsToDelete = new VCR_AccountRepo()
                .fetchPersonAccountsViaICN(listOfVaIdentityICNsToDelete);

            try {
                new VCR_AccountRepo().deleteAccountsAllOrNoneFalse(accountsToDelete);
            } catch (Exception deleteDmlExcept) {
                Logger.error('VCC_BatchMPICorrelate.execute Account Delete Catch Exception', deleteDmlExcept);
            }
        } catch (CalloutException mpiCalloutException) {
            Logger.error(
                'An HTTP exception occurred in VCC_BatchMPICorrelate on line #' + mpiCalloutException.getLineNumber(),
                mpiCalloutException
            );
        } catch (Exception batchExecuteException) {
            String idList = String.join(cernerIdList, ',');
            Logger.error(
                'An unexpected error occured in VCC_BatchMPICorrelate on line #' +
                    batchExecuteException.getLineNumber() +
                    ', for Cerner IDs: ' +
                    idList,
                batchExecuteException
            );
        }
        Logger.saveLog();
    } //end of execute

    /**
     * @description Batch finish (part of interface, must be included)
     * @param batchContext batchable context variable - dependency injected by platform
     */
    public void finish(Database.BatchableContext batchContext) {
        Logger.saveLog();
    }

    /**
     * @description Process callout response and recird errors properly
     * @param helperWrapper contains callout response, account list, and identity var
     * @return ReturnWrapper with the Account list and VA_Identity record
     */
    public VCC_BatchMpiCorrelateHelper.ReturnWrapper processCalloutResponse(
        VCC_BatchMpiCorrelateHelper.HelperWrapper helperWrapper
    ) {
        String responseBody = helperWrapper.responseBody;
        VA_Identity__c identityVar = helperWrapper.identityVar;
        HttpResponse resp = helperWrapper.serviceResponse;

        if (resp.getStatusCode() != 200) {
            if (!String.isBlank(responseBody)) {
                Map<String, Object> mapOfResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
                if (mapOfResponse.containsKey('errorType') && mapOfResponse.containsKey('message')) {
                    identityVar.MPI_Retrieve_Error_Message__c =
                        (String) mapOfResponse.get('errorType') +
                        ': ' +
                        (String) mapOfResponse.get('message');
                }
            }
            identityVar.MPI_Correlation_Status__c = 'Error';
            identityVar.MPI_Retrieve_Error_Message_Datetime__c = System.now();
            VCC_BatchMpiCorrelateHelper.ReturnWrapper returnWrapper = new VCC_BatchMpiCorrelateHelper.ReturnWrapper();
            returnWrapper.identityVar = identityVar;
            return returnWrapper;
        } else {
            VCC_BatchMpiCorrelateHelper.ReturnWrapper returnWrapper;
            returnWrapper = helper.handleSuccessResponse(helperWrapper);
            return returnWrapper;
        }
    }

    /**
     * @description loops over accounts to populate the accountToIdentity map
     */
    private void populateAccountToIdentityMap() {
        for (Account acc : accountListToInsert) {
            if (accountICNToIdentityRec?.get(acc.VCC_MVI_External_Id__pc) != null) {
                VA_Identity__c vaId = accountICNToIdentityRec.get(acc.VCC_MVI_External_Id__pc);
                accountToIdentity.put(acc.VCC_MVI_External_Id__pc, vaId);
            }
        }
    }

    /**
     * @description loops over insertion results, checks for success/failure
     *              if failure, then set error message fields.
     *              if success, populate map of account id to account and list of successful va_ids
     * @param insertResults list of save results from account insertion
     */
    private void processAccountInsertionResults(List<Database.SaveResult> insertResults) {
        for (Integer resultIndex = 0; resultIndex < insertResults.size(); resultIndex++) {
            VA_Identity__c vaId = accountToIdentity.get(accountListToInsert[resultIndex].VCC_MVI_External_Id__pc);
            if (!insertResults[resultIndex].isSuccess()) {
                vaId.MPI_Retrieve_Error_Message__c =
                    'Error creating Account from MPI Data: ' +
                    String.join(insertResults[resultIndex].getErrors(), '\n');
                vaId.MPI_Retrieve_Error_Message_Datetime__c = System.now();
            } else {
                accountIdsToAccountMap.put(accountListToInsert[resultIndex].Id, accountListToInsert[resultIndex]);
            }
            vaIdentitiesReadyToUpdate.add(vaId);
        }
    }

    /**
     * @description populates the map accountIdToContactId
     * @param contacts Resulting contacts for the accounts
     */
    private void populateAccountIdToContactIdMap(List<Contact> contacts) {
        for (Contact con : contacts) {
            accountIdToContactId.put(con.AccountId, con.Id);
        }
    }

    /**
     * @description populates the field Salesforce_Contact_Id__c on VA_Identity.
     * This requires a lookup so it's not a straightforward assignment.
     */
    private void populateContactFieldOnVaIdentityRecord() {
        /// becasue of the quick Q/A turn arround on this, I'm leaving this code here, but commented out for now.
        /// Please remove this commented code if no issues are found in this functionality by the end of the 1.19
        /// release cycle.

        //        for (VA_Identity__c vaId : vaIdentitiesReadyToUpdate) {
        //            for (Account acct : accountIdstoAccountMap.values()) {
        //                if (vaId.ICN__c == acct.VCC_MVI_External_Id__pc) {
        //                    vaId.Salesforce_Contact_Id__c = accountIdToContactId.get(acct.Id);
        //                }
        //            }
        //        }

        /// Using two for loops is fundamentally faster than the original nested for loops (see above).
        /// Given this is a batch job, we should be mindful of performance.
        // Create a map of ICN to Account Id
        Map<String, Id> icnToAccountIdMap = new Map<String, Id>();
        for (Account acct : accountIdsToAccountMap.values()) {
            if (acct.VCC_MVI_External_Id__pc != null) {
                icnToAccountIdMap.put(acct.VCC_MVI_External_Id__pc, acct.Id);
            }
        }

        // Populate the Salesforce_Contact_Id__c field
        for (VA_Identity__c vaId : vaIdentitiesReadyToUpdate) {
            Id accountId = icnToAccountIdMap.get(vaId.ICN__c);
            if (accountId != null) {
                vaId.Salesforce_Contact_Id__c = accountIdToContactId.get(accountId);
            }
        }
    }
}
