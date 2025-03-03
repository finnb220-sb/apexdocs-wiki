/**
 * @description
 */
@SuppressWarnings('PMD.ExcessivePublicCount')
public with sharing class VCC_MedsService {
    /**
     * @description
     */
    public class VCC_MedsServiceException extends Exception {
    }

    /**
     * @description Calls out to DIVA and gets activity logs for an individual Rx/Med
       @param logType Pharmacy Log Request
       @param rq type of activity log to fetch from DIP
       @return  String Activity Log Response
     */

    public static VCC_DivaResponse getPharmacyLog(VCC_Enum.VCC_PharmacyLogType logType, VCC_PharmacyLogRQ rq) {
        // TODO: Integrate with DIVA when DIP is done 11/15/2022
        VCC_DivaClient divaClient = new VCC_DivaClient();

        switch on logType {
            when ACTIVITY {
                return divaClient.getActivityLog(rq);
            }
            when REFILL {
                return divaClient.getRefillLog(rq);
            }
            when LABEL {
                return divaClient.getLabelLog(rq);
            }
            when ERX {
                return divaClient.getERXLog(rq);
            }
            when COPAY {
                return divaClient.getCopayLog(rq);
            }
            when CMOP {
                return divaClient.getCMOPLog(rq);
            }
            when ECME {
                return divaClient.getECMELog(rq);
            }
            when PARTIAL {
                return divaClient.getPartialsLog(rq);
            }
            when CMOPLOTLOG {
                return divaClient.getCMOPLotExpLog(rq);
            }
            when else {
                throw new VCC_MedsServiceException('Meds Service Exception');
            }
        }
    }

    //? CASE
    /**
    * @description
	  @param cse
	  @param medRefillRequests
	  @return medRefillResponse
    */
    public static MedRefillResponse refillMedications(Case cse, List<MedRefillRequest> medRefillRequests) {
        fflib_ISObjectUnitOfWork uow = VCC_UoWDomain.createUoW();
        MedRefillResponse medRefillResponse = refillMedications(cse, medRefillRequests, uow);
        uow.commitWork();
        return medRefillResponse;
    }

    /**
    * @description
	  @param cse
	  @param medRefillRequests
	  @param uow
	  @return MedRefillResponse
    */
    public static MedRefillResponse refillMedications(Case cse, List<MedRefillRequest> medRefillRequests, fflib_ISObjectUnitOfWork uow) {
        // return mock response if training mode is enabled
        if (!Test.isRunningTest() && VCC_TrainingModeService.isTrainingModeEnabled()) {
            VCC_TrainingModeService.refillMedications(cse.Id, medRefillRequests);
            return new MedRefillResponse(true);
        }

        // check the inputs are ok (validation)
        if (String.isBlank(cse.id)) {
            throw new VCC_MedsServiceException('Case Id is required');
        }
        List<Case> cases = new VCC_CaseSelector().selectById(new Set<Id>{ cse.Id });
        if (cases == null || cases.isEmpty()) {
            throw new VCC_MedsServiceException('Case not found');
        }
        // set the retrieved case from case selector to the one passed into the domain
        cse = cases[0];

        // 1. build the request for DIVA & refill medications
        VCC_DivaClient divaClient = new VCC_DivaClient();
        List<VCC_DivaClient.RefillRequest> requestList = new List<VCC_DivaClient.RefillRequest>();
        for (MedRefillRequest medRefillRequest : medRefillRequests) {
            VCC_DivaClient.RefillRequest req = new VCC_DivaClient.RefillRequest(medRefillRequest);
            requestList.add(req);
        }
        divaClient.rqBody = new VCC_DivaClient.RefillMedicationsRQ(requestList);
        VCC_DivaClient.RefillMedicationsRS responses = new VCC_DivaClient.RefillMedicationsRS();
        responses = divaClient.refillMedications(divaClient.rqBody);

        // 2. update the case with result details
        new VCC_CaseDomain().setMedicationRefillDescription(cse, responses.responseJSON, medRefillRequests);

        uow.registerDirty(cse); //? dirty because it has been changed by domain (not matching database)

        return new MedRefillResponse(responses, cse);
    }

    //? ACCOUNT
    /**
    * @description
	  @param account
	  @param medRefillRequests
	  @return medRefillResponse
    */
    public static MedRefillResponse refillMedications(Account account, List<MedRefillRequest> medRefillRequests) {
        fflib_ISObjectUnitOfWork uow = VCC_UoWDomain.createUoW();
        MedRefillResponse medRefillResponse = refillMedications(account, medRefillRequests, uow);
        uow.commitWork();
        return medRefillResponse;
    }

    /**
    * @description
	  @param account
	  @param medRefillRequests
	  @param uow
	  @return MedRefillResponse
    */
    public static MedRefillResponse refillMedications(Account account, List<MedRefillRequest> medRefillRequests, fflib_ISObjectUnitOfWork uow) {
        // return mock response if training mode is enabled
        if (!Test.isRunningTest() && VCC_TrainingModeService.isTrainingModeEnabled()) {
            VCC_TrainingModeService.refillMedications(account.Id, medRefillRequests);
            return new MedRefillResponse(true);
        }

        // check the inputs are ok (validation)
        if (String.isBlank(account.id)) {
            throw new VCC_MedsServiceException('Account Id is required');
        }
        List<Account> accounts = new VCC_AccountSelector().selectById(new Set<Id>{ account.Id });
        if (accounts == null || accounts.isEmpty()) {
            throw new VCC_MedsServiceException('Account not found');
        }
        // set the retrieved account from account selector to the one passed into the domain
        account = accounts[0];

        // 1. build the request for DIVA & refill medications
        VCC_DivaClient divaClient = new VCC_DivaClient();
        List<VCC_DivaClient.RefillRequest> requestList = new List<VCC_DivaClient.RefillRequest>();
        for (MedRefillRequest medRefillRequest : medRefillRequests) {
            VCC_DivaClient.RefillRequest req = new VCC_DivaClient.RefillRequest(medRefillRequest);
            requestList.add(req);
        }

        divaClient.rqBody = new VCC_DivaClient.RefillMedicationsRQ(requestList);
        VCC_DivaClient.RefillMedicationsRS responses = new VCC_DivaClient.RefillMedicationsRS();
        responses = divaClient.refillMedications(divaClient.rqBody);

        // 2. Create a case
        Case cse = new VCC_CaseDomain().createMedicationRefillCase(account, responses.responseJSON.size(), responses.allSuccessful);
        uow.registerNew(cse); //! may need to be moved below

        // 3. Update description
        new VCC_CaseDomain().setMedicationRefillDescription(cse, responses.responseJSON, medRefillRequests);

        return new MedRefillResponse(responses, cse);
    }

    //? PROGRESS NOTE
    /**
    * @description
	  @param progressNote
	  @param medRefillRequests
	  @return medRefillResponse
    */
    public static MedRefillResponse refillMedications(VCC_Progress_Note__c progressNote, List<MedRefillRequest> medRefillRequests) {
        fflib_ISObjectUnitOfWork uow = VCC_UoWDomain.createUoW();
        MedRefillResponse medRefillResponse = refillMedications(progressNote, medRefillRequests, uow);
        uow.commitWork();
        return medRefillResponse;
    }

    /**
    * @description
	@param progressNote
	@param medRefillRequests
	@param uow
	@return MedRefillResponse
    */
    @SuppressWarnings('PMD.CyclomaticComplexity, PMD.CognitiveComplexity')
    public static MedRefillResponse refillMedications(VCC_Progress_Note__c progressNote, List<MedRefillRequest> medRefillRequests, fflib_ISObjectUnitOfWork uow) {
        // return mock response if training mode is enabled
        if (!Test.isRunningTest() && VCC_TrainingModeService.isTrainingModeEnabled()) {
            VCC_TrainingModeService.refillMedications(progressNote.Id, medRefillRequests);
            return new MedRefillResponse(true);
        }

        // check the inputs are ok (validation)
        if (String.isBlank(progressNote.id)) {
            throw new VCC_MedsServiceException('Progress Note Id is required');
        }

        List<VCC_Progress_Note__c> progressNotes = new VCC_ProgressNoteSelector().selectByIds(new Set<Id>{ progressNote.Id });
        if (progressNotes == null || progressNotes.isEmpty()) {
            throw new VCC_MedsServiceException('Progress Note not found');
        }
        progressNote = progressNotes[0];

        // 1. build the request for DIVA & refill medications
        VCC_DivaClient divaClient = new VCC_DivaClient();

        List<VCC_DivaClient.RefillRequest> requestList = new List<VCC_DivaClient.RefillRequest>();
        for (MedRefillRequest medRefillRequest : medRefillRequests) {
            VCC_DivaClient.RefillRequest req = new VCC_DivaClient.RefillRequest(medRefillRequest);
            requestList.add(req);
        }

        divaClient.rqBody = new VCC_DivaClient.RefillMedicationsRQ(requestList);
        VCC_DivaClient.RefillMedicationsRS responses = new VCC_DivaClient.RefillMedicationsRS();
        responses = divaClient.refillMedications(divaClient.rqBody);

        // 2. Update the parent case description
        Case cse = new Case();
        List<Case> cases = new VCC_CaseSelector().selectById(new Set<Id>{ progressNote.VCC_Case__c });
        if (cases == null || cases.isEmpty()) {
            throw new VCC_MedsServiceException('Case not found');
        }
        cse = cases[0];
        new VCC_CaseDomain().setMedicationRefillDescription(cse, responses.responseJSON, medRefillRequests);

        uow.registerDirty(cse); //? dirty because it has been changed by domain (not matching database)

        return new MedRefillResponse(responses, cse);
    }

    //? CLASSES
    /**
     * @description
     */
    public class MedRefillRequest {
        /**
         * @description
         */
        public String facilityId { get; set; }
        /**
         * @description
         */
        public String prescriptionId { get; set; }
        /**
         * @description
         */
        public String icn { get; set; }
        /**
         * @description
         */
        public String prescriptionName { get; set; }
        /**
         * @description
         */
        public String requesterId { get; set; }

        /**
         * @description
         */
        @SuppressWarnings('PMD.EmptyStatementBlock')
        public MedRefillRequest() {
        }
    }
    /**
     * @description
     */
    public class MedRefillResponse {
        /**
         * @description
         */
        @AuraEnabled
        public Boolean allSuccessful { get; set; }

        /**
         * @description
         */
        @AuraEnabled
        public Case caseObject { get; set; }
        /**
         * @description
         */
        public MedRefillResponse() {
            this.allSuccessful = false;
        }
        /**
         * @description
         * @param allSuccessful
         */
        public MedRefillResponse(Boolean allSuccessful) {
            this.allSuccessful = allSuccessful;
            this.caseObject = new Case(Id = SchemaHelper.GenerateIdFor(Case.SObjectType));
        }

        /**
        * @description
        @param refillMedicationRS
		@param cse
        */
        public MedRefillResponse(VCC_DivaClient.RefillMedicationsRS refillMedicationRS, Case cse) {
            this.allSuccessful = refillMedicationRS.allSuccessful;
            this.caseObject = cse;
        }
    }
}
