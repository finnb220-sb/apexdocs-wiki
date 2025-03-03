/**
 * @description This class holds methods used by Flows to interact with patient information via MPI callouts
 *              NOTE: this code duplicates callout logic in the VCC_lwc_utils.retrieveVetInfo method that is set to be reworked in the future, so this logic should be reworked at that time as well
 * @author      Booz Allen
 * @since       2024
 */
public with sharing class PC_PatientMpiCalloutsInvocable {
    /**
     * @description repo class for Account SOQL/DML
     */
    @TestVisible
    private static VCR_AccountRepo accountRepo {
        get {
            return accountRepo = accountRepo ?? new VCR_AccountRepo();
        }
        set;
    }

    /**
     * @description     Invocable entry point accessible from a Flow used to grab a patient's register facility data and the Person Id for the Referring Provider's location from MPI
     * @param flowInput Input from the flow (contains patient's account Id)
     * @return          `List<PatientMpiFlowOutput>` output for the flow (contain's list of patient's registered facilities and the Person Id for the Referring Provider's location from MPI)
     *                  - returns a blank list in patientRegisteredFacilities property if no facilities and/or a blank list in the localPid property if no Person Id for the Referring Provider's
     *                  location could be retrieved by the MPI callout
     */
    @InvocableMethod(
        Label='Get Patient Data via MPI'
        Description='Retrieves a Veteran\'s data from MPI (Registered Facilities and localPid)'
        Category='Provider Connect'
    )
    public static List<PatientMpiFlowOutput> getPatientDataFromFlow(List<PatientMpiFlowInput> flowInput) {
        List<PatientMpiFlowOutput> results = new List<PatientMpiFlowOutput>();
        VCC_MPIParser responseData = retrieveVetInfo(flowInput?.get(0)?.patientAccountId);

        List<String> registeredFacilityIds = parsePatientFacilitiesMPI(responseData);
        String localPid = parseLocalPidMPI(responseData, flowInput?.get(0)?.referringProviderFacilityId);

        PatientMpiFlowOutput flowOutput = new PatientMpiFlowOutput();
        flowOutput.patientRegisteredFacilities = String.join(registeredFacilityIds, ',');
        flowOutput.localPid = localPid;
        results.add(flowOutput);

        return results;
    }

    /**
     * @description        Parses the response data initiated from the callout to the MPI that retrieves veteran (patient) information to generate a list of their registered facilities
     * @param responseData Callout Response of the Patient's data retrieved from the retrieveVetInfo method
     * @return             `List<String>` List of Facility Id Codes for which the patient is already registered - if no matches found the returned list is empty
     */
    @TestVisible
    private static List<String> parsePatientFacilitiesMPI(VCC_MPIParser responseData) {
        if (responseData?.vetsV3?.get(0)?.mvi?.medicalCenterFacilities.isEmpty()) {
            return new List<String>();
        }

        Set<String> registeredFacilityIds = new Set<String>();
        for (
            VCC_MPIParser.MedicalCenterFacility registeredFacility : responseData
                ?.vetsV3
                ?.get(0)
                ?.mvi
                ?.medicalCenterFacilities
        ) {
            if (String.isNotBlank(registeredFacility?.facilityId)) {
                registeredFacilityIds.add(registeredFacility.facilityId);
            }
        }

        List<String> registeredFacilityIdsSorted = new List<String>(registeredFacilityIds);
        registeredFacilityIdsSorted.sort();

        return registeredFacilityIdsSorted;
    }

    /**
     * @description                                    Parses the response data initiated from the callout to the MPI that retrieves veteran (patient) information to generate their localPid
     * @param responseData                             Callout Response of the Patient's data retrieved from the retrieveVetInfo method
     * @param referringProviderFacilityId              The Facility Id of the FLP's (Referring Provider) location
     * @return                                         `String` String of the Person Id for the Referring Provider's location - if no matches found the returned String is empty
     */
    @TestVisible
    private static String parseLocalPidMPI(VCC_MPIParser responseData, String referringProviderFacilityId) {
        String localPid = '';

        if (
            responseData?.vetsV3?.get(0)?.mvi?.medicalCenterFacilities.isEmpty() ||
            String.isBlank(referringProviderFacilityId)
        ) {
            return localPid;
        }

        for (
            VCC_MPIParser.MedicalCenterFacility medicalFacility : responseData
                ?.vetsV3
                ?.get(0)
                ?.mvi
                ?.medicalCenterFacilities
        ) {
            if (referringProviderFacilityId.equals(medicalFacility?.facilityId)) {
                localPid = medicalFacility?.personId;
            }
        }

        return localPid;
    }

    /**
     * @description     driver method that generates and sends callout request to MPI to grab a patient's data and parse it into workable object form
     * @param patientId Salesforce person account ID of the patient (veteran)
     * @return          `VCC_MPIParser` the response from MPI parsed into object form
     */
    public static VCC_MPIParser retrieveVetInfo(Id patientId) {
        String patientICN = getPatientsICN(patientId);
        HttpRequest request = buildRetrieveVetInfoRequest(patientICN);
        HttpResponse response = sendRetrieveVetInfoRequest(request);
        VCC_MPIParser responseData = parseRetrieveVetInfoResponse(response);
        return responseData;
    }

    /**
     * @description     Queries for the person account of the patient (veteran) in order to retrieve their VCC_MVI_External_Id__pc field value, which is their ICN number in MPI
     * @param patientId salesforce Id of the patient account
     * @return          `String` VCC_MVI_External_Id__pc of the patient aka their ICN in MPI
     * @exception       PC_CustomException if the patientId parameter is blank
     * @exception       Exception catch, log and re-throw any other unexpected errors
     */
    @TestVisible
    private static String getPatientsICN(Id patientId) {
        Account acct;
        try {
            if (String.isBlank(patientId)) {
                throw new PC_CustomException('MPI retrieveVetInfo request failure: Patient Id is blank.');
            }
            acct = (Account) accountRepo.fetchById(
                patientId,
                new Set<String>{ 'Id', 'Name', 'VCC_MVI_External_Id__pc' }
            );
        } catch (PC_CustomException caughtCustomExcept) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.getPatientsICN Failed to retrieve Account for patient ' + patientId,
                caughtCustomExcept
            );
            throw caughtCustomExcept;
        } catch (Exception caughtExcept) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.getPatientsICN Failed to retrieve Account for patient ' + patientId,
                caughtExcept
            );
            throw caughtExcept;
        } finally {
            Logger.saveLog();
        }

        return acct?.VCC_MVI_External_Id__pc;
    }

    /**
     * @description      generates a request for the veteran's information from MPI
     * @param patientICN ICN number of the veteran patient in MPI that equates to their person account record's VCC_MVI_External_Id__pc field value
     * @return           `HttpRequest` request object with the required properties populated for a successful vccMPIeVetRetrieveV3 callout to MPI
     * @exception        PC_CustomException if the patientICN parameter is blank
     * @exception        Exception catch, log and re-throw any other unexpected errors
     */
    @TestVisible
    private static HttpRequest buildRetrieveVetInfoRequest(String patientICN) {
        HttpRequest request;
        try {
            if (String.isBlank(patientICN)) {
                throw new PC_CustomException('MPI retrieveVetInfo request failure: Patient ICN is blank.');
            }

            request = new HttpRequest();

            request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIeVetRetrieveV3'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);

            request.setBody(
                JSON.serialize(
                    new Map<Object, Object>{
                        'userId' => 'VAHC CRM',
                        'id' => patientICN,
                        'idType' => 'ICN',
                        'unattended' => true,
                        'showCorrelated' => false,
                        'datasets' => new List<String>{ 'VA_PROFILE', 'EE' }
                    }
                )
            );
        } catch (PC_CustomException caughtCustomException) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.buildRetrieveVetInfoRequest failed constructing the vccMPIeVetRetrieveV3 MPI request',
                caughtCustomException
            );
            throw caughtCustomException;
        } catch (Exception caughtException) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.buildRetrieveVetInfoRequest failed constructing the vccMPIeVetRetrieveV3 MPI request',
                caughtException
            );
            throw caughtException;
        } finally {
            Logger.saveLog();
        }

        return request;
    }

    /**
     * @description   sends a callout to MPI to retriebve a veteran's information
     * @param request `HttpRequest` request object with the required properties populated for a successful vccMPIeVetRetrieveV3 callout to MPI
     * @return        `HttpResponse` response object returned from the callout
     * @exception     VCC_RemoteServiceException if the callout did not return a 200 success status code, throw an error so we do not attempt to parse the response body
     * @exception     Exception catch, log and re-throw any other unexpected errors
     */
    @TestVisible
    private static HttpResponse sendRetrieveVetInfoRequest(HttpRequest request) {
        HttpResponse response;
        try {
            response = new Http().send(request);

            Integer statusCode = response.getStatusCode();
            if (statusCode != 200) {
                Logger.info('vccMPIeVetRetrieveV3 request body: ' + response?.getBody());
                throw new VCC_RemoteServiceException('MPI Application Error ' + statusCode);
            }
        } catch (VCC_RemoteServiceException caughtRemoteServiceException) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.sendRetrieveVetInfoRequest callout did not return a success status code of 200',
                caughtRemoteServiceException
            );
            throw caughtRemoteServiceException;
        } catch (Exception caughtException) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.sendRetrieveVetInfoRequest retrieveVetInfo callout failed',
                caughtException
            );
            throw caughtException;
        } finally {
            Logger.saveLog();
        }
        return response;
    }

    /**
     * @description     takes a HttpResponse object from a callout to MPI and parses it into a VCC_MPIParser object structure so that we can more easily work with the returned data
     * @param response  `HttpResponse` response object returned from the callout
     * @return          `VCC_MPIParser` object structure that contains the parsed response data
     * @exception       PC_CustomException if the HttpResponse parameter is null or the response body is empty
     * @exception       Exception catch, log and re-throw any other unexpected errors
     */
    @TestVisible
    private static VCC_MPIParser parseRetrieveVetInfoResponse(HttpResponse response) {
        VCC_MPIParser parsedResponse = new VCC_MPIParser();
        try {
            if (response == null || String.isEmpty(response?.getBody())) {
                throw new PC_CustomException('MPI retrieveVetInfo response failure: Response body was empty.');
            }

            parsedResponse = (VCC_MPIParser) JSON.deserialize(
                response
                    ?.getBody()
                    .replace('"null"', 'null') // Swapping "null" string for null literals
                    .replace('"true"', 'true')
                    .replace('"false"', 'false'),
                VCC_MPIParser.class
            );
        } catch (PC_CustomException caughtCustomException) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.parseRetrieveVetInfoResponse failed to parse the retrieveVetInfo response body',
                caughtCustomException
            );
            throw caughtCustomException;
        } catch (Exception caughtException) {
            Logger.error(
                'PC_PatientMpiCalloutsInvocable.parseRetrieveVetInfoResponse failed to parse the retrieveVetInfo response body',
                caughtException
            );
            throw caughtException;
        } finally {
            Logger.saveLog();
        }

        return parsedResponse;
    }

    /**
     * @description This inner class will handle the flow inputs
     */
    public class PatientMpiFlowInput {
        /**
         * @description Salesforce Account Id of the patient (veteran)
         */
        @InvocableVariable(required=true)
        public Id patientAccountId;
        /**
         * @description Salesforce Facility Id of the FLP's (Referring Provider) location
         */
        @InvocableVariable
        public String referringProviderFacilityId;
    }

    /**
     * @description This inner class will handle the flow outputs
     */
    public class PatientMpiFlowOutput {
        /**
         * @description comma delimited list of codes for patient's registered facilities
         */
        @InvocableVariable
        public String patientRegisteredFacilities;
        /**
         * @description Person Id for the Referring Provider's location
         */
        @InvocableVariable
        public String localPid;
    }
}
