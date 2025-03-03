/**
 * @description This class houses many methods that are used when loading patient records in VAHC (and Tele-EC, in some cases). Many
 * of the functions in this class once lived in VCC_lwc_utils
 * @author Booz Allen
 * @see `VCC_OnPatientLoadControllerTest`
 */
public with sharing class VCC_OnPatientLoadController {
    /**
     * @description exception message thrown by method deferredMpiUpdate() when either argument is null
     * marked @TestVisible for use in VCC_OnPatientLoadControllerTest
     */
    @TestVisible
    private static final String DEFERRED_MPI_UPDATE_NULL_ARG_MSG = 'Both arguments must not be null';

    /**
     * @description exception message thrown by method deferredMpiUpdate() when the provided Id is not for SObject type Account
     * marked @TestVisible for use in VCC_OnPatientLoadControllerTest
     */
    @TestVisible
    private static final String DEFERRED_MPI_UPDATE_WRONG_ID_TYPE_MSG = 'Argument "accountId" must be an Id for SObject type Account';

    /**
     * @description exception message thrown by method deferredMpiUpdate() when MPI JSON is not provided
     * marked @TestVisible for use in VCC_OnPatientLoadControllerTest
     */
    @TestVisible
    private static final String DEFERRED_MPI_UPDATE_BLANK_MPI_STRING_MSG = 'Argument "responseDataString" must be a non-empty JSON string.';

    /**
     * @description exception message provided when the MPI ICN is missing in method "buildAndMakeMpieCalloutViaDip"
     * marked @TestVisible for use in VCC_OnPatientLoadControllerTest
     */
    @TestVisible
    private static final String MISSING_MVI_EXTERNAL_ID_MSG = 'No VCC_MVI_External_Id__pc provided';

    /**
     * @description The timeout provided to the HttpRequest in method "buildAndMakeMpieCalloutViaDip"
     * marked @TestVisible for use in VCC_OnPatientLoadControllerTest
     */
    @TestVisible
    private static final Integer MPIE_CALLOUT_MAX_TIMEOUT = 120000;

    /**
     * @description Repo class for IAM_SSOi_Vista_Instance_to_User_DUZ__c
     */
    public static VCR_IAMSSOiVistaInstToUserDUZRepo vistaInstanceToUserDuzRepo {
        get {
            if (vistaInstanceToUserDuzRepo == null) {
                vistaInstanceToUserDuzRepo = new VCR_IAMSSOiVistaInstToUserDUZRepo();
            }
            return vistaInstanceToUserDuzRepo;
        }
        set;
    }

    /**
     * @description Retrieve vet information from MPIe. This can be a long running callout.
     * @param recordId the `Id` of the account to retrieve information for
     * @return String serialized VCC_MPIParser object
     */
    @AuraEnabled(Cacheable=true Scope='Global')
    public static VCC_MPIParser retrieveVetInfo(Id recordId) {
        VCR_AccountRepo accountRepo = new VCR_AccountRepo();
        Account patientPersonAccountRecord = (Account) accountRepo.fetchById(
            recordId,
            new Set<String>{ 'VCC_MVI_External_Id__pc', 'Name' }
        );
        HttpResponse httpResponse;
        VCC_MPIParser mpiDto;
        try {
            httpResponse = buildAndMakeMpieCalloutViaDip(patientPersonAccountRecord);
            if (httpResponse.getStatusCode() != 200) {
                throw new VCC_RemoteServiceException('MPI Application Error ' + httpResponse.getStatusCode());
            }
            mpiDto = (VCC_MPIParser) JSON.deserialize(
                httpResponse.getBody().replace('"null"', 'null').replace('"true"', 'true').replace('"false"', 'false'), // Swapping "null" string for null literals
                VCC_MpiParser.class
            );
        } catch (Exception thrownException) {
            handleRetrieveVetInfoException(thrownException, httpResponse);
        }
        return mpiDto;
    }

    /**
     * @description re-throws and handles an exception thrown in function retrieveVetInfo
     * Marked @TestVisible for unit testing in isolation outside of the function it is called in.
     * @param thrownException `Exception` thrown from retrieveVetInfo
     * @param httpResponse `HttpResponse` for logging futher info
     */
    @TestVisible
    private static void handleRetrieveVetInfoException(Exception thrownException, HttpResponse httpResponse) {
        try {
            throw thrownException;
        } catch (CalloutException calloutException) {
            Logger.error('VCC_lwc_utils.retrieveVetInfo caught a calloutException', calloutException);
        } catch (JSONException jsonException) {
            Logger.error('VCC_lwc_utils.retrieveVetInfo caught a JSONException', jsonException);
        } catch (VCC_RemoteServiceException remoteServiceException) {
            Logger.error('MPI Application Error ' + httpResponse.getStatusCode());
            Logger.error('get body ' + httpResponse.getBody());
            Logger.error('VCC_lwc_utils.retrieveVetInfo caught a VCC_RemoteServiceException', remoteServiceException);
        } catch (IllegalArgumentException illegalArgumentException) {
            Logger.error('API request body is invalid', illegalArgumentException);
        } catch (Exception genericUnexpectedException) {
            Logger.error(
                'VCC_lwc_utils.retrieveVetInfo caught an unexpected Exception type',
                genericUnexpectedException
            );
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Given an Account SObject, uses the VCC_MVI_External_Id__pc field to construct
     * a request for, and fetch patient information from MPIe. Marked @TestVisible for unit testing
     * in isolation outside of the function it is called in (retrieveVetInfo).
     * @param accountToPullFromMpie patients Account SObject whose info is to be requested from MPIe
     * @return `HttpResponse` the HttpResponse received from MPIe
     */
    @TestVisible
    private static HttpResponse buildAndMakeMpieCalloutViaDip(Account accountToPullFromMpie) {
        if (accountToPullFromMpie?.VCC_MVI_External_Id__pc == null) {
            throw new VCC_RemoteServiceException(MISSING_MVI_EXTERNAL_ID_MSG);
        }
        /// HTTP Callout to MPIe
        HttpRequest request = new HttpRequest();

        request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIeVetRetrieveV3'));

        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('clientid', '{!$Credential.UserName}');
        request.setHeader('clientSecret', '{!$Credential.Password}');
        request.setTimeout(MPIE_CALLOUT_MAX_TIMEOUT);

        RetrieveVetInfoRQ retrieveVetInfoRequest = new RetrieveVetInfoRQ();
        retrieveVetInfoRequest.userId = 'VAHC CRM';
        retrieveVetInfoRequest.id = accountToPullFromMpie?.VCC_MVI_External_Id__pc;
        retrieveVetInfoRequest.idType = 'ICN';
        retrieveVetInfoRequest.unattended = true;
        retrieveVetInfoRequest.showCorrelated = false;
        retrieveVetInfoRequest.datasets.add('VA_PROFILE');
        retrieveVetInfoRequest.datasets.add('EE');
        retrieveVetInfoRequest.isValid();

        request.setBody(JSON.serialize(retrieveVetInfoRequest));

        return new Http().send(request);
    }

    /**
     * @description DTO capturing properties to be sent as the request body of vccMPIeVetRetrieveV3
     * @justification field names must match what the API is expecting
     */
    @SuppressWarnings('PMD.FieldNamingConventions')
    public class RetrieveVetInfoRQ {
        public String userId;
        public String id;
        public String idType;
        public Boolean unattended;
        public Boolean showCorrelated;
        public List<String> datasets = new List<String>();

        /**
         * @description checks the value of the attributes of this class for validity
         */
        public void isValid() {
            if (String.isBlank(this.id)) {
                throw new IllegalArgumentException('API request body required attribute "id" is null or blank');
            }
            if (String.isBlank(this.idType)) {
                throw new IllegalArgumentException('API request body required attribute "idType" is null or blank');
            }
        }
    }

    /**
     * @description Separated out of retrieveVetInfo, this method updates the PersonAccount record with data from MPI so that it is always up-to-date
     * @param accountId the `Id` of the account to update
     * @param responseDataString the MPI data to update the account from, as a JSON `String`
     */
    @AuraEnabled
    public static void deferredMPIUpdates(Id accountId, String responseDataString) {
        if (accountId == null || responseDataString == null) {
            throw new IllegalArgumentException(DEFERRED_MPI_UPDATE_NULL_ARG_MSG);
        }
        if (accountId.getSobjectType() != Account.getSObjectType()) {
            throw new IllegalArgumentException(DEFERRED_MPI_UPDATE_WRONG_ID_TYPE_MSG);
        }
        if (String.isBlank(responseDataString)) {
            throw new IllegalArgumentException(DEFERRED_MPI_UPDATE_BLANK_MPI_STRING_MSG);
        }
        VCC_MPIParser responseData = (VCC_MPIParser) JSON.deserialize(responseDataString, VCC_MPIParser.class);
        VCC_MPIHelper.updateAccountNameFromMpi(accountId, responseData?.vetsV3[0]?.mvi);
        VCC_MPIHelper.updateVAProfile(accountId, responseData.vetsV3[0].vaProfileV2);
        VCC_MPIHelper.updateESR(accountId, responseData.vetsV3[0].ee);
    }

    @TestVisible
    private static Map<String, String> getFacilityOverrideMCustomMetadata() {
        Map<String, String> facilityOverrides = new Map<String, String>();
        for (VCC_Facilities_Overwrite__mdt facilityToOverwrite : VCC_Facilities_Overwrite__mdt.getAll().values()) {
            facilityOverrides.put(facilityToOverwrite.Facility_Number__c, facilityToOverwrite.Name_to_Override__c);
        }
        return facilityOverrides;
    }

    /**
     * @description Get the name of the VA Medical Center Facilities based on their 3-digit Id (e.g. 983, 984, 512, etc.) and
     * optionally override them if a VCC_Facilities_Overwrite__mdt exists for that facility Id.
     * @param facilityListJson `List<VCC_MPIParser.MedicalCenterFacility>` but in JSON form
     * @return `List<VCC_MPIParser.MedicalCenterFacility>` but with updated names, in JSON form
     */
    @AuraEnabled(cacheable=true scope='Global')
    public static String getFacilityNames(String facilityListJson) {
        List<VCC_MPIParser.MedicalCenterFacility> facilityList = (List<VCC_MPIParser.MedicalCenterFacility>) JSON.deserialize(
            facilityListJson,
            List<VCC_MPIParser.MedicalCenterFacility>.class
        );
        VCC_MPIHelper.getFacilityNames(facilityList);
        Map<String, String> overrides = getFacilityOverrideMCustomMetadata();
        for (VCC_MPIParser.MedicalCenterFacility facility : facilityList) {
            if (overrides.containsKey(facility.facilityId)) {
                facility.facilityName = overrides.get(facility.facilityId);
            }
        }
        return JSON.serialize(facilityList);
    }

    /**
     * @description fetches a list of VistA instances the running user has access too from custom setting IAM_SSOi_Vista_Instance_to_User_DUZ__c.
     * IAM_SSOi_Vista_Instance_to_User_DUZ__c is updated each time the user signs in with SSO with their access.
     * @return `List<String>` the list of vista instances (3-digit site code ie. 983, 984, etc)
     */
    @AuraEnabled(cacheable=true)
    public static List<String> userVistAs() {
        List<String> vistAList = new List<String>();
        String userId = UserInfo.getUserId();
        for (
            IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaInstanceToUserDuzRecord : vistaInstanceToUserDuzRepo.fetchByUserId(
                userId
            )
        ) {
            vistAList.add(vistaInstanceToUserDuzRecord.VistA_Instance__c);
        }
        return vistAList;
    }
}
