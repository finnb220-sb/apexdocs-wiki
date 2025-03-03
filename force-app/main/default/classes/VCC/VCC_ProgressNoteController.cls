/**
 * @description Serves as a controller for Progress Note related LWC, Flow, Trigger, etc.
 * @author Patrick Skamarak
 * @since 08/10/2021
 * @group Object - VCC_Progress_Note__c
 */
public with sharing class VCC_ProgressNoteController {
    public static final Integer VISTA_BASE_YEAR = 1700;
    public static final String SERVICE_CATEGORY = 'T'; //HardCoding as T (possible vals: A, H, T, or E )
    /**
     * @description Singleton instance of VCR_IAMSSOiVistaInstToUserDUZRepo for SSOiVista to User DUZ mappings.
     */
    @TestVisible
    private static VCR_IAMSSOiVistaInstToUserDUZRepo iamSSOiVistaInstanceToUserDUZRepo {
        get {
            if (iamSSOiVistaInstanceToUserDUZRepo == null) {
                iamSSOiVistaInstanceToUserDUZRepo = new VCR_IAMSSOiVistaInstToUserDUZRepo();
            }
            return iamSSOiVistaInstanceToUserDUZRepo;
        }
        private set;
    }

    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    /**
     * @description instantiation of Progress Note repo
     */
    private static VCR_ProgressNoteRepo pNoteRepo {
        get {
            return pNoteRepo = pNoteRepo ?? new VCR_ProgressNoteRepo();
        }
        set;
    }

    @TestVisible
    /**
     * @description instantiation of VCR_HealthDataRepo repo
     */
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            return healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('ehr_progress_notes');
        }
        set;
    }

    @AuraEnabled(Cacheable=true)
    /**
     * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
     * @param icn - icn to query patient bday
     * @return `VCR_HealthDataRepo.Model` - Returns patient birthyear, and workstream settings
     */
    public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
        healthDataRepo.setPatientByICN(icn);
        return healthDataRepo.fetchHealthDataConfig();
    }

    /**
     * @description - Get Notes through VTC
     * @param args - Arguments for the Notes VTC call
     * @return VTC_DataModel - The data model containing the notes data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchNotes(Map<String, Object> args) {
        args.put('application', APPLICATION);
        try {
            return pNoteRepo.fetchNotes(args);
        } catch (Exception ex) {
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => 'RETRY_CMD',
                'VTC_CalloutException' => 'RETRY_CMD',
                'VTC_TimeoutException' => 'RETRY_CMD'
            };
            throw VCC_ExceptionUtils.createAuraHandledException(ex, cmdMap, 'NO_RETRY_CMD');
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description - Get Notes through VTC
     * @param args - Arguments for the Notes VTC call
     * @return VTC_DataModel - The data model containing the notes data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchDirectives(Map<String, Object> args) {
        args.put('application', APPLICATION);
        args.put('noteType', VTC_NoteType.ADVANCE_DIRECTIVE);
        try {
            return pNoteRepo.fetchDirectives(args);
        } catch (Exception ex) {
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => 'RETRY_CMD',
                'VTC_CalloutException' => 'RETRY_CMD',
                'VTC_TimeoutException' => 'RETRY_CMD'
            };
            throw VCC_ExceptionUtils.createAuraHandledException(ex, cmdMap, 'NO_RETRY_CMD');
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description prevent Progress Note delete if record is signed, or if the running user is not record owner
     * @param recs  list of progress notes
     */
    public static void preventProgressNoteDelete(List<VCC_Progress_Note__c> recs) {
        if (VCC_TrainingModeService.isTrainingModeEnabled()) {
            return;
        }

        for (VCC_Progress_Note__c pNote : recs) {
            // if Progress Note Signed checkbox = true, throw prevent delete error
            if (pNote.VCC_Signed__c) {
                // add error to prevent delete. Display custom label message.
                pNote.addError(System.Label.VCC_Prevent_Delete_Signed_Progress_Note);
            }
        }
    }
    /**
     * @description        Returns true if at least one Progress Note on a Case is not signed
     * @param caseRecordId The Id of the Case
     * @return             `Boolean`
     */
    @AuraEnabled
    public static Boolean unsignedProgressNotesOnCase(Id caseRecordId) {
        Boolean unsignedNote = false;
        List<VCC_Progress_Note__c> progressNoteList = [
            SELECT Id, VCC_Signed__c
            FROM VCC_Progress_Note__c
            WHERE VCC_Case__c = :caseRecordId
            WITH USER_MODE
        ];
        for (VCC_Progress_Note__c progNote : progressNoteList) {
            if (!progNote.VCC_Signed__c) {
                unsignedNote = true;
            }
        }
        return unsignedNote;
    }
    /**
     * @description    Returns the Id of the record type associated with the Progress Note
     * @param recordId The Id of the progress note record
     * @return         `Id`
     */
    @AuraEnabled
    public static Id getProgressNoteRecordTypeId(Id recordId) {
        String sObjectName = ((Id) recordId).getSobjectType().getDescribe(SObjectDescribeOptions.FULL).getName();

        Id recordTypeId;

        //whitelisting certain sobjects
        switch on (sObjectName) {
            when 'VCC_Progress_Note__c' {
                recordTypeId = [SELECT RecordTypeId FROM VCC_Progress_Note__c WHERE Id = :recordId WITH USER_MODE]
                .RecordTypeId;
            }
        }

        return recordTypeId;
    }
    /**
     * @description Creates VCC_Signers__c records and associates them to the Progress Note or Addendum.
     * @param progressNoteOrAddendum Id of the Progress Note or Addendum
     * @param providers A list of providers that will be used as signers for the Progress Note/Addendum
     */
    @AuraEnabled
    public static void createSigners(Id progressNoteOrAddendum, List<VCC_VDIFResponseParser.ProviderTO> providers) {
        String sObjectName = String.valueOf((progressNoteOrAddendum).getSobjectType());
        List<VCC_Signers__c> signersToInsert = new List<VCC_Signers__c>();

        for (VCC_VDIFResponseParser.ProviderTO provider : providers) {
            VCC_Signers__c signer = new VCC_Signers__c(
                VCC_DUZ__c = provider.duz,
                Name = (provider.providername),
                VCC_Title__c = provider.providertitle,
                VCC_Location__c = provider.loginSiteCode
            );
            switch on sObjectName {
                when 'VCC_Progress_Note__c' {
                    signer.VCC_Progress_Note__c = progressNoteOrAddendum;
                }
                when 'VCC_Addendum__c' {
                    signer.VCC_Addendum__c = progressNoteOrAddendum;
                }
            }
            signersToInsert.add(signer);
        }
        if (VCC_Signers__c.SObjectType.getDescribe(SObjectDescribeOptions.FULL).isCreateable()) {
            insert signersToInsert;
        }
    }
    public static String generateEncounterString(
        Integer locationIEN,
        Boolean isNoShowNoWelfare,
        Boolean isNoShowWithWelfare
    ) {
        Datetime now;
        if (Test.isRunningTest()) {
            now = Datetime.valueOf('2021-07-23 13:15:03');
        } else {
            now = Datetime.now();
        }

        String timeStamp = String.valueOf((now.year() - VISTA_BASE_YEAR)) + now.format('MMdd.HHmmss');
        String finalString;
        if (isNoShowNoWelfare || isNoShowWithWelfare) {
            finalString = locationIEN + ';' + timeStamp + ';' + 'E';
        } else {
            finalString = locationIEN + ';' + timeStamp + ';' + SERVICE_CATEGORY;
        }
        return finalString;
    }

    /**
     * @description Generates a Name by concatenating 'mockSSO', the UserId, and VistA instance.
     * @param primarySetting The custom setting containing the VistA instance.
     * @return `String` The Name in the format: `mockSSO.<UserId>_<VistA_Instance>`.
     */
    private static String generateMockSSOName(VCC_Mock_SSO_Settings__c primarySetting) {
        return 'mockSSO.' + UserInfo.getUserId() + '_' + primarySetting.VCC_VistA_Instance__c;
    }

    /**
     * @description Creates an IAM_SSOi_Vista_Instance_to_User_DUZ__c record for the user based on the current MOCK SSO setting, then returns the token.
     * This allows QA to test with users based upon an SSO token generated by our team. This token is stored in VCC_Mock_SSO_Settings__c and is returned through this
     * method when needed. The IAM_SSOi_Vista_Instance_to_User_DUZ__c record signifies the authorization to perform work for a specific VistA site (ex. 983, 984), and
     * the functionality of VA Health Connect will allow/dissallow them from performing certain actions based on the existence of this record. In production, this
     * record is created via a Registration Handler : IAM_SSOi_RegistrationHandler
     *
     * @justification Explicitly perform an unsafe insert or update (using SYSTEM_MODE) here due to Custom Settings not being
               updateable/insertable without the Customize Application permission which should not be granted to running persona.
     * @return      `String`
     */
    public static String mockSSO() {
        List<VCC_Mock_SSO_Settings__c> mockSettingsList;
        VCC_Mock_SSO_Settings__c userSetting;
        VCC_Mock_SSO_Settings__c profileSetting;
        VCC_Mock_SSO_Settings__c orgSetting;
        String token;

        mockSettingsList = [
            SELECT Id, SetupOwnerId, VCC_SSO_Token__c, VCC_VistA_Instance__c, VCC_DUZ__c
            FROM VCC_Mock_SSO_Settings__c
            WHERE
                SetupOwnerId = :UserInfo.getUserId()
                OR SetupOwnerId = :UserInfo.getProfileId()
                OR SetupOwnerId = :UserInfo.getOrganizationId()
            WITH USER_MODE
        ];

        if (mockSettingsList.size() > 0) {
            for (VCC_Mock_SSO_Settings__c mssos : mockSettingsList) {
                switch on VCC_lwc_utils.getObjectApiNameById(mssos.SetupOwnerId) {
                    when 'User' {
                        userSetting = mssos;
                    }
                    when 'Profile' {
                        profileSetting = mssos;
                    }
                    when 'Organization' {
                        orgSetting = mssos;
                    }
                }
            }

            //higher specificity takes priority user > profile > org
            VCC_Mock_SSO_Settings__c primarySetting;
            if (userSetting != null) {
                primarySetting = userSetting;
            } else if (profileSetting != null) {
                primarySetting = profileSetting;
            } else if (orgSetting != null) {
                primarySetting = orgSetting;
            }

            token = primarySetting.VCC_SSO_Token__c;

            String formattedMockSSOName = generateMockSSOName(primarySetting);

            IAM_SSOi_Vista_Instance_to_User_DUZ__c vistaInstanceToUserDUZ;
            try {
                vistaInstanceToUserDUZ = [
                    SELECT Id, DUZ__c, User_Id__c, VistA_Instance__c
                    FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c
                    WHERE User_Id__c = :UserInfo.getUserId() AND Name = :formattedMockSSOName
                    WITH USER_MODE
                    LIMIT 1
                ];
            } catch (Exception e) {
                Logger.error('ERROR MESSAGE::: ' + e);
                Logger.saveLog();
            }

            DescribeSObjectResult vitudDescribe = IAM_SSOi_Vista_Instance_to_User_DUZ__c.SObjectType.getDescribe(
                SObjectDescribeOptions.FULL
            );

            //creating mockSSO Vista_Instance_To_User_DUZ custom setting or updating existing
            if (vistaInstanceToUserDUZ == null) {
                if (vitudDescribe.isCustomSetting() && vitudDescribe.isAccessible()) {
                    vistaInstanceToUserDUZ = new IAM_SSOi_Vista_Instance_to_User_DUZ__c(
                        Name = formattedMockSSOName,
                        DUZ__c = primarySetting.VCC_DUZ__c,
                        VistA_Instance__c = primarySetting.VCC_VistA_Instance__c,
                        User_Id__c = UserInfo.getUserId()
                    );

                    //Explicitly doing an unsafe insert (SYSTEM_MODE) here due to Custom Settings not being
                    //insertable without the Customize Application permission
                    new VCR_IAMSSOiVistaInstToUserDUZRepo(true).performUnsafeInsert(vistaInstanceToUserDUZ);
                }
            } else {
                if (vitudDescribe.isCustomSetting() && vitudDescribe.isAccessible()) {
                    vistaInstanceToUserDUZ.DUZ__c = primarySetting.VCC_DUZ__c;
                    vistaInstanceToUserDUZ.VistA_Instance__c = primarySetting.VCC_VistA_Instance__c;
                    vistaInstanceToUserDUZ.Name = formattedMockSSOName;
                    //Explicitly doing an unsafe update (SYSTEM_MODE) here due to Custom Settings not being
                    // updateable without the Customize Application permission
                    new VCR_IAMSSOiVistaInstToUserDUZRepo(true).performUnsafeUpdate(vistaInstanceToUserDUZ);
                }
            }
        }
        return token;
    }
    /**
     * @description  The Sign Note Flow calls this method with an action name to execute different actions based on what step the user is on when signing a progress note
     * @param params An instance of the ActionParams object that contains several properties (including actionName) that are used in this method to perform business logic. Set and passed in by the VCC_Sign_Note_with_Callouts_2 flow
     * @return       `List<String>`
     * @exception ProgressNoteControllerException
     */
    @InvocableMethod(Category='Progress Note' Callout=true)
    public static List<String> progressNoteAction(List<ActionParams> params) {
        //creating these variables for easier code readability
        ActionParams param = params[0];
        VCC_Progress_Note__c pnRecord = param?.pnRecord;
        VCC_Addendum__c addendumRecord = param?.addendumRecord;
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams = param?.patientAndProviderParams;
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams = param?.noteAndEncounterParams;

        List<String> stringListToReturn = new List<String>();

        //to-do bulkify?? not sure if its needed since this is called from a screen flow
        if (params.size() == 1) {
            switch on param.actionName {
                when 'ValidateEsig' {
                    Boolean valid;
                    if (pnRecord != null) {
                        valid = VCC_ProviderService.validateEsig(
                            UserInfo.getUserId(),
                            patientAndProviderParams.providerLoginSiteCode,
                            patientAndProviderParams.eSig,
                            patientAndProviderParams.providerUserId,
                            pnRecord.Id
                        );
                    } else if (addendumRecord != null) {
                        valid = VCC_ProviderService.validateEsig(
                            UserInfo.getUserId(),
                            patientAndProviderParams.providerLoginSiteCode,
                            patientAndProviderParams.eSig,
                            patientAndProviderParams.providerUserId,
                            addendumRecord.Id
                        );
                    }
                    stringListToReturn.add((valid == true ? 'True' : 'False'));

                    if (valid == false) {
                        Logger.info('START ERROR:: Progress Note ID ==>' + pnRecord?.Id);

                        Logger.saveLog();
                    }
                }
                when 'WriteNote' {
                    Logger.info('Writing note to VDIF...');
                    Logger.saveLog();
                }
                when 'CreateEncounter' {
                    String encounterString;
                    if (pnRecord != null) {
                        encounterString = VCC_EncounterService.saveNoteAndEncounter(
                            noteAndEncounterParams,
                            patientAndProviderParams,
                            pnRecord.Id
                        );
                    } else if (addendumRecord != null) {
                        encounterString = VCC_EncounterService.saveNoteAndEncounter(
                            noteAndEncounterParams,
                            patientAndProviderParams,
                            addendumRecord.Id
                        );
                    }
                    stringListToReturn.add(encounterString);
                }
                when 'SignNote' {
                    VCC_VdifRSCommon.TextTO textTO;
                    if (pnRecord != null) {
                        textTO = VCC_NoteService.signNote(
                            noteAndEncounterParams,
                            patientAndProviderParams,
                            pnRecord.Id
                        );
                    } else if (addendumRecord != null) {
                        textTO = VCC_NoteService.signNote(
                            noteAndEncounterParams,
                            patientAndProviderParams,
                            addendumRecord.Id
                        );
                    }
                    stringListToReturn.add(textTO.text);
                }
                when 'GetNoteText' {
                    Logger.info('Converting note/addendum to JSON...');
                    Logger.saveLog();
                }
                when 'AddSigners' {
                    /* This condition is commented out for code coverage purposes. The VCC_Named_Toggle__mdt enables the searching of signers from custom object "VCC_Vista_User__c.
                    If there is ever an instance that we need to switch back to retrieving providers from the VDIFResponse, this code will have to be uncommented, and the VCC_State__c property will
                    have to be toggled to false on the New_Vista_User_Search mdt record.

                    if (VCC_Named_Toggle__mdt.getInstance('New_Vista_User_Search').VCC_State__c == false) {
                        if (noteAndEncounterParams.supplementalParameters != null && noteAndEncounterParams.supplementalParameters != '') {
                            List<VCC_VDIFResponseParser.ProviderTO> providers = (List<VCC_VDIFResponseParser.ProviderTO>) JSON.deserialize(
                                noteAndEncounterParams.supplementalParameters,
                                List<VCC_VDIFResponseParser.ProviderTO>.class
                            );

                            List<String> supParam = new List<String>();
                            for (VCC_VDIFResponseParser.ProviderTO provider : providers) {
                                supParam.add(provider.duz);
                            }
                            if (supParam.size() > 0) {
                                VCC_NoteService.addSigners(noteAndEncounterParams, patientAndProviderParams, supParam);
                            }
                            if (pnRecord != null) {
                                VCC_ProgressNoteController.createSigners(pnRecord.Id, providers);
                            } else if (addendumRecord != null) {
                                VCC_ProgressNoteController.createSigners(addendumRecord.Id, providers);
                            }
                        }
                    }*/
                    if (VCC_Named_Toggle__mdt.getInstance('New_Vista_User_Search').VCC_State__c == true) {
                        List<String> signerDuzList = VCC_SignersService.instance.getSignerDuzListForCallout(
                            (addendumRecord?.Id == null ? pnRecord?.Id : addendumRecord?.Id)
                        );

                        if (signerDuzList == null || signerDuzList.size() == 0) {
                            return null;
                        }
                        if (pnRecord != null) {
                            VCC_NoteService.addSigners(
                                noteAndEncounterParams,
                                patientAndProviderParams,
                                signerDuzList,
                                pnRecord.Id
                            );
                        } else if (addendumRecord != null) {
                            VCC_NoteService.addSigners(
                                noteAndEncounterParams,
                                patientAndProviderParams,
                                signerDuzList,
                                addendumRecord.Id
                            );
                        }
                    }
                }
                when 'CreateAddendum' {
                    Logger.info('Creating/writing addendum....');
                    Logger.saveLog();
                }
                when 'GetVisitRelatedTos' {
                    VCC_VdifSelectPatientRS.VisitRelatedTO visitrelatedTos;
                    if (pnRecord != null) {
                        visitrelatedTos = VCC_PatientService.getVisitRelatedTos(patientAndProviderParams, pnRecord.Id);
                    } else if (addendumRecord != null) {
                        visitrelatedTos = VCC_PatientService.getVisitRelatedTos(
                            patientAndProviderParams,
                            addendumRecord.Id
                        );
                    }
                    stringListToReturn.add(JSON.serialize(visitrelatedTos));
                }
                when 'GetEncounterString' {
                    if (
                        noteAndEncounterParams.noShowNoWelfare != null &&
                        noteAndEncounterParams.noShowWithWelfare != null
                    ) {
                        stringListToReturn.add(
                            generateEncounterString(
                                Integer.valueOf(noteAndEncounterParams.noteAndEncounterLocationIen),
                                noteAndEncounterParams.noShowNoWelfare,
                                noteAndEncounterParams.noShowWithWelfare
                            )
                        );
                    } else {
                        stringListToReturn.add(
                            generateEncounterString(
                                Integer.valueOf(noteAndEncounterParams.noteAndEncounterLocationIen),
                                false,
                                false
                            )
                        );
                    }
                }
                when 'GetAuthToken' {
                    String token;
                    Boolean mockSSO = true;
                    if (!Test.isRunningTest()) {
                        mockSSO = [
                            SELECT Id, Enable_SSO_Mocking__c
                            FROM VCC_Org_Settings__mdt
                            WHERE vccOrgId__c = :UserInfo.getOrganizationId()
                            WITH USER_MODE
                        ]
                        .Enable_SSO_Mocking__c;
                    }
                    if (mockSSO == true) {
                        token = VCC_ProgressNoteController.mockSSO();
                    } else if (mockSSO == false) {
                        token = IAM_SSOi_OAuthUtility.getVARefreshToken()[0];
                    }

                    stringListToReturn.add(token);
                }
                when else {
                    throw new ProgressNoteControllerException(
                        param.actionName + ' doesn\'t exist or has not been configured.'
                    );
                }
            }
        }
        return stringListToReturn;
    }
    /**
     * @description    This method returns the list of VCC_Call_Tracking__c records associated with the Progress Note.
     * @param recordId
     * @return         `List<VCC_Call_Tracking__c>`
     */
    @AuraEnabled(Cacheable=true)
    public static List<VCC_Call_Tracking__c> getCallTrackingList(String recordId) {
        VCR_CallTrackingRepo callTrackRepo = new VCR_CallTrackingRepo();
        return callTrackRepo.fetchCallTrackingList(recordId);
    }
    /**
     * @description Parameters are set by the VCC_Sign_Note_with_Callouts_2 flow, then passed into the progressNoteAction invocable method in this class. The actionName property determines which action the user is currently trying to accomplish
     * in the Sign Note flow, and the other properties hold information about the Progress Note, Patient, and Provider that are used to write the Progress Note to the external system (VistA, through Vdif middleware)
     */
    public class ActionParams {
        @InvocableVariable
        public String actionName;

        @InvocableVariable
        public VCC_Progress_Note__c pnRecord;

        @InvocableVariable
        public VCC_Addendum__c addendumRecord;

        @InvocableVariable
        public VCC_Vdif_PatientAndProviderParams patientAndProviderParams;

        @InvocableVariable
        public VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams;
    }

    class ProgressNoteControllerException extends Exception {
    }
}
