/**
 * @description       : Class used as the controller for the ntsp_CaseSearch Lightning Web Component.
 * Uses without sharing to ensure users are aware this case has already been peer reviewed.
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
public without sharing class NTSP_CaseController {
    /**
     * @description Method to return all search filter options
     * @author George Elias | 02-16-2022
     * @return  Map<String, List<ComboBoxWrapper>> - A map containing the combobox options labelled by the map key
     **/
    @AuraEnabled(Cacheable=true)
    public static Map<String, List<ComboBoxWrapper>> fetchComboboxOptions() {
        try {
            final Map<String, List<ComboBoxWrapper>> cbwMap = new Map<String, List<ComboBoxWrapper>>();

            final List<ComboBoxWrapper> consultantList = new List<ComboBoxWrapper>();
            final List<ComboBoxWrapper> creatorList = new List<ComboBoxWrapper>();
            final List<ComboBoxWrapper> facilityList = new List<ComboBoxWrapper>();

            //Loop through NTSP user list and add users to combobox options, then add list to map

            // Set<Id> constulant = new Set<Id>();
            // List<String> permissionsSearch = new List<String> {'NTSP_Consultant','NTSP_Triage_Nurse'};
            // for (SetupEntityAccess access : [
            //     SELECT ParentId
            //     FROM SetupEntityAccess
            //     WHERE SetupEntityId IN (
            //         SELECT Id
            //         FROM CustomPermission
            //         WHERE DeveloperName = 'NTSP_Consultant'
            //     )
            // ]) {
            //     constulant.add(access.ParentId);
            // }

            List<Group> ntspGroups = [SELECT Id, DeveloperName FROM Group WHERE Name LIKE 'NTSP%'];
            List<Group> consultantGroup = new List<Group>();
            for (Group g : ntspGroups) {
                if (g.DeveloperName.contains('NTSP_Consultant')) {
                    consultantGroup.add(g);
                }
            }

            for (User ntspUser : [SELECT Name, Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :ntspGroups) ORDER BY Name]) {
                creatorList.add(new ComboBoxWrapper(ntspUser.Name, ntspUser.Id));
            }

            for (User ntspUser : [SELECT Name, Id FROM User WHERE Id IN (SELECT UserOrGroupId FROM GroupMember WHERE GroupId IN :consultantGroup) ORDER BY Name]) {
                consultantList.add(new ComboBoxWrapper(ntspUser.Name, ntspUser.Id));
            }

            cbwMap.put('consultants', consultantList);
            cbwMap.put('creators', creatorList);

            //Loop through facility list and add users to combobox options, then add list to map
            for (NTSP_Facility__c loc : [SELECT Id, Name FROM NTSP_Facility__c WHERE NTSP_Registered_Site__c = TRUE WITH SECURITY_ENFORCED ORDER BY Name]) {
                facilityList.add(new ComboBoxWrapper(loc.Name, loc.Id));
            }
            cbwMap.put('facilities', facilityList);

            return cbwMap;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description Method to search and return all results based on the search criteria
     * @author George Elias | 02-16-2022
     * @param searchCriteria - Map containing the search critieria
     * @param refreshApex - Used as a work around to refresh impertively called apex in lwc, should be a value that is different every call. ex: current datetime
     * @return  List<ComboBoxWrapper> - A map containing the combobox options labelled by the map key
     **/
    @AuraEnabled
    public static List<CaseRowWrapper> searchCases(Map<String, String> searchCriteria, String refreshApex) {
        try {
            final String caseQuery = buildQuery(searchCriteria);
            return assembleResults(Database.query(caseQuery));
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    private static String buildQuery(Map<String, String> searchCriteria) {
        final String creatorId = searchCriteria.get('creatorId');
        final String consultantId = searchCriteria.get('consultantId');
        final String facilityId = searchCriteria.get('facilityId');
        final String dateString = searchCriteria.get('dateString');

        String caseQuery = 'SELECT Id, Name, CreatedById, CreatedBy.Name, Consult_Date__c, NTSP_Facility__c, NTSP_Facility__r.Name, Last_Name__c, Last_Four__c, Telestroke_Consultant__r.Name, ';

        caseQuery += 'Provider_Called__c, Consult_Time_Local_Time_24_hrs__c, Name_and_Role_of_Caller__c, Location__c, Direct_Call_Back_Number__c, Dr_Caring_for_Patient__c, Stroke_Symptoms__c, LKW_Time_24_hr__c, ';

        caseQuery += '(SELECT Id, RecordTypeId, CreatedById, Status__c FROM NTSP_Peer_Reviews__r) ';

        caseQuery += 'FROM NTSP_Case__c WHERE Id != null';

        caseQuery += (!String.isBlank(creatorId) ? ' AND CreatedById = \'' + String.escapeSingleQuotes(creatorId) + '\'' : '');

        caseQuery += (!String.isBlank(consultantId) ? ' AND Telestroke_Consultant__c = \'' + String.escapeSingleQuotes(consultantId) + '\'' : '');

        caseQuery += (!String.isBlank(facilityId) ? ' AND NTSP_Facility__c = \'' + String.escapeSingleQuotes(facilityId) + '\'' : '');

        caseQuery += (!String.isBlank(dateString) ? ' AND Consult_Date__c = ' + String.escapeSingleQuotes(dateString) : '');

        caseQuery += 'ORDER BY Consult_Date__c DESC, Name DESC LIMIT 200';

        return caseQuery;
    }

    private static List<CaseRowWrapper> assembleResults(List<NTSP_Case__c> caseList) {
        final List<CaseRowWrapper> returnList = new List<CaseRowWrapper>();

        final Boolean isPeerReviewer = FeatureManagement.checkPermission('NTSP_Consultant_Peer_Reviewer') || FeatureManagement.checkPermission('NTSP_Triage_Nurse_Peer_Reviewer');

        for (NTSP_Case__c log : caseList) {
            final CaseRowWrapper clrw = new CaseRowWrapper();
            clrw.caseName = log.Name;
            clrw.caseLink = '/lightning/r/NTSP_Case__c/' + log.Id + '/view';
            clrw.caseTooltip = 'View Case ' + log.Name;

            if (isPeerReviewer) {
                final Boolean isConsultant = FeatureManagement.checkPermission('NTSP_Consultant');
                final boolean isManager = FeatureManagement.checkPermission('NTSP_Consultant_Manager') || FeatureManagement.checkPermission('NTSP_Triage_Nurse_Manager');
                buildPRLink(clrw, log, isConsultant, isManager);
            }

            clrw.consultDate = formatDate(log.Consult_Date__c);
            clrw.facility = log.NTSP_Facility__r?.Name;
            clrw.lastName = log.Last_Name__c;
            clrw.last4 = log.Last_Four__c;
            clrw.caseCreator = log.CreatedBy.Name;
            clrw.consultant = log.Telestroke_Consultant__r?.Name;
            returnList.add(clrw);
        }
        return returnList;
    }

    private static void buildPRLink(CaseRowWrapper clrw, NTSP_Case__c log, Boolean isConsultant, Boolean isManager) {
        if (log.CreatedById == UserInfo.getUserId() || log.Telestroke_Consultant__c == UserInfo.getUserId()) {
            clrw.peerReview = 'Own Case';
            clrw.peerReviewLink = '/lightning/r/NTSP_Case__c/' + log.Id + '/view';
            clrw.peerReviewTooltip = 'View Case ' + log.Name;
        } else {
            for (NTSP_Peer_Review__c pr : log.NTSP_Peer_Reviews__r) {
                final Boolean hasPRAccess = isManager || (!isManager && pr.CreatedById == UserInfo.getUserId());
                final Id consultRtId = Schema.SObjectType.NTSP_Peer_Review__c.getRecordTypeInfosByName().get('Consultant Peer Review').getRecordTypeId();
                final Id nurseRtId = Schema.SObjectType.NTSP_Peer_Review__c.getRecordTypeInfosByName().get('Triage Nurse Peer Review').getRecordTypeId();

                if ((isConsultant && pr.RecordTypeId == consultRtId) || (!isConsultant && pr.RecordTypeId == nurseRtId)) {
                    clrw.peerReview = pr.Status__c;
                    if (hasPRAccess) {
                        clrw.peerReviewLink = '/lightning/r/NTSP_Peer_Review__c/' + pr.Id + '/view';
                    } else {
                        clrw.peerReviewLink = '/lightning/n/NTSP_No_Access';
                    }
                    clrw.peerReviewTooltip = 'View Peer Review of ' + log.Name;

                    break;
                }
            }

            if (clrw.peerReview == null) {
                String prepopValues =
                    '?defaultFieldValues=NTSP_Case__c=' +
                    log.Id +
                    ',NTSP_Facility__c=' +
                    log.NTSP_Facility__c +
                    ',' +
                    'Provider_Calling__c=' +
                    (log.Provider_Called__c ? 'Yes' : 'No') +
                    ',' +
                    'Local_Time_of_Call__c=' +
                    (log.Consult_Time_Local_Time_24_hrs__c != null ? true : false) +
                    ',' +
                    'Name_Role_of_Caller__c=' +
                    log.Name_and_Role_of_Caller__c +
                    ',' +
                    'Facility__c=' +
                    (log.NTSP_Facility__c != null ? true : false) +
                    ',' +
                    'Department__c=' +
                    (log.Location__c != null ? true : false) +
                    ',' +
                    'Direct_Call_Back_Number__c=' +
                    log.Direct_Call_Back_Number__c +
                    ',' +
                    'Dr_Caring_for_Patient__c=' +
                    log.Dr_Caring_for_Patient__c +
                    ',' +
                    'Patient_Last_Name__c=' +
                    (log.Last_Name__c != null ? true : false) +
                    ',' +
                    'Patients_last_4__c=' +
                    (log.Last_Four__c != null ? true : false) +
                    ',' +
                    'Stroke_Symptoms__c=' +
                    log.Stroke_Symptoms__c +
                    ',' +
                    'Was_the_Last_Known_Well_Time_Gathered__c=' +
                    (log.LKW_Time_24_hr__c != null ? true : false);
                clrw.peerReview = 'Peer Review';
                clrw.peerReviewLink = '/lightning/o/NTSP_Peer_Review__c/new' + prepopValues;
                clrw.peerReviewTooltip = 'Create Peer Review for ' + log.Name;
            }
        }
    }

    private static string formatDate(Date dateField) {
        String returnDate = '';
        if (dateField != null) {
            returnDate = dateField.month() + '/' + dateField.day() + '/' + dateField.year();
        }
        return returnDate;
    }

    /**
     * @description       : Class used as the wrapper to return combobox options
     * to the LWC to be used as the options for lightning comboboxes
     * @author            : George Elias
     * @group             : Liberty IT Solutions
     * @last modified on  : 02-16-2022
     * @last modified by  : George Elias
     * Modifications Log
     * Ver   Date         Author                               Modification
     * 1.0   02-16-2022   George Elias                          Initial Version
     **/
    public class ComboBoxWrapper {
        /**
         * String visible to the user
         */
        @AuraEnabled
        public string label;

        /**
         * Actual value of the selection
         */
        @AuraEnabled
        public string value;

        /**
         * @description Constructor to add a label and value
         * @author George Elias | 02-16-2022
         * @return  ComboBoxWrapper - initializes the object with label and value
         **/
        public ComboBoxWrapper(String label, String value) {
            this.label = label;
            this.value = value;
        }
    }

    /**
     * @description       : Class used as the wrapper to return rows to be
     * displayed in the search results datatable
     * @author            : George Elias
     * @group             : Liberty IT Solutions
     * @last modified on  : 02-16-2022
     * @last modified by  : George Elias
     * Modifications Log
     * Ver   Date         Author                               Modification
     * 1.0   02-16-2022   George Elias                          Initial Version
     **/
    public class CaseRowWrapper {
        /**
         * Case Name (Autonumber)
         */
        @AuraEnabled
        public string caseName;

        /**
         * Url that points to the case record page
         */
        @AuraEnabled
        public string caseLink;

        /**
         * Tooltip for case url
         */
        @AuraEnabled
        public string caseTooltip;

        /**
         * Label for the url anchor
         */
        @AuraEnabled
        public string peerReview;

        /**
         * Url that points to either the peer review record page, peer review create page, or back to the case if own case
         */
        @AuraEnabled
        public string peerReviewLink;

        /**
         * Tooltip for peer review url
         */
        @AuraEnabled
        public string peerReviewTooltip;

        /**
         * Consult date as string
         */
        @AuraEnabled
        public string consultDate;

        /**
         * Facility name
         */
        @AuraEnabled
        public string facility;

        /**
         * Patient last name
         */
        @AuraEnabled
        public string lastName;

        /**
         * Patient last 4 of ssn
         */
        @AuraEnabled
        public string last4;

        /**
         * Created by name
         */
        @AuraEnabled
        public string caseCreator;

        /**
         * Telestroke Consultant name
         */
        @AuraEnabled
        public string consultant;
    }
}
