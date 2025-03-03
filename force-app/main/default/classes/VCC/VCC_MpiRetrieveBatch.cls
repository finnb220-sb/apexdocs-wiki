/**
 * @description: This class is step 1 of the VCC_BatchMPICorrelate process.
 *   The purpose of this class is to make one callout to MPI via DIP per idnentity record to retrieve person information.
 *   The information is retrieved using ICN__c (not Cernner_Specific_ICN__C) from VA_Identity__c records
 *   The retrieved information is stored in the VA_Identity__c records
 *   Create Salesforce Person Account with the retrieved information for each one of the VA_Identity__c record, and store
 *      the contact ID of the person account to the Salesforce_Contact__c field on the VA_Identity__c
 *
 *   For step 2, at the finish() of this batch, it calls the "MPICorrelate" batch on successfully retrieved and stored records.
 *   The  "MPICorrelate" batch class is named "MPIBatchIdentityService" with following characteristics:
 *       the class is part of the vavet-mpie package (Version 2.0 and above);
 *       one callout to MPI via DIP per identity record is made;
 *       the class will create a correlation between a person in Salesforce and MPI;
 *       the class runs on identity object based on custom metadata type reocords (the default object is VA_Identity__c);
 *       the class updates the "MPI Correlation Status" field on the identity record to "Success" or "Failed"
 *
 *   For step 3, delete the Person Account created in step 1, if correlation status is not success ('Waiting' or 'Failed')
 *
 *   Instructions: 		This batch job should be scheduled to run after the Cerner data load completes (it would be 8 am)
 *
 *   Constraints: 		As of October 2022, the MPI Correlate services accepts only one record per request (no lists).
 *                       As of October 2022, the maximum number of callouts from Salesforce is 100 per transaction.
 *
 *   Testing:			To run this job on demand in a Sandbox, execute this code via Dev Console: (max of 100)
 *                       Id batchJobId = Database.executeBatch(new VCC_MpiRetrieveBatch(), 100);
 * @description written above, as it is complex
 * @author Mung Fan, Acumen Solutions
 * @since October 18, 2022
 * @modified October 17, 2024
 * @group API - MPI
 */
public with sharing class VCC_MpiRetrieveBatch implements Database.Batchable<SObject>, Database.AllowsCallouts, Database.Stateful {
    @TestVisible
    private String originalTransactionId;
    @TestVisible
    private Set<Id> successIdSet = new Set<Id>();
    @TestVisible
    private Id personAcctRecordTypeId;
    @TestVisible
    private String waiting = System.Label.MPIE_CorrelationStatus_Waiting_Value;
    @TestVisible
    private String failed = System.Label.MPIE_CorrelationStatus_Failure_Value;
    /// These two lines are commented out because Intelli-j believes they're never used in the code.
    /// I want to verify that before actually deleting - @codefriar
    //    @TestVisible
    //    private String requesterDefaultValue = System.Label.vccMpiCorrelationRequesterDefault;
    @TestVisible
    private String requesterUserDefaultValue = 'VA-Vet VAHC CRM Batch Job';

    /**
     * @description Default constructor. Initialize personAcctRecordTypeId.
     */
    public VCC_MpiRetrieveBatch() {
        personAcctRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName()
            .get('PersonAccount')
            .getRecordTypeId();
    }

    /**
     * @description Implement start() method of Database.Batchable interface
     * @param  myBatchableContext Database.BatchableContext
     * @return    Database.QueryLocator
     */
    public Database.QueryLocator start(Database.BatchableContext myBatchableContext) {
        this.originalTransactionId = Logger.getTransactionId();
        String queryString = buildVaIdentityQuery();

        Logger.fine('start() with transaction ID ' + this.originalTransactionId);
        Logger.debug('Query : ' + queryString);
        Logger.debug('Person Account Record Type ID: ' + personAcctRecordTypeId);
        Logger.saveLog();

        VCR_VaIdentityRepo vaIdRepo = new VCR_VaIdentityRepo();
        Map<String, Object> bindParamMap = new Map<String, Object>{
            'waiting' => this.waiting,
            'failed' => this.failed
        };
        return vaIdRepo.getQueryLocatorWithBinds(String.escapeSingleQuotes(queryString), bindParamMap);
    }

    /**
     * @description Implement execute() method of Database.Batchable interface
     * @param  myBatchableContext              Database.BatchableContext
     * @param  scopeVAIdentity List<VA_Identity__c>
     */
    public void execute(Database.BatchableContext myBatchableContext, List<VA_Identity__c> scopeVAIdentity) {
        Logger.setParentLogTransactionId(this.originalTransactionId);
        Logger.fine('execute() with transaction ID ' + this.originalTransactionId);

        try {
            Map<String, VA_Identity__c> vaIdentityMapByIcn = new Map<String, VA_Identity__c>();
            List<Account> personAccountToInsert = new List<Account>();

            // retrieve info, and store info in the varilables "vaIdentityMapByIcn" and "personAccountToInsert"
            HttpRequest request = createHttpRequestWithoutBody();
            for (VA_Identity__c identityVar : scopeVAIdentity) {
                HttpResponse resp = sendRequestForIdentity(request, identityVar);
                ResponseWrapper myResponseWrapper = new ResponseWrapper();
                myResponseWrapper.resp = resp;
                myResponseWrapper.identityVar = identityVar;
                myResponseWrapper.vaIdentityMapByIcn = vaIdentityMapByIcn;
                myResponseWrapper.personAccountToInsert = personAccountToInsert;
                parseResponse(myResponseWrapper);
            }

            // insert person-account, update a lookup field on the VA Identity with the contact ID of the person-account
            if (personAccountToInsert.isEmpty() == false) {
                List<Database.SaveResult> srList = new VCR_AccountRepo()
                    .insertAccountsAllOrNoneFalse(personAccountToInsert);
                MPIIdentityUtility.logErrorIfAny(srList); // MPIIdentityUtility is from vavet-mpie pacakge
                updateVaIdentities(srList, personAccountToInsert, vaIdentityMapByIcn);
            }

            // update the VA Identity records.
            if (vaIdentityMapByIcn.isEmpty() == false) {
                List<Database.SaveResult> srList = new VCR_VaIdentityRepo()
                    .updateVAIdentitiesAllOrNoneFalse(vaIdentityMapByIcn.values());
                MPIIdentityUtility.logErrorIfAny(srList); // MPIIdentityUtility is from vavet-mpie pacakge
                updateSuccessIdSet(srList);
            }
        } catch (Exception ex) {
            Logger.error('Caught system exception', ex);
        }
        Logger.saveLog();
    }

    /**
     * @description Implement finish() method of Database.Batchable interface
     * @param  myBatchableContext Database.BatchableContext
     */
    public void finish(Database.BatchableContext myBatchableContext) {
        Logger.setParentLogTransactionId(this.originalTransactionId);
        Logger.fine('Finished with tranasaction ID ' + this.originalTransactionId);
        if (successIdSet.isEmpty() == false) {
            Logger.debug('Passing Success ID Set for MPI Correlation.');
            try {
                Database.executeBatch(
                    new MPIIdentityCorrelationBatch(successIdSet),
                    Integer.valueOf(System.Label.vccMpiBatchSize)
                );
            } catch (Exception ex) {
                Logger.error('Caught exception while chaining the batch for MPI Correlation', ex);
            }
        }
        Logger.saveLog();
    }

    /**
     * @description Builds a SOQL query for the VA identity retrieval to use
     * @return String of the resulting query.
     */
    @TestVisible
    private static String buildVaIdentityQuery() {
        String queryString = '';
        queryString += 'SELECT ID, Last_Name__c, Cerner_specific_ICN__c, ICN__c ';
        queryString += ', MPI_Correlation_Requester__c, MPI_Correlation_Requester_User__c ';
        queryString += ' FROM VA_Identity__c ';
        queryString += ' WHERE MPI_Correlation_Status__c IN (:waiting, :failed)';
        queryString += '    AND ICN__c != null';
        queryString += '    AND MPI_Correlation_Id__c = null';
        return queryString;
    }

    /**
     * @description Helper to creat the MPI request body
     * @return `HttpRequest` The resulting request object
     */
    @TestVisible
    private static HttpRequest createHttpRequestWithoutBody() {
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('clientid', '{!$Credential.UserName}');
        request.setHeader('clientSecret', '{!$Credential.Password}');
        request.setTimeout(120000);
        request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIeVetRetrieve'));
        return request;
    }

    /**
     * @description Send the HTTP request, and returns the resulting response object
     *
     * @param request The HTTP request to send
     * @param identityVar The VA identity value that the request needs to work with
     *
     * @return Resulting response object from the MPI request
     */
    @TestVisible
    private HttpResponse sendRequestForIdentity(HttpRequest request, VA_Identity__c identityVar) {
        HttpResponse resp = null;
        if (String.isBlank(identityVar.ICN__c)) {
            Logger.error('ICN__c cannot be blank ' + identityVar);
        } else {
            setHttpRequestBody(request, identityVar);
            try {
                resp = (new Http()).send(request);
            } catch (Exception ex) {
                Logger.error('Caught exception sending request to MPI ' + request, ex);
            }
        }
        return resp;
    }

    /**
     * @description Sets the request body text for the specified `request` object.
     * @param request The HTTP request that needs its body set
     * @param identityVar The vet identity value that the request needs to work with
     */
    @TestVisible
    private void setHttpRequestBody(HttpRequest request, VA_Identity__c identityVar) {
        request.setBody(
            JSON.serialize(
                new Map<Object, Object>{
                    'userId' => requesterUserDefaultValue,
                    'id' => identityVar.ICN__c,
                    'idType' => 'ICN',
                    'unattended' => true,
                    'showCorrelated' => false,
                    // BGS can be added to the list of datasets in the future, when needed
                    'datasets' => new List<String>{ 'VA_PROFILE', 'EE' }
                }
            )
        );
    }

    /**
     * @description Update a set of IDs with the appropriate values from a supplied list
     * @param srList Save-result list
     */
    @TestVisible
    private void updateSuccessIdSet(Database.SaveResult[] srList) {
        for (Database.SaveResult mySaveResults : srList) {
            if (mySaveResults.isSuccess() == false) {
                successIdSet.remove(mySaveResults.getId());
            }
        }
    }

    /**
     * @description Update the external identities with values from a supplied list
     * @param srList Save result list containing the values that were persisted
     * @param personAccountToInsert Person accounts we will create based on the save result
     * @param vaIdentityMapByIcn <waiting on definition>
     */
    @TestVisible
    private static void updateVaIdentities(
        Database.SaveResult[] srList,
        List<Account> personAccountToInsert,
        Map<String, VA_Identity__c> vaIdentityMapByIcn
    ) {
        Map<String, Id> contactMapByIcn = getContactIdByIcn(vaIdentityMapByIcn.keySet());
        for (Integer myInt = 0; myInt < personAccountToInsert.size(); myInt++) {
            Database.SaveResult mySaveResults = srList[myInt];
            Account acctRec = personAccountToInsert[myInt];
            String icn = acctRec.VCC_MVI_External_Id__pc;
            VA_Identity__c identityVar = vaIdentityMapByIcn.get(icn);
            if (mySaveResults.isSuccess()) {
                identityVar.Salesforce_Contact_Id__c = contactMapByIcn.get(icn); //acctRec.PersonContactId
            } else {
                identityVar.MPI_Retrieve_Error_Message__c =
                    'Error creating Account from MPI Data:' + String.join(mySaveResults.getErrors(), '');
                identityVar.MPI_Retrieve_Error_Message_Datetime__c = System.now();
            }
        }
    }

    /**
     * @description Get a map of contact IDs for a given set of ICNs
     * @param icnSet Set of ICNs used to look up contact IDs
     * @return `Map<String,ID>` Map of resulting Contact IDs with associated ICNs
     */
    @TestVisible
    private static Map<String, Id> getContactIdByIcn(Set<String> icnSet) {
        Map<String, Id> contactMapByIcn = new Map<String, Id>();
        VCR_ContactRepo contactRepo = new VCR_ContactRepo();
        List<Contact> contactList = contactRepo.getContactFromIcnSet(icnSet);
        for (Contact contactRec : contactList) {
            contactMapByIcn.put(contactRec.VCC_MVI_External_Id__c, contactRec.Id);
        }
        return contactMapByIcn;
    }

    /**
     * @description Parsed HTTP response
     * @param responseWrapper Helper object that defines what we get back from the HTTP request
     */
    @TestVisible
    private void parseResponse(ResponseWrapper responseWrapper) {
        HttpResponse resp = responseWrapper.resp;
        VA_Identity__c identityVar = responseWrapper.identityVar;
        Map<String, VA_Identity__c> vaIdentityMapByIcn = responseWrapper.vaIdentityMapByIcn;
        List<Account> personAccountToInsert = responseWrapper.personAccountToInsert;
        VCC_MpiRetrieveLogic logicClass = new VCC_MpiRetrieveLogic();

        if (resp == null) {
            Logger.error('Unable to send request for identity ' + identityVar);
        } else {
            String responseBody = resp.getBody();
            responseBody = responseBody.replace('\\', '\\');
            if (resp.getStatusCode() != 200) {
                Logger.error('Failed to retrieve information from MPI for VA_Identity__c ' + identityVar);
                vaIdentityMapByIcn.put(identityVar.ICN__c, handleFailure(identityVar, responseBody));
            } else {
                Logger.debug('Retrieve information from MPI for VA_Identity__c  ' + identityVar);
                VCC_MPIParser.VetDetails vetDetails = logicClass.extractVetDetails(responseBody);
                Account accountToInsert = prepForAcctInsert(vetDetails);
                if (accountToInsert != null) {
                    personAccountToInsert.add(accountToInsert);
                }
                vaIdentityMapByIcn.put(identityVar.ICN__c, handleSuccess(identityVar, vetDetails));
            }
        }
    }

    /**
     * @description Handle any failure state gracefully
     * @param identityVar The VA identity that failed
     * @param responseBody Body of the response where a failure state was detected
     * @return `VA_Identity__c` object that caused the failure
     */
    @TestVisible
    private VA_Identity__c handleFailure(VA_Identity__c identityVar, String responseBody) {
        VA_Identity__c vaIdRecord = new VA_Identity__c(Id = identityVar.Id);
        String errorMsg = '';
        if (String.isNotBlank(responseBody)) {
            Map<String, Object> mapOfResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
            errorMsg = (String) mapOfResponse.get('errorType') + ': ' + (String) mapOfResponse.get('message');
        } else {
            errorMsg = 'HTTP Response body is blank';
        }
        vaIdRecord.MPI_Retrieve_Error_Message__c = errorMsg;
        vaIdRecord.MPI_Retrieve_Error_Message_Datetime__c = System.now();
        vaIdRecord.MPI_Correlation_Status__c = failed;
        Logger.debug('Error Message: ' + errorMsg);
        return vaIdRecord;
    }

    /**
     * @description Handle any success state
     *
     * @param identityVar The VA identity that succeeded
     * @param vetDetails Data for the vet record that succeeded
     *
     * @return `VA_Identity__c` object that succeeded
     */
    @TestVisible
    private VA_Identity__c handleSuccess(VA_Identity__c identityVar, VCC_MPIParser.VetDetails vetDetails) {
        VA_Identity__c vaIdRecord = new VA_Identity__c(Id = identityVar.Id);
        VCC_MpiRetrieveLogic logicClass = new VCC_MpiRetrieveLogic();
        logicClass.modifyVaIdentityRecordForUpdate(vaIdRecord, vetDetails.vaProfileV1, vetDetails.vaProfile);
        logicClass.modifyVaIdentityRecordForUpdate(vaIdRecord, vetDetails);
        logicClass.modifyVaIdentityRecordForUpdate(vaIdRecord, identityVar);
        successIdSet.add(identityVar.Id);
        return vaIdRecord;
    }

    /**
     * @description Prepare a vet account for insert into SF
     * @param vetDetails Details of the vet record to be inserted
     * @return `Account` that will be inserted
     */
    @TestVisible
    private Account prepForAcctInsert(VCC_MPIParser.VetDetails vetDetails) {
        Account accountForInsert = null;
        try {
            VCC_MpiRetrieveLogic logicClass = new VCC_MpiRetrieveLogic();
            accountForInsert = initAccount(vetDetails);
            accountForInsert = logicClass.updateGender(accountForInsert, vetDetails);
            accountForInsert = logicClass.updateDateOfBirth(accountForInsert, vetDetails);
            accountForInsert = logicClass.updateDateOfBirthText(accountForInsert, vetDetails);
            accountForInsert = logicClass.updateDateOfDeath(accountForInsert, vetDetails);
            accountForInsert = VCC_MPIHelper.updateVAProfileFields(accountForInsert, vetDetails.vaProfileV1);
            accountForInsert = VCC_MPIHelper.updateESRFields(accountForInsert, vetDetails.ee);
        } catch (Exception myException) {
            Logger.error('Failed to initialize account for insert', myException);
        }
        return accountForInsert;
    }

    /**
     * @description Initialize account for details insertion
     * @param vetDetails Details to be inserted
     * @return `Account` that was initialized
     */
    @TestVisible
    private Account initAccount(VCC_MPIParser.VetDetails vetDetails) {
        return new Account(
            Salutation = vetDetails?.mvi?.prefixName,
            PersonTitle = vetDetails?.mvi?.prefixName,
            FirstName = vetDetails?.mvi?.firstName,
            MiddleName = vetDetails?.mvi?.middleName,
            LastName = vetDetails?.mvi?.lastName,
            Suffix = vetDetails?.mvi?.suffixName,
            HealthCloudGA__TaxId__c = vetDetails?.mvi?.ssn,
            SSN_Search__c = (vetDetails?.mvi?.lastName != null ? vetDetails?.mvi?.lastName.substring(0, 1) : '') +
                (vetDetails?.mvi?.ssn != null ? vetDetails?.mvi?.ssn.substring(vetDetails?.mvi?.ssn.length() - 4) : ''),
            RecordTypeId = this.personAcctRecordTypeId,
            OwnerId = UserInfo.getUserId(),
            VCC_MVI_External_Id__pc = vetDetails.mvi.icn // must have ICN
        );
    }

    /**
     * @description Wrapper class for ResponseWrapper
     */
    public class ResponseWrapper {
        /**@description HttpResponse resp*/
        @TestVisible
        public HttpResponse resp { get; set; }
        /**@description VA_Identity__c identityVar*/
        @TestVisible
        public VA_Identity__c identityVar { get; set; }
        /**@description Map<String, VA_Identity__c> vaIdentityMapByIcn*/
        @TestVisible
        public Map<String, VA_Identity__c> vaIdentityMapByIcn { get; set; }
        /**@description List<Account> personAccountToInsert*/
        @TestVisible
        public List<Account> personAccountToInsert { get; set; }

        /**
         * @description Constructor for ResponseWrapper
         */
        public ResponseWrapper() {
            this.resp = new HttpResponse();
            this.identityVar = new VA_Identity__c();
            this.vaIdentityMapByIcn = new Map<String, VA_Identity__c>();
            this.personAccountToInsert = new List<Account>();
        }
    }
}
