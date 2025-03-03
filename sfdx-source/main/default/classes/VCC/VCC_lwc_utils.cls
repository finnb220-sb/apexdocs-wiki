/**
 * @author Booz Allen
 * @since 9/2/2021
 * @description Class that holds apex methods to be used in LWC/Aura components
 * @group Helpers/Utilities
 */
public with sharing class VCC_lwc_utils {
    public static final String TYPE_SENSITIVE_PATIENT = 'SensitivePatient';
    public static final String TYPE_VERIFY_PATIENT = 'VerifyPatient';
    public static final String TYPE_IN_PATIENT = 'InPatient';
    public static final String TYPE_FACILITY_ACCESS = 'FacilityAccess';
    public static final String[] ACCEPTED_ADDRESS_ATTRS = new List<String>{
        'addressLine1',
        'addressLine2',
        'addressLine3',
        'city',
        'zipCode5',
        'zipCode4',
        'internationalPostalCode'
    };

    /**
     * @author Booz Allen
     * @since 9/2/2021
     * @description Exception placeholder
     */
    @TestVisible
    private class MpiException extends Exception {
    }

    /**
     * @author Booz Allen
     * @since 9/2/2021
     * @description Exception placeholder
     */
    @TestVisible
    private class VAHCException extends Exception {
    }

    /**
     * @description Get start date based on bridg service
     * @param bridgService - Set of recordids
     * @return string
     */
    @TestVisible
    private static String getStartDateBasedOnBridgService(String bridgService) {
        VCC_Workstream_Settings__mdt workstreamSettings = VCC_WorkstreamSettingsController.getWorkstreamSettings();
        switch on bridgService {
            when 'vccBridgNotes' {
                return String.valueOf(
                        Date.today().addMonths(-Integer.valueOf(workstreamSettings.VCC_EHR_Progress_Notes_Duration__c))
                    )
                    .substring(0, 10);
            }
            when 'vccBridgVitals' {
                return String.valueOf(
                        Date.today().addMonths(-Integer.valueOf(workstreamSettings.VCC_Vitals_Duration__c))
                    )
                    .substring(0, 10);
            }
            when 'vccBridgMeds' {
                return String.valueOf(Date.today().addMonths(-Integer.valueOf(workstreamSettings.VCC_Meds_Duration__c)))
                    .substring(0, 10);
            }
        }
        return String.valueOf(Date.today().addMonths(-4)).substring(0, 10);
    }

    /**
     * @description
     * @param recordId Id of current record
     * @param bridgService HDR service to call defaults to historical progress notes.
     * @param clientObject Salesforce Object the user is in, used to know which object to query icn against.
     * @param initialCallout Flag to determine if the request body generated is for an initial callout.
     * @return HDR response
     */
    @AuraEnabled
    public static string retrieveHDR(
        String recordId,
        String bridgService,
        String clientObject,
        Boolean initialCallout
    ) {
        String startDate = getStartDateBasedOnBridgService(bridgService);
        return retrieveHDRCallout(
            recordId,
            bridgService,
            clientObject,
            initialCallout,
            startDate,
            System.now().format('yyyy-MM-dd')
        );
    }

    /**
     * @description Retrieve HDR
     * @param recordId
     * @param bridgService
     * @param clientObject
     * @param initialCallout
     * @param startDate
     * @param stopDate
     * @return string
     */
    @AuraEnabled
    public static string retrieveHDRCallout(
        String recordId,
        String bridgService,
        String clientObject,
        Boolean initialCallout,
        String startDate,
        String stopDate
    ) {
        if (!bridgService.equalsIgnoreCase('vccBridgNotes')) {
            startDate = getStartDateBasedOnBridgService(bridgService);
        }

        // TODO: generate create
        try {
            /*
            // Training Mode short-circuit.
            if (bridgService.equalsIgnoreCase('vccBridgNotes') && VCC_TrainingModeService.isTrainingModeEnabled()) {
                String notesTrainingData = VCC_TrainingModeService.getProgressNotesByAccountId(recordId);
                return notesTrainingData;
            }*/
            HttpRequest request = new HttpRequest();

            request.setEndpoint(VCC_EndpointUtility.getEndpoint('Bridg', bridgService));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('apiKey', '{!$Credential.Password}');
            request.setTimeout(120000);

            HttpResponse resp;

            /**
             * Create request body dynamically depending on current object and service
             */

            request.setBody(
                VCC_HDRHelper.generateBRIDG(recordId, bridgService, clientObject, initialCallout, startDate, stopDate)
            );

            resp = (new Http()).send(request);
            String respBody = resp.getBody();
            switch on resp.getStatusCode() {
                when 500 {
                    // if limit exceeded, throw special error message for limiting date range
                    if (respBody.contains('Exceeded max size')) {
                        throw new VAHCException('Exceeded max size');
                    } else if (respBody.contains('Exceeded Max Records')) {
                        throw new VAHCException('Exceeded Max Records');
                    } else {
                        throw new VAHCException(resp.getBody());
                    }
                }
                when 200 {
                    /**
                     * Normalize response then return
                     */
                    return resp.getBody()
                        .replace('"null"', 'null')
                        .replace('"true"', 'true')
                        .replace('"false"', 'false');
                }
                when else {
                    throw new VAHCException(resp.getBody());
                }
            }
        } catch (Exception e) {
            throw new VAHCException(e.getMessage());
        }
    }

    //TODO: write back to VAProfile

    /**
     * @description
     * @param recordId
     * @param phone
     * @param type
     * @param create
     * @return  `string`
     * @exception
     */
    @AuraEnabled
    public static String vaProfileWritePhone(Id recordId, Map<String, Object> phone, String type, Boolean create) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIePostPhone'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);
            HttpResponse resp;

            Map<Id, Map<String, String>> patientIdMap = VCC_MPIHelper.getPatientParameters(recordId);

            request.setBody(
                JSON.serialize(
                    new Map<Object, Object>{
                        'areaCode' => phone.get('areaCode'),
                        'countryCode' => phone.get('countryCode'),
                        'effectiveDate' => Datetime.now(),
                        'effectiveEndDate' => phone.get('effectiveEndDate'),
                        'id' => (create == true
                            ? patientIdMap.get(recordId).get('vaid')
                            : patientIdMap.get(recordId).get('icn')),
                        'idType' => create == true ? 'salesforceId' : 'ICN',
                        'internationalIndicator' => phone.get('internationalIndicator'),
                        'phoneNumber' => phone.get('phoneNumber'),
                        'phoneType' => phone.get('phonetype'),
                        'sourceDate' => Datetime.now(),
                        'confirmationDate' => Datetime.now(),
                        'userId' => 'VAHC CRM',
                        'phoneNumberExt' => phone.get('phoneNumberExt')
                    }
                )
            );

            resp = (new Http()).send(request);
            if (resp.getStatusCode() != 200) {
                throw new VAHCException(resp.getBody());
            } else {
                return JSON.serialize(resp.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description
     * @param recordId
     * @param email
     * @param create
     *
     * @return
     */
    @AuraEnabled
    public static String vaProfileWriteEmail(Id recordId, String email, Boolean create) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIePostEmail'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);
            HttpResponse resp;

            Map<Id, Map<String, String>> patientIdMap = VCC_MPIHelper.getPatientParameters(recordId);

            request.setBody(
                JSON.serialize(
                    new Map<Object, Object>{
                        'effectiveDate' => Datetime.now(),
                        'confirmationDate' => Datetime.now(),
                        'emailAddressText' => email,
                        'id' => (create == true
                            ? patientIdMap.get(recordId).get('vaid')
                            : patientIdMap.get(recordId).get('icn')),
                        'idType' => create == true ? 'salesforceId' : 'ICN',
                        'userId' => 'VAHC CRM'
                    }
                )
            );

            resp = (new Http()).send(request);
            if (resp.getStatusCode() != 200) {
                throw new VAHCException(resp.getBody());
            } else {
                return JSON.serialize(resp.getBody());
            }
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    // this functionality was never used
    // a block of codes that was commented out was removed on 10/18/24

    /**
     * @description
     * @param recordId callout parameters
     * @param data callout parameters
     * @param type callout parameters
     * @param key callout parameters
     * @param create callout parameters
     * @return  `string` Response
     * @exception Aura
     */
    @AuraEnabled
    public static string vaProfileWriteAddress(
        Id recordId,
        Map<String, Object> data,
        String type,
        String key,
        Boolean create
    ) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vccMPIePostAddress'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);
            HttpResponse resp;

            Map<Id, Map<String, String>> patientIdMap = VCC_MPIHelper.getPatientParameters(recordId);

            request.setBody(
                JSON.serialize(
                    new Map<Object, Object>{
                        'addressLine1' => data.get('addressLine1'),
                        'addressLine2' => data.get('addressLine2'),
                        'addressLine3' => data.get('addressLine3'),
                        'addressPou' => type,
                        'cityName' => data.get('city'),
                        'countryCodeIso3' => data.get('country'),
                        'stateCode' => data.get('province'),
                        'zipCode5' => data.get('zipCode5'),
                        'zipCode4' => data.get('zipCode4'),
                        'userId' => 'VAHC CRM',
                        'effectiveDate' => Datetime.now(),
                        'confirmationDate' => Datetime.now(),
                        'overrideIndicator' => data.get('overrideIndicator'),
                        'validationKey' => key,
                        'id' => (create == true
                            ? patientIdMap.get(recordId).get('vaid')
                            : patientIdMap.get(recordId).get('icn')),
                        'idType' => create == true ? 'salesforceId' : 'ICN'
                    }
                )
            );

            resp = (new Http()).send(request);
            if (resp.getStatusCode() != 200) {
                throw new VAHCException(resp.getBody());
            } else {
                return JSON.serialize(resp.getBody());
            }
        } catch (Exception e) {
            throw new VAHCException(e.getMessage());
        }

        // /return JSON.serialize(data);
    }

    @AuraEnabled
    /**
     * @description
     * @param data consumed as an APEX base object
     * @param type CORRESPONDENCE (mailing) or RESIDENTIAL/CHOICE (residential)
     * @return AVS JSON response
     */
    public static string validateAddress(Map<String, Object> data, String type) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint('callout:vccAVS_qa');

            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('apiKey', '{!$Credential.Password}');
            request.setTimeout(120000);
            HttpResponse resp;

            Map<String, Object> reqAddress = new Map<String, Object>{
                'addressPOU' => type,
                'stateProvince' => new Map<Object, Object>{ 'code' => data.get('province') },
                'requestCountry' => new Map<Object, Object>{ 'countryCode' => data.get('country') }
            };
            if (data.containsKey('street')) {
                reqAddress.put('addressLine1', String.valueOf(data.get('street')).replace('\n', ''));
            }
            if (data.containsKey('postalCode')) {
                reqAddress.put('zipCode5', data.get('postalCode'));
            }
            for (String key : ACCEPTED_ADDRESS_ATTRS) {
                if (data.containsKey(key)) {
                    reqAddress.put(key, data.get(key));
                }
            }

            request.setBody(JSON.serialize(new Map<String, Object>{ 'requestAddress' => reqAddress }));

            resp = (new Http()).send(request);
            if (resp.getStatusCode() != 200) {
                throw new VAHCException(resp.getBody());
            } else {
                return JSON.serialize(resp.getBody());
            }
        } catch (Exception e) {
            throw new VAHCException(e.getMessage());
        }
    }

    /**
     * @description Gets historical progress notes from DIP BRIDG API
     * @param recordId the account `Id` from which the ICN is retrieved
     * @return `VCC_BaseResponseWrp` the JSON response from BRIDG
     */
    @AuraEnabled
    public static VCC_BaseResponseWrp getHistoricalProgressNotes(String recordId) {
        String externalId;
        String assigningAuth;
        String facility;
        //final String ENDPOINT = 'callout:vccBridg_qa/notes';
        final String endpoint = VCC_EndpointUtility.getEndpoint('Bridg', 'vccBridgNotes');

        // TODO: pass in record id and query external id

        VCC_BaseResponseWrp responseWrapper = new VCC_BaseResponseWrp();
        Account acct = [
            SELECT Id, Name, VCC_MVI_External_Id__pc
            FROM Account
            WHERE Id = :recordId
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        List<VCC_API_Setting__mdt> settings = [
            SELECT DeveloperName, VCC_AssigningAuthority__c, VCC_Assigning_Facility__c
            FROM VCC_API_Setting__mdt
            WHERE DeveloperName = 'VCC_Hist_PN_Config'
            WITH SECURITY_ENFORCED
            LIMIT 1
        ];

        if (acct.VCC_MVI_External_Id__pc == null) {
            responseWrapper.statusCode = 400;
            responseWrapper.responseBody = '{"error": "No VCC_MVI_External_Id__pc provided"}';
            return responseWrapper;
        }

        externalId = acct.VCC_MVI_External_Id__pc;
        assigningAuth = settings[0].VCC_AssigningAuthority__c;
        facility = settings[0].VCC_Assigning_Facility__c;

        try {
            HttpResponse response;

            HttpRequest request = new HttpRequest();
            request.setEndpoint(endpoint);
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('apiKey', '{!$Credential.Password}');
            request.setTimeout(120000);

            request.setBody(
                JSON.serialize(
                    new Map<Object, Object>{
                        'nationalId' => externalId,
                        'assigningAuthority' => assigningAuth,
                        'assigningFacility' => facility
                    }
                )
            );

            response = (new Http()).send(request);

            responseWrapper.responseBody = response.getBody();
            if (response.getStatusCode() != 200) {
                responseWrapper.statusCode = response.getStatusCode();
                responseWrapper.responseBody = '{"error": "No valid response returned form HDR"}';
                return responseWrapper;
            }
            responseWrapper.statusCode = response.getStatusCode();

            return responseWrapper;
        } catch (Exception e) {
            throw new AuraHandledException('ERROR IN VCC_lwc_utils\n' + e.getMessage());
        }
    }

    /**
     * @description
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static VCC_BaseResponseWrp callMpi(String recordId) {
        String userId;
        String icn;
        String idType;
        Boolean unattended;
        Boolean showCorrelated;
        String datasets;
        final String endpoint = 'callout:vccMPIe_qa/v0/vetRetrieve';

        VCC_BaseResponseWrp responseWrapper = new VCC_BaseResponseWrp();

        Account acct = (Account) VCC_LWCSObjectRepos.accountRepo.fetchById(
            recordId,
            new Set<String>{ 'Id', 'VCC_MVI_External_Id__pc' }
        );
        List<VCC_API_Setting__mdt> settings = new List<VCC_API_Setting__mdt>{
            VCC_API_Setting__mdt.getInstance('DIP_MPI')
        };
        if (acct.VCC_MVI_External_Id__pc == null) {
            responseWrapper.statusCode = 400;
            responseWrapper.responseBody = '{"error": "No VCC_MVI_External_Id__pc provided"}';
            return responseWrapper;
        }

        userId = settings[0].VCC_User_Id__c;
        icn = acct.VCC_MVI_External_Id__pc;
        idType = settings[0].VCC_Id_Type__c;
        unattended = settings[0].VCC_Unattended__c;
        showCorrelated = settings[0].VCC_Show_Correlated__c;
        datasets = settings[0].VCC_Datasets__c;

        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('clientid', '{!$Credential.UserName}');
        request.setHeader('clientSecret', '{!$Credential.Password}');
        request.setTimeout(120000);
        HttpResponse resp;

        request.setBody(
            JSON.serialize(
                new Map<Object, Object>{
                    'userId' => userId,
                    'id' => icn,
                    'idType' => idType,
                    'unattended' => unattended,
                    'showCorrelated' => showCorrelated,
                    'datasets' => new List<String>{ 'EE', 'VA_PROFILE' }
                }
            )
        );

        resp = (new Http()).send(request);

        if (resp.getStatusCode() != 200) {
            responseWrapper.statusCode = resp.getStatusCode();
            responseWrapper.responseBody = '{"error": "no successful response returned from MPI"}';

            return responseWrapper;
        }

        responseWrapper.statusCode = resp.getStatusCode();
        responseWrapper.responseBody = resp.getBody();

        // removed commented out code 10/21/2024

        return responseWrapper;
    }

    /**
     * @description
     * @param recordId
     *
     * @return
     */
    @AuraEnabled(cacheable=true)
    public static String getObjectApiNameById(Id recordId) {
        String name;
        try {
            name = ((Id) recordId).getSObjectType().getDescribe().getName();
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
        return name;
    }

    @AuraEnabled
    /**
     * @description call to acknowledge recent view for Sensitive Patient type.
     * @param recordId
     *
     * @return string
     */
    public static String acknowledgeSenstivePatient(String recordId) {
        // Sensitive Patient Popup

        //CCCM-21695
        VCC_RecentViewHelper.acknowledge(recordId, VCC_RecentViewHelper.TYPE_SENSITIVE_PATIENT);

        Map<String, Object> resp = new Map<String, Object>();
        resp.put('status', true);
        return JSON.serializePretty(resp);
    }

    /**
     * @description Upserts Associated Persons data
     * @param recordId callout parameters
     * @param data callout parameters
     * @param type callout parameters
     * @param nextofkinoremergencyconobj callout parameters
     * @return  `string` Response
     * @exception Aura
     * -------------------- DEPRECATED, DO NOT USE! SEE: VCC_VaProfileService ----------------------------------------
     */
    @AuraEnabled
    public static string vaProfileUpsertAssociatedPersons(
        Id recordId,
        Map<String, Object> data,
        String type,
        String nextofkinoremergencyconobj
    ) {
        Map<String, Object> actualReqData = (Map<String, Object>) JSON.deserializeUntyped(nextofkinoremergencyconobj);
        actualReqData.put('sourceDate', Datetime.now());
        actualReqData.put('updateDate', Datetime.now());

        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vaProfileUpsertAssociatedPersons'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('clientid', '{!$Credential.UserName}');
            request.setHeader('clientSecret', '{!$Credential.Password}');
            request.setTimeout(120000);
            HttpResponse resp;

            Map<Id, Map<String, String>> patientIdMap = VCC_MPIHelper.getPatientParameters(recordId);

            String reqBody = JSON.serialize(
                new Map<Object, Object>{
                    'userId' => 'acumen',
                    'id' => patientIdMap.get(recordId).get('icn'),
                    'idType' => 'ICN',
                    'vaProfileAssociatedPersons' => new List<Map<String, Object>>{ actualReqData }
                }
            );

            request.setBody(reqBody);

            resp = (new Http()).send(request);
            if (resp.getStatusCode() != 200) {
                throw new VAHCException(resp.getBody());
            } else {
                return JSON.serialize(resp.getBody());
            }
        } catch (Exception e) {
            throw new VAHCException(e.getStackTraceString());
        }
        // /return JSON.serialize(data);
    }

    /**
     * @description
     * @param recordId
     *
     * @return
     */
    @AuraEnabled
    public static String retrieveInPatientInfo(Id recordId) {
        try {
            HttpRequest request = new HttpRequest();
            request.setEndpoint(VCC_EndpointUtility.getEndpoint('Bridg', 'vccPatientMovement'));
            request.setMethod('POST');
            request.setHeader('Content-Type', 'application/json;charset=UTF-8');
            request.setHeader('apiKey', '{!$Credential.Password}');
            request.setTimeout(120000);

            Account acct = [
                SELECT Id, name, VCC_MVI_External_Id__pc
                FROM Account
                WHERE id = :recordId
                WITH SECURITY_ENFORCED
                LIMIT 1
            ];

            request.setBody(
                JSON.serialize(
                    new Map<Object, Object>{
                        //'assigningAuthority' => 'USVHA',
                        //'assigningFacility' => '578',
                        //'ien' => '100008',
                        'nationalId' => acct.VCC_MVI_External_Id__pc
                    }
                )
            );

            HttpResponse resp = (new Http()).send(request);

            if (resp.getStatusCode() != 200) {
                throw new MPIException(resp.getBody());
            }

            VCC_InpatientResWrp responseData = new VCC_InpatientResWrp();
            responseData.resBody = resp.getBody();

            return JSON.serialize(responseData);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    /**
     * @description call to acknowledge recent view for In Patient type.
     * @param recordId
     *
     * @return string
     */
    public static String acknowledgeInPatient(String recordId) {
        // Sensitive Patient Popup

        //CCCM-21695
        VCC_RecentViewHelper.acknowledge(recordId, VCC_RecentViewHelper.TYPE_IN_PATIENT);

        Map<String, Object> resp = new Map<String, Object>();
        resp.put('status', true);
        return JSON.serializePretty(resp);
    }

    // Facility Access Code
    @AuraEnabled
    /**
     * @description call to acknowledge recent view for Facility Access type.
     * @param recordId
     *
     * @return string
     */
    public static String acknowledgeFacilityAccess(String recordId) {
        //CCCM-21695
        VCC_RecentViewHelper.acknowledge(recordId, VCC_RecentViewHelper.TYPE_FACILITY_ACCESS);

        Map<String, Object> resp = new Map<String, Object>();
        resp.put('status', true);
        return JSON.serializePretty(resp);
    }

    /**
     * @description    Takes the ID of a record, checks for the sObjectType, and attempts to looks up the MPI/MVI ID via the VCC_MVI_External_Id__pc field depending on the sObjectType. Returns null if the record is not found, or the MVI field is blank.
     * @param recordId     A string containing the record ID for lookup
     * @return String      A string containing the MPI/MVI ID corresponding to the input recordId, or null if no corresponding MPI/MVI ID found
     */
    @AuraEnabled(cacheable=true)
    public static String getICN(String recordId) {
        if (String.isBlank(recordId)) {
            return null;
        }
        String mviId = null;
        Id thisId = (Id) recordId;

        switch on (thisId.getSobjectType().newSObject()) {
            when Account acc {
                Set<String> myAdditionalFields = new Set<String>{ 'VCC_MVI_External_Id__pc' };
                Account fetchedAccount = (Account) VCC_LWCSObjectRepos.accountRepo.fetchById(
                    recordId,
                    myAdditionalFields
                );
                mviId = fetchedAccount?.VCC_MVI_External_Id__pc;
            }
            when Contact con {
                Set<String> myAdditionalFields = new Set<String>{ 'VCC_MVI_External_Id__c' };
                Contact fetchedContact = (Contact) VCC_LWCSObjectRepos.contactRepo.fetchById(
                    recordId,
                    myAdditionalFields
                );
                mviId = fetchedContact?.VCC_MVI_External_Id__c;
            }
            when VCC_Progress_Note__c progNote {
                Set<String> myAdditionalFields = new Set<String>{ 'VCC_Case__r.Contact.VCC_MVI_External_Id__c' };
                VCC_Progress_Note__c fetchedProgressNote = (VCC_Progress_Note__c) VCC_LWCSObjectRepos.progressNoteRepo.fetchById(
                    recordId,
                    myAdditionalFields
                );
                mviId = fetchedProgressNote?.VCC_Case__r.Contact.VCC_MVI_External_Id__c;
            }
            when Case cse {
                Set<String> myAdditionalFields = new Set<String>{ 'Contact.VCC_MVI_External_Id__c' };
                Case fetchedCase = (Case) VCC_LWCSObjectRepos.caseRepo.fetchById(recordId, myAdditionalFields);
                mviId = fetchedCase?.Contact.VCC_MVI_External_Id__c;
            }
            when Task tsk {
                Task fetchedTask = (Task) VCC_LWCSObjectRepos.taskRepo.fetchById(recordId);
                Id conId = fetchedTask?.WhoId;
                Set<String> myAdditionalFields = new Set<String>{ 'VCC_MVI_External_Id__c' };
                Contact fetchedContact = (Contact) VCC_LWCSObjectRepos.contactRepo.fetchById(conId, myAdditionalFields);
                mviId = fetchedContact?.VCC_MVI_External_Id__c;
            }
        }
        return mviId;
    }
}
