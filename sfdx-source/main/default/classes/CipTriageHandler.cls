public class CipTriageHandler {
    @AuraEnabled
    public static ResponseWrap mpiPatientSearch(String reqBody) {
        system.debug('reqBody: ' + reqBody);
        // Make the callout to MPI
        Http http = new Http();
        HttpRequest request = buildHttpRequest('callout:DIP_MPI_nc/mpiSearch');
        request.setBody(reqBody);
        HttpResponse response = http.send(request);
        system.debug('reponse ' + response.getBody());
        system.debug('response error type ' + response.getStatus());

        // Put the response data in a Map
        Map<String, Object> responseBodyMap = new Map<String, Object>((Map<String, Object>) JSON.deserializeUntyped(response.getBody()));
        system.debug('responseBodyMap ' + responseBodyMap);
        ResponseWrap respWrap;
        String errorType;

        if (response.getStatusCode() == 200) {
            list<Object> vetList = new List<Object>((list<Object>) responseBodyMap.get('vets'));
            map<String, Object> vetMap = new Map<String, Object>((map<String, Object>) vetList[0]);
            system.debug('vetMap ' + vetMap);
            List<Object> medicalCenterFacilitiesList = (List<Object>) vetMap.get('medicalCenterFacilities');
            String vetString;
            Boolean existingPatient;
            if (medicalCenterFacilitiesList.size() > 0) {
                // Call the patientLocalPid to check if the patient has been to the location before
                existingPatient = String.IsNotBlank(getPatientLocalPid(medicalCenterFacilitiesList));

                if (existingPatient == true) {
                    //format the date of birth from YYYYMMDD to MM-DD-YYYY
                    String dob = String.ValueOf(vetMap.get('dob'));
                    String formattedDob = dob.subString(4, 6) + '-' + dob.subString(6, 8) + '-' + dob.subString(0, 4);
                    // Write the new formatted DOB back to the same map
                    vetMap.put('dob', formattedDob);
                    vetList.clear();
                    vetList.add(vetMap);
                    responseBodyMap.put('vets', vetList);
                    // Convert the map back to a String to pass it to the ResponseWrap wrapper class
                    vetString = JSON.serialize(responseBodyMap);
                }
                // If patient have never been to the facility
                else {
                    // Set the error type to PatientNewToClinic
                    errorType = 'PatientNewToClinic';
                }
            }
            // If patient does not have any medicalCenterFacilities pair values from MPI search
            else {
                // Set the error type to PatientHasNoClinic
                errorType = 'PatientHasNoClinic';
            }

            system.debug('vetString ' + vetString);
            respWrap = new ResponseWrap(String.valueOf(response.getStatusCode()), vetString, errorType);
            return respWrap;
        }
        // If the callout fails, pass the errorType to the wrapper class along with the other response's info
        else {
            errorType = String.valueOf(responseBodyMap.get('errorType'));
            respWrap = new ResponseWrap(String.valueOf(response.getStatusCode()), response.getBody(), errorType);
            system.debug('respWrap: ' + respWrap);
            return respWrap;
        }
    }

    // Wrapper class for MPI response which is passed back to the cipSearch component
    public class ResponseWrap {
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String body { get; set; }
        @AuraEnabled
        public String errorType { get; set; }

        public ResponseWrap(String s, String b, String et) {
            status = s;
            body = b;
            errorType = et;
        }
    }

    @AuraEnabled
    public static String createTriage(String vetSelect, String triageStatus) {
        system.debug('vetSelect ' + vetSelect);
        //deserialize the JSON passed when a patient is selected after patient search
        Map<String, Object> vetMap = (Map<String, Object>) JSON.deserializeUntyped(vetSelect);

        // get demographic data about the patient
        String genderVal = String.valueOf(vetMap.get('gender'));
        String gender = genderVal == 'M' ? 'Male' : genderVal == 'F' ? 'Female' : null;

        String ssn = String.valueOf(vetMap.get('ssn'));
        String ssn4 = ssn.right(4);

        String dateStr =
            String.valueOf(vetMap.get('dob')).subString(6, 10) +
            '-' +
            String.valueOf(vetMap.get('dob')).subString(0, 2) +
            '-' +
            String.valueOf(vetMap.get('dob')).subString(3, 5);
        Date Date_of_Birth = date.valueOf(dateStr);

        // get the medical center facilities from the previous map
        List<Object> medicalCenterFacilitiesList = (List<Object>) vetMap.get('medicalCenterFacilities');
        String medicalCenterFacilitiesArray = String.valueOf(vetMap.get('medicalCenterFacilities'));
        String PatientLocalPid = getPatientLocalPid(medicalCenterFacilitiesList);
        CIP_UserAttribute__c userAttribute = [SELECT Id, localSiteId__c FROM CIP_UserAttribute__c WHERE User__c = :userInfo.getUserId()];
        String facilityId = userAttribute.localSiteId__c;
        String patientMessage;

        // Create the triage record
        Triage__c tri = new Triage__c(
            First_Name__c = String.valueOf(vetMap.get('firstName')),
            Last_Name__c = String.valueOf(vetMap.get('lastName')),
            Gender__c = gender,
            Date_of_Birth__c = Date_of_Birth,
            Triage_Status__c = triageStatus,
            Check_In_Date_Time__c = DateTime.now(),
            SSN__c = ssn,
            Last_4_SSN__c = ssn4,
            Patient_Local_Pid__c = PatientLocalPid,
            Facility_Id__c = facilityId,
            MPI_Medical_Center_Facilities_List__c = medicalCenterFacilitiesArray
        );

        insert tri;
        system.debug('triage record ' + tri);
        // Format the current day and time from YYYYMMDD to MM-dd-yyyy hh:mm:ss
        String checkInTimeToReturn = DateTime.now().format('MM-dd-yyyy hh:mm:ss');
        // Build a new map to use with the new formatted current date and pass it back to the cipSearch component
        Map<String, Object> triMap = new Map<String, Object>{
            'Id' => tri.Id,
            'FirstName' => tri.First_Name__c,
            'LastName' => tri.Last_Name__c,
            'Last4SSN' => tri.Last_4_SSN__c,
            'DateOfBirth' => String.valueOf(vetMap.get('dob')),
            'Gender' => tri.Gender__c,
            'TriageStatus' => tri.Triage_Status__c,
            'CheckInDateTime' => checkInTimeToReturn
        };
        system.debug('triMap ' + triMap);
        // try {

        // } catch (Exception e) {
        //     throw new AuraHandledException(e.getMessage());
        // }
        system.debug('triage record ' + JSON.serialize(triMap));
        // Serialize the map into a String and return it
        return JSON.serialize(triMap);
    }

    private static String getPatientLocalPid(List<Object> medicalCenterFacilitiesList) {
        List<CIP_UserAttribute__c> localSites = [SELECT id, User__c, localSiteId__c FROM CIP_UserAttribute__c WHERE User__c = :userInfo.getUserId()];
        String patientLocalPid;
        if (!localSites.isEmpty()) {
            String localSiteId = localSites[0].localSiteId__c;
            for (integer i = 0; i < medicalCenterFacilitiesList.size(); i++) {
                map<String, Object> currentMedicalCenterFacility = new Map<String, Object>((map<String, Object>) medicalCenterFacilitiesList[i]);
                system.debug('currentMedicalCenterFacility ' + currentMedicalCenterFacility);
                if (String.valueOf(currentMedicalCenterFacility.get('facilityId')) == localSiteId) {
                    patientLocalPid = String.valueOf(currentMedicalCenterFacility.get('personId'));
                    break;
                }
            }
        }
        return patientLocalPid;
    }

    @AuraEnabled
    public static PatientMessagesResponseWrap patientFlagMessages(String triageId) {
        system.debug('Triage Id ' + triageId);
        triage__c tri = [
            SELECT Id, Patient_Flag__c, Patient_Message__c, Patient_Messages_Call_Made_Before__c, Facility_Id__c, Patient_Local_Pid__c
            FROM Triage__c
            WHERE Id = :triageId
        ];
        System.debug('Patient messages ' + tri.Patient_Message__c);
        System.debug('Patient flag ' + tri.Patient_Flag__c);

        String patientMessage = '';
        // if the Patient_Message__c field has no data and no callout was made before to get the messages
        if (String.isBlank(tri.Patient_Message__c) && tri.Patient_Messages_Call_Made_Before__c == false) {
            //Call VDIF to get the patient flag message and store it in the triage record

            HttpResponse response = makeVdifCallout('callout:DIP_VDIF_nc/vdifSelectPatient', tri.Facility_Id__c, tri.Patient_Local_Pid__c);

            system.debug('response status ' + response.getStatusCode());
            system.debug('Patient flag ' + response.getBody());

            if (response.getStatusCode() == 200) {
                //traverse the data structure to get to the patient flag list
                Map<String, Object> patientFlagsMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                system.debug(patientFlagsMap);
                map<String, Object> patientToMap = new Map<String, Object>((map<String, Object>) patientFlagsMap.get('patientTO'));
                system.debug(patientToMap);
                //If the patient has flag messages
                if (patientToMap.containsKey('patientFlags')) {
                    map<String, Object> patientFlagMap = new Map<String, Object>((map<String, Object>) patientToMap.get('patientFlags'));
                    system.debug('patient flag map ' + patientFlagMap);
                    if (patientFlagMap.containsKey('results')) {
                        map<String, Object> resultsMap = new Map<String, Object>((map<String, Object>) patientFlagMap.get('results'));
                        system.debug(resultsMap);
                        list<Object> taggedTextList = new List<Object>((list<Object>) resultsMap.get('taggedText'));
                        system.debug(taggedTextList);
                        // Loop through the patient flag list for the patient and format the text to show in the triage record page
                        for (Object obj : taggedTextList) {
                            Map<String, Object> patientMessagesMap = new Map<String, Object>((Map<String, Object>) obj);
                            String tag = String.valueOf(patientMessagesMap.get('tag'));
                            String text = String.valueOf(patientMessagesMap.get('text'));
                            String flagLine = tag + ': ' + text + '\n';
                            if (String.isNotBlank(patientMessage)) {
                                patientMessage += flagLine;
                            } else {
                                patientMessage = flagLine;
                            }
                            system.debug('list of patient flags ' + patientMessage);
                            tri.Patient_Message__c = patientMessage;
                            tri.Patient_Flag__c = true;
                            tri.Patient_Messages_Call_Made_Before__c = true;
                        }
                    }
                    // if patient has no flag messages
                    else {
                        tri.Patient_Message__c = '';
                        tri.Patient_Flag__c = false;
                        tri.Patient_Messages_Call_Made_Before__c = true;
                    }
                    update tri;
                }
                PatientMessagesResponseWrap PatientMessagesRespWrap = new PatientMessagesResponseWrap(String.valueOf(response.getStatusCode()), patientMessage);
                system.debug('PatientMessagesResponseWrap 200:' + PatientMessagesRespWrap);
                return PatientMessagesRespWrap;
            } else {
                PatientMessagesResponseWrap failedMessagesRespWrap = new PatientMessagesResponseWrap(String.valueOf(response.getStatusCode()), String.valueOf(response.getBody()));
                system.debug('FailedMessagesResponseWrap NOT 200:' + failedMessagesRespWrap);
                return failedMessagesRespWrap;
            }
        }
        // if a callout was made before to get the messages
        else {
            PatientMessagesResponseWrap PatientMessagesRespWrap = new PatientMessagesResponseWrap('200', tri.Patient_Message__c);
            system.debug('PatientMessagesResponseWrap Previous success call:' + PatientMessagesRespWrap);
            return PatientMessagesRespWrap;
        }
        //return null;
    }
    //wrapper class used to pass the flag messages to the cipFlag component
    public class PatientMessagesResponseWrap {
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public String patientMessage { get; set; }

        //This is the contructor method.
        public PatientMessagesResponseWrap(String s, String pm) {
            status = s;
            patientMessage = pm;
        }
    }

    @AuraEnabled //(cacheable=true)
    public static VitalsResponseWrap historicVitals(String triageId) {
        //Check if the historic vitals field has the vitals data, if so get that data from there otherwise
        //make the callout and populate the field
        system.debug('Triage Id ' + triageId);
        triage__c tri = [SELECT Id, Patient_Vitals__c, Patient_Has_No_Vitals__c, Facility_Id__c, Patient_Local_Pid__c FROM Triage__c WHERE Id = :triageId];
        System.debug('Patient Vitals ' + tri.Patient_Vitals__c);
        List<Map<String, String>> vitalsMapList = new List<Map<String, String>>();
        // if the Patient_Vitals__c field has no data and the callout was NOT previously made to VDIF, make the callout
        if (String.isBlank(tri.Patient_Vitals__c) && tri.Patient_Has_No_Vitals__c == false) {
            HttpResponse response = makeVdifCallout('callout:DIP_VDIF_nc/vdifGetVitalSigns', tri.Facility_Id__c, tri.Patient_Local_Pid__c);
            System.debug('vdifGetVitalSigns response ' + response.getBody());

            //List<Map<String, String>>vitalsMapList = new List<Map<String, String>>();
            if (response.getStatusCode() == 200) {
                // Call the vitalsSearchJSONWrapper wrapper class to deserialize the reponse
                vitalsSearchJSONWrapper vitalsrespWrap = (vitalsSearchJSONWrapper) JSON.deserialize(response.getBody(), vitalsSearchJSONWrapper.class);
                System.debug('vitalsrespWrap ' + vitalsrespWrap);

                Integer i;
                Integer vitalSignSetToSize = vitalsrespWrap.TaggedVitalSignSetArrays.arrays.taggedVitalSignSetArray[0].vitals.vitalSignSetTO.size() > 5
                    ? 5
                    : vitalsrespWrap.TaggedVitalSignSetArrays.arrays.taggedVitalSignSetArray[0].vitals.vitalSignSetTO.size();
                for (i = 0; i < vitalSignSetToSize; i++) {
                    Map<String, String> vitalsValuesMap = new Map<String, String>();
                    // Get the timestamp for the vital
                    String vitalDate = vitalsrespWrap.TaggedVitalSignSetArrays.arrays.taggedVitalSignSetArray[0].vitals.vitalSignSetTO[i].timestamp;
                    String formattedVitalDate = vitalDate.subString(0, 4) + '-' + vitalDate.subString(4, 6) + '-' + vitalDate.subString(6, 8);
                    // Check if the vital date is less than 5 year old, if not skip that vital
                    CIP_Settings__c setting = CIP_Settings__c.getValues('cipsit');
                    Integer numberOfYears = integer.valueOf(setting.VitalSearchNumberOfYears__c) != null ? integer.valueOf(setting.VitalSearchNumberOfYears__c) : null;

                    if (date.valueOf(formattedVitalDate) < (date.today() - (numberOfYears * 365))) {
                        continue;
                    } else {
                        String finalFormattedDate = vitalDate.subString(4, 6) + '-' + vitalDate.subString(6, 8) + '-' + vitalDate.subString(0, 4);
                        vitalsValuesMap.put('TimeStamp', finalFormattedDate);
                    }
                    //Loop through the vitalSignTO list from the response and fetch the relevant fields for the vitals
                    Integer j;
                    for (j = 0; j < vitalsrespWrap.TaggedVitalSignSetArrays.arrays.taggedVitalSignSetArray[0].vitals.vitalSignSetTO[i].vitals.vitalSignTO.size(); j++) {
                        String vitalName = vitalsrespWrap.TaggedVitalSignSetArrays.arrays.taggedVitalSignSetArray[0].vitals.vitalSignSetTO[i].vitals.vitalSignTO[j].type?.name;
                        String vitalValue = vitalsrespWrap.TaggedVitalSignSetArrays.arrays.taggedVitalSignSetArray[0].vitals.vitalSignSetTO[i].vitals.vitalSignTO[j]?.value1;
                        if (!String.isBlank(vitalName)) {
                            vitalsValuesMap.put(vitalName, vitalValue);
                        } else {
                            continue;
                        }
                    }
                    // Construct a map with all the relevant data for the vitals
                    Map<String, String> vitalsMap = new Map<String, String>();
                    vitalsMap.put('date', vitalsValuesMap.get('TimeStamp'));
                    vitalsMap.put('temp', vitalsValuesMap.get('TEMPERATURE'));
                    vitalsMap.put('bp', vitalsValuesMap.get('BLOOD PRESSURE'));
                    vitalsMap.put('pulse', vitalsValuesMap.get('PULSE'));
                    vitalsMap.put('resp', vitalsValuesMap.get('RESPIRATION'));
                    vitalsMap.put('lbs', vitalsValuesMap.get('WEIGHT'));
                    vitalsMapList.add(vitalsMap);
                }
                System.debug('vitalsMapList ' + vitalsMapList);

                System.debug('vitalsMapList ' + vitalsMapList);
                //Put the map in the VitalsResponseWrap wrapper class and pass that wrapper back as a return type
                VitalsResponseWrap finalVitalsRespWrap = new VitalsResponseWrap(String.valueOf(response.getStatusCode()), vitalsMapList);
                system.debug('Response Wrap ' + finalVitalsRespWrap);
                //if the vitalsMapList is not empty, populate the fields, so that vitals are available on the triage record in the future
                if (!vitalsMapList.isEmpty()) {
                    //tri.Patient_Vitals__c = String.valueOf(vitalsMapList);
                    tri.Patient_Vitals__c = JSON.serialize(vitalsMapList);
                    tri.Patient_Has_No_Vitals__c = false;
                } else {
                    tri.Patient_Has_No_Vitals__c = true;
                }
                update tri;
                system.debug('finalVitalsRespWrap ' + finalVitalsRespWrap);
                return finalVitalsRespWrap;
            } else {
                VitalsResponseWrap failedvitalsRespWrap = new VitalsResponseWrap(String.valueOf(response.getStatusCode()), vitalsMapList);
                system.debug('Response Wrap for failed callout' + failedvitalsRespWrap);
                return failedvitalsRespWrap;
            }
        }
        // if Patient_Vitals__c field has no data and a call to VDIF has been made in the past to get the vitals
        // but nothing was returned or vitals older than one year
        else if (String.isBlank(tri.Patient_Vitals__c) && tri.Patient_Has_No_Vitals__c == true) {
            VitalsResponseWrap vitalsRespWrap = new VitalsResponseWrap('200', vitalsMapList);
            system.debug('Response Wrap ' + vitalsRespWrap);
            return vitalsRespWrap;
        }
        // if Patient_Vitals__c field has data and a call to VDIF has been made in the past to get the vitals
        else if (String.isNotBlank(tri.Patient_Vitals__c)) {
            for (Object vital : (List<Object>) JSON.deserializeUntyped(tri.Patient_Vitals__c)) {
                Map<String, Object> ObjectVitalsMap = new Map<String, Object>((Map<String, Object>) vital);
                Map<String, String> vitalsMap = new Map<String, String>();
                vitalsMap.put('date', String.valueOf(ObjectVitalsMap.get('date')));
                vitalsMap.put('temp', String.valueOf(ObjectVitalsMap.get('temp')));
                vitalsMap.put('bp', String.valueOf(ObjectVitalsMap.get('bp')));
                vitalsMap.put('pulse', String.valueOf(ObjectVitalsMap.get('pulse')));
                vitalsMap.put('resp', String.valueOf(ObjectVitalsMap.get('resp')));
                vitalsMap.put('lbs', String.valueOf(ObjectVitalsMap.get('lbs')));
                vitalsMapList.add(vitalsMap);
            }
            VitalsResponseWrap vitalsRespWrap = new VitalsResponseWrap('200', vitalsMapList);
            system.debug('Response Wrap ' + vitalsRespWrap);
            return vitalsRespWrap;
        }
        System.debug('tri.Patient_Has_No_Vitals__c ' + tri.Patient_Has_No_Vitals__c);
        return null;
    }

    // Wrapper class used to pass the response back to the cipHistoricVitals component
    public class VitalsResponseWrap {
        @AuraEnabled
        public String status { get; set; }
        @AuraEnabled
        public List<Map<String, String>> vitalsBody { get; set; }

        public VitalsResponseWrap(String s, List<Map<String, String>> vb) {
            status = s;
            vitalsBody = vb;
        }
    }

    @AuraEnabled
    public static String buildNote(Triage__c tri) {
        String modeOfArrival = triage__c.Mode_of_Arrival__c.getDescribe().getLabel() + '\n' + '\t' + tri.Mode_of_Arrival__c;
        String accompaniedBy = triage__c.Accompanied_By__c.getDescribe().getLabel() + '\n' + '\t' + tri.Accompanied_By__c;
        String reasonForVisit = triage__c.Reason_for_Visit__c.getDescribe().getLabel() + '\n' + '\t' + tri.Reason_for_Visit__c;
        String nurseNotes = triage__c.Nurse_Notes__c.getDescribe().getLabel() + '\n' + '\t' + tri.Nurse_Notes__c;
        String patientResponse = triage__c.Response__c.getDescribe().getLabel() + '\n' + '\t' + tri.Response__c;
        String reasonForTriageClassUpdate = triage__c.Reason__c.getDescribe().getLabel() + '\n' + '\t' + tri.Reason__c;

        // Removing the screening questions responses from the note for now
        /*
        String mentalHealthScreening = 'Has veteran had mental health screening?' + '\n' + '\t' + tri.Mental_Health_Screening__c ;
        String outsideUs30Days = 'Has veteran traveled outside of the US in the last 30 days?' + '\n' + '\t' + tri.Outside_US_30_Days__c;
        String signOfAbuse = 'Does veteran show any signs of abuse?' + '\n' + '\t' + tri.Signs_of_Abuse__c;
        String feelSafe = 'Does veteran feel safe in current living conditions?' + '\n' + '\t' + tri.Feels_Safe__c;
        String suicidalIdeation =  'Suicidal or homicidal ideation in the last 2 weeks?' + '\n' + '\t' + tri.Suicidal_Homicidal__c;
        */
        String note = parseNoteText(
            '\n' +
                nurseNotes +
                '\n' +
                '\n' +
                tri.TXC_Results__c +
                '\n' +
                '\n' +
                reasonForVisit +
                '\n' +
                '\n' +
                modeOfArrival +
                '\n' +
                '\n' +
                accompaniedBy +
                '\n' +
                '\n' +
                reasonForTriageClassUpdate +
                '\n' +
                '\n' +
                /* mentalHealthScreening + '\n' + '\n' + outsideUs30Days + '\n' + '\n' + signOfAbuse + '\n' + '\n' + feelSafe + '\n' + '\n' + suicidalIdeation + '\n' + '\n' +*/ patientResponse
        );
        return note;
    }

    @InvocableMethod(label='Write Note')
    public static List<String> writeNote(List<triage__c> triage) {
        List<String> noteIdList = new List<String>();
        String error;

        //verify the list is not empty
        if (!triage.isEmpty() && triage.size() == 1) {
            Triage__c tri = triage[0];

            // Build the note body here. We might have to use | for single line breaks
            // and || for double line breaks instead of '\n'
            String note = buildNote(tri);

            //Get the encounterString from calling SaveNoteAndEncounter
            String encounterString = tri.Encounter_String__c == null ? getEncounterString(tri) : tri.Encounter_String__c;
            //String encounterString = '631;3210617.123000;E';
            System.debug('encounter String passed ' + encounterString);

            if (String.isBlank(encounterString)) {
                error = 'calloutFailed';
                noteIdList.add(error);
                return noteIdList;
            }

            String titleIEN = tri.Progress_Note__c;
            String noteId;

            HttpResponse response = makeVdifCalloutToWriteNote('callout:DIP_VDIF_nc/vdifWriteNote', tri.Facility_Id__c, tri.Patient_Local_Pid__c, note, encounterString, titleIEN);
            //If the callout is successful, get the id returned from the response and add it to a list to be passed back to the flow
            if (response.getStatusCode() == 200) {
                system.debug('response from write note ' + response.getBody());
                Map<String, Object> noteResultTOMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
                Map<String, Object> noteResponseMap = (Map<String, Object>) noteResultTOMap.get('noteResultTO');
                noteId = String.ValueOf(noteResponseMap?.get('id'));
                noteIdList.add(noteId);
                //Update the fields on the Triage record with the encounter string, noteid, note, triage status, note written flag
                tri.Encounter_String__c = encounterString;
                tri.Note_Written__c = true;
                tri.Nurses_Note_Id__c = noteId;
                tri.Triage_Status__c = 'Note Submitted';
                tri.Submitted_Note__c = note;
                update tri;
            } else {
                error = 'calloutFailed';
                noteIdList.add(error);
                tri.Encounter_String__c = encounterString;
                update tri;
            }
            // return the id from the response back to the flow
            // return noteIdList;
        } else {
            error = 'NoTriageRecordPassed';
            noteIdList.add(error);
        }
        return noteIdList;
    }

    public class writeNoteResult {
        @InvocableVariable
        public List<String> noteIdList;
    }

    // TODO: Method used to get the encounterString from vdifSaveNoteAndEncounter
    @testVisible
    private static String getEncounterString(triage__c tri) {
        String titleIEN = tri.Progress_Note__c;
        String locationIEN = tri.Location__c;

        Map<Id, IAM_SSOi_Vista_Instance_to_User_DUZ__c> duzMap;
        // Get Site ID from User attribute object
        List<CIP_UserAttribute__c> userAttributes = [SELECT Id, localSiteId__c FROM CIP_UserAttribute__c WHERE User__c = :UserInfo.getUserId()];
        if (!userAttributes.isEmpty()) {
            // Get DUZ code for the logged in user from custom setting - VCC_Vista_Instance_to_User_DUZ__c
            duzMap = new Map<Id, IAM_SSOi_Vista_Instance_to_User_DUZ__c>(
                [SELECT Id, DUZ__c FROM IAM_SSOi_Vista_Instance_to_User_DUZ__c WHERE User_Id__c = :UserInfo.getUserId() AND VistA_Instance__c = :userAttributes[0].localSiteId__c]
            );
        }

        String emDuzCode = duzMap.isEmpty() ? tri.E_M_Code__c : tri.E_M_Code__c + '^^^' + duzMap.values()[0].DUZ__c;
        //Call VDIF to get the encounterString
        HttpResponse response = makeVdifCalloutToSaveNoteAndEncounter(
            'callout:DIP_VDIF_nc/vdifSaveNoteAndEncounter',
            tri.First_Name__c + ' ' + tri.Last_Name__c,
            tri.Facility_Id__c,
            tri.Patient_Local_Pid__c,
            locationIEN,
            titleIEN,
            emDuzCode,
            tri.ICD10_code__c
        );
        system.debug('response body for encounterString ' + response.getBody());
        if (response.getStatusCode() == 200) {
            //traverse the data structure to get to the encounterString
            Map<String, Object> responseMap = (Map<String, Object>) JSON.deserializeUntyped(response.getBody());
            map<String, Object> textToMap = new Map<String, Object>((map<String, Object>) responseMap.get('textTO'));
            String text = string.valueOf(textToMap.get('text'));
            system.debug('encounterstring text ' + text);
            Integer startOfEncStrIndex = text.indexOf('EncounterString', 0) + 18;
            String encounterString = text.substring(startOfEncStrIndex);
            CIP_Settings__c setting = CIP_Settings__c.getValues('cipsit');
            String serviceCategory = setting.serviceCategory__c != null ? setting.serviceCategory__c : null;
            Integer[] chars = serviceCategory.getChars();
            Integer indexOfServCat = encounterString.indexOfChar(chars[0]) + 1;
            encounterString = encounterString.substring(0, indexOfServCat);
            system.debug('encounterstring text ' + encounterString);
            return encounterString;
        }
        return null;
    }

    // Method used to build http callout requests
    public static HttpRequest buildHttpRequest(String endpoint) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endpoint);
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('clientid', '{!$Credential.UserName}');
        request.setHeader('clientSecret', '{!$Credential.Password}');
        request.setTimeout(120000);
        return request;
    }

    // Method used to make VDIF callouts. It calls the buildHttpRequest above for the http request
    private static HttpResponse makeVdifCallout(String path, String facilityId, String PatientLocalPid) {
        Http http;
        HttpRequest request;
        HttpResponse response;
        for (Integer i = 1; i < 3; i++) {
            String token = '';
            if (i == 1)
                token = getIAMToken('Access'); //get current access token
            else if (i == 2)
                token = getIAMToken('Refresh'); //get new access token

            http = new Http();
            request = buildHttpRequest(path);
            Map<String, Object> requestBodyMap = new Map<String, Object>{
                'providerLoginSiteCode' => facilityId,
                'patientLocalSiteId' => facilityId,
                'patientLocalPid' => PatientLocalPid,
                'providerName' => UserInfo.getFirstName() +
                ',' +
                UserInfo.getLastName(),
                'providerUserId' => token,
                'patientName' => 'dummy'
            };
            System.debug('requestBodyMap ' + requestBodyMap);
            request.setBody(JSON.serialize(requestBodyMap));
            response = http.send(request);
            system.debug('Response Body ' + response.getBody());
            if (response.getStatusCode() == 401 || response.getStatusCode() == 500) {
                // UnAuthorized or Server Error
                continue;
            } else {
                return response;
            }
        }
        return response;
    }

    // Method used by the writeNote method to make VDIF callouts. It calls the buildHttpRequest above for the http request
    private static HttpResponse makeVdifCalloutToWriteNote(String path, String facilityId, String PatientLocalPid, String note, String encounterString, String titleIEN) {
        Http http;
        HttpRequest request;
        HttpResponse response;
        for (Integer i = 1; i < 3; i++) {
            String token = '';
            if (i == 1)
                token = getIAMToken('Access'); //get current access token
            else if (i == 2)
                token = getIAMToken('Refresh'); //get new access token

            http = new Http();
            request = buildHttpRequest(path);
            Map<String, Object> requestBodyMap = new Map<String, Object>{
                'encounterString' => encounterString,
                'titleIEN' => titleIEN,
                'text' => note,
                'providerLoginSiteCode' => facilityId,
                'patientLocalPid' => PatientLocalPid,
                'providerName' => UserInfo.getFirstName() +
                ',' +
                UserInfo.getLastName(),
                'providerUserId' => token
            };
            System.debug('requestBodyMap ' + requestBodyMap);
            request.setBody(JSON.serialize(requestBodyMap));
            response = http.send(request);
            system.debug('Response Body ' + response.getBody());
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                // Everthing fine
                return response;
            } else if (response.getStatusCode() == 401 || response.getStatusCode() == 500) {
                // UnAuthorized or Server Error
                continue;
            } else {
                throw new cipTriageHandlerException(
                    'HTTP callout failed:' +
                        '\nendPoint=' +
                        request.getEndPoint() +
                        '\nstatusCode=' +
                        response.getStatusCode() +
                        '\nstatus=' +
                        response.getStatus() +
                        '\nbody=' +
                        response.getBody()
                );
            }
        }
        return response;
    }

    // Method used to make VDIF callout to get the encounterString. It calls the buildHttpRequest above for the http request
    private static HttpResponse makeVdifCalloutToSaveNoteAndEncounter(
        String path,
        String patientName,
        String facilityId,
        String PatientLocalPid,
        String locationIEN,
        String titleIEN,
        String eAndMCode,
        String ICD10Code
    ) {
        Http http;
        HttpRequest request;
        HttpResponse response;
        for (Integer i = 1; i < 3; i++) {
            String token = '';
            if (i == 1)
                token = getIAMToken('Access'); //get current access token
            else if (i == 2)
                token = getIAMToken('Refresh'); //get new access token

            http = new Http();
            request = buildHttpRequest(path);

            CIP_Settings__c setting = CIP_Settings__c.getValues('cipsit');
            String serviceCategory = setting.serviceCategory__c != null ? setting.serviceCategory__c : null;
            String procedures = eAndMCode;
            String diagnoses = ICD10Code;

            //Map<String,Object> requestBodyMap = new Map<String,Object>{'patientName' => patientName, 'providerLoginSiteCode' => '984', 'patientLocalSiteId' => '984', 'patientLocalPid' => '78', 'providerName' => UserInfo.getFirstName()+ ','+ UserInfo.getLastName(), 'providerUserId' => 'ou1mvMf8HHGLbEIie7vAyvp7mY5wq4jhi9McDEwT', 'noteAndEncounterLocationIen' => '2289', 'noteAndEncounterNoteTitleIen' => '1986', 'noteAndEncounterServiceCategory' => 'A', 'noteAndEncounterProcedures' => procedures, 'noteAndEncounterDiagnoses' => 'Z71.89^Acute depression'};
            Map<String, Object> requestBodyMap = new Map<String, Object>{
                'patientName' => patientName,
                'providerLoginSiteCode' => facilityId,
                'patientLocalSiteId' => facilityId,
                'patientLocalPid' => PatientLocalPid,
                'providerName' => UserInfo.getFirstName() +
                ',' +
                UserInfo.getLastName(),
                'providerUserId' => token,
                'noteAndEncounterLocationIen' => locationIEN,
                'noteAndEncounterNoteTitleIen' => titleIEN,
                'noteAndEncounterServiceCategory' => serviceCategory,
                'noteAndEncounterProcedures' => procedures,
                'noteAndEncounterDiagnoses' => diagnoses
            };

            System.debug('requestBodyMap ' + requestBodyMap);
            request.setBody(JSON.serialize(requestBodyMap));
            response = http.send(request);
            system.debug('Response Body ' + response.getBody());
            if (response.getStatusCode() >= 200 && response.getStatusCode() < 300) {
                // Everthing fine
                return response;
            } else if (response.getStatusCode() == 401 || response.getStatusCode() == 500) {
                // UnAuthorized or Server Error
                continue;
            } else {
                throw new cipTriageHandlerException(
                    'HTTP callout failed:' +
                        '\nendPoint=' +
                        request.getEndPoint() +
                        '\nstatusCode=' +
                        response.getStatusCode() +
                        '\nstatus=' +
                        response.getStatus() +
                        '\nbody=' +
                        response.getBody()
                );
            }
        }
        return response;
    }

    // get the IAM token for the current logged in user to be passed to VDIF calls
    @testVisible
    private static String getIAMToken(String AccessRefresh) {
        String IAMToken, accessToken;
        String refreshError;
        Map<String, String> refreshTokenMap;
        boolean iamconnectedenv = false;
        String authProviderName;
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

        //get the values from the CIP IAM Connected Environment.
        for (CIP_Settings__c iamenv : CIP_Settings__c.getAll().values()) {
            System.debug('base url from Custom setting:' + iamenv.baseUrl__c);
            IAMToken = iamenv.token__c != null ? iamenv.token__c : null;
            if (baseUrl.contains(iamenv.baseUrl__c)) {
                iamconnectedenv = true;
                authProviderName = iamenv.AuthProviderName__c != null ? iamenv.AuthProviderName__c : 'VA_SSOi';
                break;
            }
        }
        //If the environment is connected IAM, get the access token
        if (iamconnectedenv) {
            if (AccessRefresh == 'Access') {
                if (!Test.isRunningTest()) {
                    accessToken = IAM_SSOi_OAuthUtility.getAccessToken(authProviderName);
                } else if (Test.isRunningTest())
                    accessToken = IAMToken;
                if (accessToken != null) {
                    system.debug('using accessToken: ' + accessToken);
                    IAMToken = accessToken;
                } else {
                    system.debug('access Token error');
                    throw new cipTriageHandlerException('access Token Error');
                }
            } else if (AccessRefresh == 'Refresh') {
                if (!Test.isRunningTest()) {
                    refreshTokenMap = IAM_SSOi_OAuthUtility.getRefreshToken(authProviderName);
                } else if (Test.isRunningTest()) {
                    refreshTokenMap = new Map<String, String>();
                    refreshTokenMap.put('AccessToken', IAMToken);
                }
                accessToken = refreshTokenMap?.get('AccessToken');
                refreshError = refreshTokenMap?.get('RefreshError');
                if (refreshError == null) {
                    system.debug('using accessToken: ' + accessToken);
                    IAMToken = accessToken;
                } else {
                    system.debug('error refresh error: ' + refreshError);
                    throw new cipTriageHandlerException('Refresh Error:' + refreshError);
                }
            }
        }

        return IAMToken;
    }

    @testVisible
    private static String parseNoteText(String unparsedText) {
        string noBarCharText = '';
        CIP_Settings__c setting = CIP_Settings__c.getValues('cipsit');
        String replacementChar = String.valueOf(setting.TXCPipeSymbolReplacement__c) != null ? String.valueOf(setting.TXCPipeSymbolReplacement__c) : null;
        Integer charLimit = Integer.valueOf(setting.VistaNoteLineCharacterLimit__c) != null ? Integer.valueOf(setting.VistaNoteLineCharacterLimit__c) : null;

        System.debug('UnparsedText:' + unparsedText);

        if (unparsedText.length() > 0) {
            if (unparsedText.contains('|')) {
                noBarCharText = unparsedText.replace('|', replacementChar);
            } else {
                noBarCharText = unparsedText;
            }
        }
        List<String> unparsedTextLines = noBarCharText.split('\n');
        String parsedText = '';

        for (String line : unparsedTextLines) {
            if (line.length() > charLimit) {
                Integer startIndex = 0;
                Integer endIndex = charLimit - 1;
                String toAddToNextLineText = '';
                String currentLine = line.substring(startIndex, endIndex);

                do {
                    //System.debug('current line:'+currentLine);
                    Integer lastOccurenceIndex = line.lastIndexOfChar(32, endIndex);
                    //System.debug('lastOccurenceIndex actual:'+line.lastIndexOfChar(32 , endIndex));
                    //System.debug('lastOccurenceIndex variable:'+lastOccurenceIndex);
                    lastOccurenceIndex = lastOccurenceIndex > startIndex ? lastOccurenceIndex : 0;
                    Integer lastOccurenceIndexOfTab = line.lastIndexOfChar(9, endIndex);
                    //System.debug('lastOccurenceIndexOfTab:'+lastOccurenceIndexOfTab);
                    lastOccurenceIndex = lastOccurenceIndex > lastOccurenceIndexOfTab ? lastOccurenceIndex : lastOccurenceIndexOfTab;
                    lastOccurenceIndex = lastOccurenceIndex <= 0 ? endIndex : lastOccurenceIndex + 1;
                    String lineToParse = line.subString(startIndex, lastOccurenceIndex);
                    //System.debug('lineToParse:'+lineToParse);
                    //System.debug('lineToParse length:'+lineToParse.length());
                    if (lastOccurenceIndex != line.length()) {
                        toAddToNextLineText = line.subString(lastOccurenceIndex, line.length());
                        currentLine = toAddToNextLineText;
                    }
                    //System.debug('toAddToNextLineText:'+toAddToNextLineText);
                    startIndex = lastOccurenceIndex;
                    endIndex = startIndex + charLimit;
                    if (endIndex > line.length()) {
                        endIndex = line.length();
                    }
                    //else currentLine =
                    //System.debug('start index:'+startIndex+' endIndex:'+endIndex);
                    parsedText += lineToParse + '\n';
                    //System.debug('parsedText in do while:'+parsedText);
                } while (line.length() - startIndex > charLimit);
                parsedText += toAddToNextLineText + '\n';
                //System.debug('parsedText out of do while:'+parsedText);
            } else {
                parsedText += line + '\n';
            }
        }
        system.debug('parsedText:' + parsedText);
        return parsedText;
    }

    public class cipTriageHandlerException extends Exception {
    }
}
