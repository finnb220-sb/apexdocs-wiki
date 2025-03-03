/**
 * @description This class performs operations for vccMedicationList and related components
 * @author Booz Allen Hamilton
 * @group API - Bridg - Meds
 *
 * Jeff Watson 2023.05.24 Signed off of PMD suppression.  This code needs to be rewritten.
 */

@SuppressWarnings('PMD.cyclomaticComplexity, PMD.CognitiveComplexity')
public with sharing class VCC_MedsListController {
    @TestVisible
    static final String MVI_ID_ERROR = 'An MPI ID could not be found for this record.';
    @TestVisible
    static Boolean throwException = false;

    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static VCR_PharmacyRepo pharmacyRepo {
        get {
            if (pharmacyRepo == null) {
                pharmacyRepo = new VCR_PharmacyRepo();
            }
            return pharmacyRepo;
        }
        set;
    }

    /**
     * @description - Exception class for VCC_MedsListCtrl
     */
    public class VCC_MedsListCtrlException extends Exception {
    }

    /**
     * @description - gets patient Account record based on icn
     * @param icn - the patients icn
     * @return `Account`
     * @exception - AuraHandledException
     */
    @AuraEnabled
    public static Account getPatientasSFRecord(String icn) {
        try {
            VCC_AccountSelector selector = new VCC_AccountSelector();
            selector.addSObjectFields(
                new List<Schema.SObjectField>{
                    Account.ShippingAddress,
                    Account.BillingAddress,
                    Account.PersonMailingAddress
                }
            );
            return selector.selectByICN(new Set<String>{ icn })[0];
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description - Gets Patient demographic data based on Vista instance
     * @param params - represents facilityId and patient ien in a Map
     * @return `VCC_VISTAModel`
     * @exception - AuraHandledException
     */
    @AuraEnabled
    public static VCC_VISTAModel fetchDemographicsByVista(Map<String, String> params) {
        try {
            return VCC_VISTADataService.getDemographicsByVista(
                new VCC_BridgRequest(params.get('facilityId'), params.get('ien'))
            );
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    /**
     * @description Fetches IEN number from MPI for correct fetchDemographicsByVista return.
     * @param params map<string, string> (icnNumber, facilityId)
     * @return String
     */
    @AuraEnabled
    public static String getFacilityIens(Map<String, String> params) {
        try {
            HttpResponse res = VCC_MPI_HTTP.dispatchRequest(
                VCC_MPI_HTTP.createRequest('POST', JSON.serialize(params), 'vccMpiRetrieveLocalPid')
            );
            return ((String) ((Map<String, Object>) JSON.deserializeUntyped(res.getBody())).get('patientIdAtFacility'));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description - Gets Pharmacy activity log
     * @param logType which activity log to fetch
     * @param jsObject javascript object with the request payload
     * @return  `String`
     */
    @AuraEnabled
    public static VCC_DivaResponse fetchPharmacyLog(String logType, Map<String, Object> jsObject) {
        try {
            VCC_PharmacyLogRQ pharmLogRQ = new VCC_PharmacyLogRQ(jsObject);
            VCC_Enum.VCC_PharmacyLogType type = VCC_Enum.VCC_PharmacyLogType.valueOf(logType); // mapping string from lwc into pharm log enum type

            if (!pharmLogRQ.isValid()) {
                throw new VCC_MedsListCtrlException('Request is invalid');
            }

            return VCC_MedsService.getPharmacyLog(type, pharmLogRQ);
        } catch (VCC_DivaClient.VCC_DivaBadRequestException ex) {
            // 400 errors
            Logger.debug('DIVA bad request ' + ex.getMessage());
            Logger.saveLog();
            throw new AuraHandledException(ex.getMessage());
        } catch (VCC_DivaClient.VCC_DivaRemoteInternalException ex) {
            // 500 errors
            Logger.debug('DIVA remote server error ' + ex.getMessage());
            Logger.saveLog();
            throw new AuraHandledException(ex.getMessage());
        } catch (VCC_MedsService.VCC_MedsServiceException ex) {
            // meds service error aka, log type not supported error
            Logger.debug(ex.getMessage());
            Logger.saveLog();
            throw new AuraHandledException('Log Type Not Supported ' + ex.getMessage());
        } catch (Exception ex) {
            throw new AuraHandledException(ex.getMessage());
        }
    }

    /**
     * @description Fetches Medication data.
     * @param recordId - recordId from the Case page
     * @param isDebugMode - boolean to decide whether or not to use debug
     * @return String
     */
    @AuraEnabled(Cacheable=true)
    public static String fetchMedsData(String recordId, Boolean isDebugMode) {
        // System.debug(LoggingLevel.INFO, 'isDebugMode: ' + isDebugMode);
        /*
                 Takes the ID of a record, looks up the MPI/MVI ID, and calls out to the
                 Meds API to retrieve a list of medications for the person with that MPI/MVI ID.
                 Returns a JSON-formatted string with the Meds API response, or any relevant error
                 that occurred in the process.
 
                 @param recordId     A string containing the record ID for lookup
                 @return String      A JSON-formatted string with the Meds API response, or any relevant error
                                     that occurred in the process
             */

        // get the MVI / MPI Id corresponding to the record
        String mviId = VCC_lwc_utils.getICN(recordId);

        // if MVI ID is found
        if (mviId != null) {
            if (isDebugMode) {
                StaticResource staticResource = [
                    SELECT Id, Body
                    FROM StaticResource
                    WHERE Name = 'VCC_MedsRefillExample'
                    WITH SECURITY_ENFORCED
                    LIMIT 1
                ];
                return staticResource.Body.toString();
            } else {
                // perform callout to Meds API
                Map<String, String> meds = doMedsApiCallout(mviId);

                // if no errors returned from callout and return value exists
                if (meds.get('error') == null && meds.get('value') != null) {
                    // return the response from the Meds API
                    // System.debug(LoggingLevel.INFO, '##RESPONSE: ' + meds.get('value'));
                    return meds.get('value');
                } else {
                    // otherwise, return error from callout in JSON format
                    return '{"apexError":"' + meds.get('error') + '"}';
                }
            }
        } else {
            // otherwise, return error due to lack of MVI ID in JSON format
            return '{"apexError":"' + MVI_ID_ERROR + '"}';
        }
    }

    /**
     * @description Takes the MVI/MPI ID of an individual, and performs a callout to the Meds API (Named Credential: VCC_Meds_API).
     * @param mviId
     * @return Map<String, String>
     */
    @TestVisible
    private static Map<String, String> doMedsApiCallout(String mviId) {
        /*
             Takes the MVI/MPI ID of an individual, and performs a callout to the Meds API (Named Credential: VCC_Meds_API).
             Returns the JSON - formatted Meds API response, or any errors in retrieving that response.
             
             @param mviId -                  A string containing the MVI/MPI ID of the person to find medications for via the Meds API
             @return Map<String, String>     A Map containing keys for either a successful callout ('value') or failed callout ('error')
                                             and the API response for the 'value' key or error description for the 'error' key
         */

        VCC_Workstream_Settings__mdt workstreamSettings = VCC_WorkstreamSettingsController.getWorkstreamSettings();

        // create the HTTP request for the Meds API callout, using the VCC_Meds_API Named Credential
        HttpRequest req = new HttpRequest();
        req.setEndpoint(VCC_EndpointUtility.getEndpoint('Bridg', 'vccBridgMeds'));
        req.setHeader('APIKEY', '{!$Credential.Password}');
        req.setHeader('Content-Type', 'application/json');
        req.setTimeout(120000);
        req.setMethod('POST');
        req.setBody(
            '{"nationalId":"' +
                mviId +
                '","ien": "202243", "startDate":"' +
                System.now().addMonths(-Integer.valueOf(workstreamSettings.VCC_Meds_Duration__c)).format('yyyy-MM-dd') +
                '"}'
        );

        // create a map to hold return value(s) and potential errors
        Map<String, String> rMap = new Map<String, String>();

        try {
            // send the HTTP request
            Http http = new Http();
            HttpResponse httpResponse = http.send(req);

            // retrieve status code of the request
            Integer statusCode = httpResponse.getStatusCode();

            if (statusCode == 200) {
                // 200 OK

                // put the return body into the value key of the map
                rMap.put('value', httpResponse.getBody());
            } else {
                // 400 or 500 error

                // put the status message into the error key of the map
                rMap.put('error', httpResponse.getStatus());
            }
            return rMap;
        } catch (Exception e) {
            rMap.put('error', e.getMessage());
            return rMap;
        }
    }

    /**
     * @description - Parses the medication response from the Bridg API
     */
    public class MedsWrapper {
        @AuraEnabled
        public String medsResponse;
        @AuraEnabled
        public List<String> errors;
        @AuraEnabled
        public VCC_BridgMedsResponseParser v1;
        @AuraEnabled
        public Boolean isMaxRecordsError;

        public MedsWrapper(String medsResponse, List<String> errors, VCC_BridgMedsResponseParser v1) {
            this.medsResponse = medsResponse;
            this.errors = errors;
            this.v1 = v1;
        }
    }

    /**
     * @description Generates bridge request and callout to get meds list
     * @param icn string patient ICN Number
     * @param startDate string Medication StartDate formatted  yyyy-mm-dd
     * @return `MedsWrapper`
     * @exception - AuraHandledException
     */
    @AuraEnabled(Cacheable=true)
    public static MedsWrapper getMedsWithParams(String icn, String startDate) {
        try {
            VCC_BridgMedsRQ medsRequest = new VCC_BridgMedsRQ(icn, startDate, 'USVHA');
            VCC_BridgClient bridgClient = new VCC_BridgClient(new Set<VCC_BaseClient.ClientOption>{});
            return VCC_Adapter_BridgToLWC.vccMedicationList((bridgClient).meds(medsRequest));
        } catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    /**
     * @description - Gets the User based on Id from input parameter
     * @param userId - userId from calling component
     * @return `User`
     */
    @AuraEnabled
    public static User getRequesterName(Id userId) {
        return [SELECT Id, Name FROM User WHERE Id = :userId WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
     * @description - Gets Case record based on Case recordId
     * @param recordId - recordId from the Case page
     * @return `Case`
     */
    @AuraEnabled
    public static Case getCaseInfo(String recordId) {
        Id incomingId = (Id) recordId;
        return [SELECT Id, IsClosed, OwnerId FROM Case WHERE Id = :incomingId WITH SECURITY_ENFORCED LIMIT 1];
    }

    /**
     * @description - Gets related Account record based on Case recordId
     * @param caseId - recordId from the Case page
     * @return `Account`
     */
    @AuraEnabled(Cacheable=true)
    public static Account getAccountInfo(String caseId) {
        Id incomingId = (Id) caseId;
        return [
            SELECT Account.FirstName, Account.LastName, Account.MiddleName, Account.HealthCloudGA__BirthDate__pc
            FROM Case
            WHERE Id = :incomingId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ]
        .Account;
    }

    /**
     * @description
     * @param recordId - recordId from the PN page
     * @return `VCC_Progress_Note__c`
     */
    @AuraEnabled
    public static VCC_Progress_Note__c getProgressNoteInfo(String recordId) {
        Id incomingId = (Id) recordId;
        return [
            SELECT
                Id,
                RecordType.DeveloperName,
                CreatedById,
                VCC_Signed__c,
                VCC_Facility__c,
                VCC_Controlled_medication__c,
                VCC_Non_controlled_medication__c
            FROM VCC_Progress_Note__c
            WHERE Id = :incomingId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];
    }

    /**
     * @description
     * @param objectInfo - The Salesforce entity requesting refill
     * @param requestData - Medication refill details
     * @return `VCC_MedsService.MedRefillResponse` - returns the response from the refill request with the related Case object and Boolean allSuccessful
     * @exception - AuraHandledException
     */
    @AuraEnabled
    public static VCC_MedsService.MedRefillResponse handleRefillRequest(
        ObjectInfo objectInfo,
        RequestData requestData
    ) {
        try {
            List<VCC_MedsService.MedRefillRequest> medRefills = (List<VCC_MedsService.MedRefillRequest>) JSON.deserialize(
                requestData.requestJSON,
                List<VCC_MedsService.MedRefillRequest>.class
            );
            VCC_MedsService.MedRefillResponse medRefillResponse = new VCC_MedsService.MedRefillResponse();
            switch on objectInfo.sObjectType {
                when 'Case' {
                    medRefillResponse = VCC_MedsService.refillMedications(new Case(id = objectInfo.id), medRefills);
                }
                when 'Account' {
                    medRefillResponse = VCC_MedsService.refillMedications(new Account(id = objectInfo.id), medRefills);
                }
                when 'VCC_Progress_Note__c' {
                    medRefillResponse = VCC_MedsService.refillMedications(
                        new VCC_Progress_Note__c(id = objectInfo.id),
                        medRefills
                    );
                }
            }

            return medRefillResponse;
        } catch (Exception e) {
            throw new AuraHandledException(e.getStackTraceString() + ' ' + e.getMessage());
        }
    }

    /**
     * @description Get workstream settings from custom metadata records
     * @return  `Map<String, VCC_Workstream_Settings__mdt>`
     */
    @AuraEnabled
    public static Map<String, VCC_Workstream_Settings__mdt> getWorkstreamSettings() {
        return VCC_Workstream_Settings__mdt.getAll();
    }

    /**
     * @description Get Temp Address by ICN and Facility
     * @param args - contains 2 key value pairs: facilityId: value is the requested facilityId, and icn: value is the patient's icn
     * @param makeTempAddressCallout - boolean to decide whether or not to make callout
     * @return VTC_DataModel - The data model containing the Temp Address data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_RecordModel getTemporaryAddress(Map<String, Object> args, Boolean makeTempAddressCallout) {
        if (!makeTempAddressCallout || args.isEmpty()) {
            return null;
        }
        args.put('application', APPLICATION);
        try {
            return pharmacyRepo.getTemporaryAddress(args);
        } catch (VTC_LimitException e) {
            Logger.error('Limit exception getting temporary addresses for patient.', e);
            throw new AuraHandledException(e.getMessage());
        } catch (Exception e) {
            Logger.error('Exception getting temporary addresses for patient.', e);
            throw new AuraHandledException(e.getMessage());
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description - ObjectInfo
     */
    public class ObjectInfo {
        @AuraEnabled
        public String sObjectType { get; set; }
        @AuraEnabled
        public Id id { get; set; }
    }

    /**
     * @description - RequestData
     */
    public class RequestData {
        // public sObject sobject { get; set; }
        @AuraEnabled
        public String requestJSON { get; set; }
        // public List<VCC_MedsService.MedRefillRequest> requestJSON { get; set; }
    }

    /**
     * @description - Formatted Meds
     */
    public class FormattedMed {
        @AuraEnabled
        public VCC_BridgMedsResponseParser.Medication fullData;
        @AuraEnabled
        public String drugName {
            get {
                String productName;
                String vaGenericName;
                String name = fullData?.name?.value;
                String rVal = '';

                try {
                    if (fullData?.products?.product?.size() != 0) {
                        productName = fullData?.products?.product[0]?.name;
                    } else {
                        productName = '';
                    }
                } catch (Exception e) {
                    Logger.error(e.getStackTraceString());
                }

                try {
                    if (fullData?.products?.product?.size() != 0) {
                        vaGenericName = fullData?.products?.product[0]?.vaGeneric?.name;
                    } else {
                        vaGenericName = '';
                    }
                } catch (Exception e) {
                    Logger.error(e.getStackTraceString());
                }

                if (productName != null && productName != '') {
                    rVal = productName;
                } else if (vaGenericName != null && vaGenericName != '') {
                    rVal = vaGenericName;
                } else if (name != null && name != '') {
                    rVal = name;
                }
                return rVal;
            }
        }
        @AuraEnabled
        public String prescriptionValue {
            get {
                return fullData?.prescription?.value;
            }
        }
        @AuraEnabled
        public String dosesDoseDosage {
            get {
                String doseString = '';
                if (fullData?.doses?.dose != null && fullData?.doses?.dose.size() > 0) {
                    VCC_BridgMedsResponseParser.Dose lastDose = fullData.doses.dose[fullData.doses.dose.size() - 1];
                    if (
                        (lastDose?.Noun != null && lastDose?.Noun != '') &&
                        (lastDose?.unitsPerDose != null &&
                        lastDose?.unitsPerDose != '')
                    ) {
                        doseString = lastDose.unitsPerDose + ' ' + lastDose.Noun;
                    } else if (lastDose?.dose != null && lastDose?.dose != '') {
                        doseString = lastDose.dose;
                    } else {
                        doseString += lastDose?.dose == null ? '' : lastDose.dose;
                        doseString += lastDose?.units == null ? '' : lastDose.units;
                        doseString += lastDose?.noun == null ? '' : ' ' + lastDose.noun;
                    }
                }
                return doseString;
            }
        }
        @AuraEnabled
        public String fillsReleaseDate {
            get {
                String releaseDateString = '';
                // TODO: Redundant code - refactor and set the property in a helper method
                if (fullData?.fills?.fill != null && fullData?.fills?.fill.size() > 0) {
                    for (VCC_BridgMedsResponseParser.MedsFill currentFill : fullData.fills.fill) {
                        String fillDate = currentFill.formattedReleaseDate;
                        if (fillDate != null) {
                            releaseDateString = (String.isBlank(releaseDateString) || releaseDateString < fillDate)
                                ? fillDate
                                : releaseDateString;
                        }
                    }
                }
                return releaseDateString;
            }
        }

        @AuraEnabled
        public String fillsReleaseDateMonth {
            get {
                String releaseMonthString = '';
                // TODO: Redundant code - refactor and set the property in a helper method
                if (fullData?.fills?.fill != null && fullData?.fills?.fill.size() > 0) {
                    VCC_BridgMedsResponseParser.MedsFill mostRecentFill;
                    for (VCC_BridgMedsResponseParser.MedsFill currentFill : fullData.fills.fill) {
                        if (currentFill.formattedReleaseDate != null) {
                            mostRecentFill = (mostRecentFill == null ||
                                (mostRecentFill.formattedReleaseDate != null &&
                                mostRecentFill.formattedReleaseDate < currentFill.formattedReleaseDate))
                                ? currentFill
                                : mostRecentFill;
                        }
                    }
                    releaseMonthString = mostRecentFill.releaseDateMonth;
                }
                return releaseMonthString;
            }
        }

        @AuraEnabled
        public String vaStatusValue {
            get {
                return fullData?.vaStatus?.value;
            }
        }

        @AuraEnabled
        public String orderingProviderName {
            get {
                return fullData?.orderingProvider?.Name;
            }
        }

        @AuraEnabled
        public String expiresValue {
            get {
                return fullData?.expires?.formattedValue;
            }
        }

        @AuraEnabled
        public String expriesValueMonth {
            get {
                return fullData?.expires?.expiresMonthValue;
            }
        }

        @AuraEnabled
        public Double quantityValue {
            get {
                return Integer.valueOf(
                    fullData?.quantity?.formattedValue == null ? 0 : fullData.quantity.formattedValue
                );
            }
        }

        @AuraEnabled
        public String startValue {
            get {
                return fullData?.start?.formattedValue;
            }
        }

        @AuraEnabled
        public String startValueMonth {
            get {
                return fullData?.start?.valueMonth;
            }
        }

        @AuraEnabled
        public String lastFilledValue {
            get {
                return fullData?.lastFilled?.formattedValue;
            }
        }

        @AuraEnabled
        public String lastFilledValueMonth {
            get {
                return fullData?.lastFilled?.valueMonth;
            }
        }

        @AuraEnabled
        public Integer fillsRemainingValue {
            get {
                return fullData?.fillsRemaining?.formattedValue == null ? 0 : fullData.fillsRemaining.formattedValue;
            }
        }

        @AuraEnabled
        public String routingValue {
            get {
                return fullData?.routing?.value;
            }
        }

        @AuraEnabled
        public String sig {
            get {
                return fullData?.sig?.content;
            }
        }

        @AuraEnabled
        public String id {
            get {
                return fullData?.id?.value;
            }
        }

        /**
         * @description - Constructor
         * @param med - VCC_BridgMedsResponseParser.Medication
         */
        public FormattedMed(VCC_BridgMedsResponseParser.Medication med) {
            fullData = med;
        }
    }

    /**
     * @description - Exception class for MedsRetrievalException
     */
    class MedsRetrievalException extends Exception {
    }
}
