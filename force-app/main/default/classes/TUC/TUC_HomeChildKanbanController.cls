/**
 * @description This class is responsible for encapsulating the logic necessary for building a
 * TUC_HomeChildKanbanDTO object in service of the TUC_HomeChildKanban Aura component.
 *
 * @author Booz Allen Hamilton
 * @see TUC_HomeChildKanbanDTO
 * @see TUC_CaseRepo
 *
 * NB: This class deprecates the TUC_HomeChildKanbanCls class.
 * NB: This class is a rewrite / refactoring of the original class - TUC_HomeChildKanbanCls.
 * The original implementation was highly configurable, and highly dynamic - allowing for a wide range of objects
 * and fields to be queried and displayed on the kanban board. This was a great feature, but it is not fit to scale.
 *
 * No shade is being thrown at the original implementation, it's just not fit for the scale of users we have.
 *
 */

public with sharing class TUC_HomeChildKanbanController {
    /**
     * @description - Static instance of TUC_CaseRepo
     */
    @TestVisible
    private static TUC_CaseRepo caseRepo {
        get {
            return caseRepo = caseRepo ?? new TUC_CaseRepo();
        }
        set;
    }

    /**
     * @description - Static instance of VCR_GroupMemberRepo
     */
    @TestVisible
    private static VCR_GroupMemberRepo groupMemberRepo {
        get {
            return groupMemberRepo = groupMemberRepo ?? new VCR_GroupMemberRepo();
        }
        set;
    }

    /**
     * @description - Static instance of VCR_GroupRepo
     */
    @TestVisible
    private static VCR_GroupRepo groupRepo {
        get {
            return groupRepo = groupRepo ?? new VCR_GroupRepo();
        }
        set;
    }

    /**
     * @description - This method is responsible for building a TUC_HomeChildKanbanDTO object.
     * @param visnFilterValues - A list of VISN Ids to filter the kanban board by.
     *
     * @return TUC_HomeChildKanbanDTO - The data transfer object returned to the TUC_HomeChildKanban Aura component.
     */
    @AuraEnabled
    public static TUC_HomeChildKanbanDTO getKanban(List<String> visnFilterValues) {
        TUC_HomeChildKanbanDTO homeChildKanbanDTO;
        try {
            Map<String, List<Case>> casesMap = caseRepo.fetchListOfCasesForVisns(
                convertStringListToDecimal(visnFilterValues),
                new TUC_IndividualQueriesProvider()
            );
            Schema.DescribeSObjectResult caseSObjDescribe = Schema.SObjectType.Case;
            Schema.DescribeFieldResult statusFieldDescribe = Case.Status.getDescribe();
            homeChildKanbanDTO = new TUC_HomeChildKanbanDTO(
                caseRepo.kanbanConfig.includedCaseStatuses,
                casesMap,
                caseRepo.kanbanConfig.fieldTypeMap
            );
            homeChildKanbanDTO.isSuccess = true;
            homeChildKanbanDTO.isEditable = statusFieldDescribe.isUpdateable();
            homeChildKanbanDTO.isDeletable = caseSObjDescribe.isDeletable();
            homeChildKanbanDTO.isCreatable = caseSObjDescribe.isCreateable();
            return homeChildKanbanDTO;
        } catch (SecurityException securityException) {
            addLogToLoggerAndSaveLog(
                'a SecurityException. The inaccessible fields are: ' +
                    securityException.getInaccessibleFields() +
                    ' The message is: ' +
                    securityException.getMessage()
            );
        } catch (QueryException queryException) {
            addLogToLoggerAndSaveLog('a QueryException. The message is: ' + queryException.getMessage());
        } catch (NullPointerException nullPointerException) {
            addLogToLoggerAndSaveLog('a NullPointerException. The message is: ' + nullPointerException.getMessage());
        } catch (Exception unexpectedException) {
            addLogToLoggerAndSaveLog('an unexpected exception. The message is: ' + unexpectedException.getMessage());
        }

        // In then case, something went wrong and we want to return an error message. So we use
        // the DTO as our transport mechanism.
        homeChildKanbanDTO = new TUC_HomeChildKanbanDTO();
        homeChildKanbanDTO.errorMessage = 'There was an issue getting Tele-EC Kanban Data. Please contact your administrator.';
        return homeChildKanbanDTO;
    }

    private static void addLogToLoggerAndSaveLog(String errorMessage) {
        Logger.error('TUC_HomeChildKanbanController.getKanban caught ' + errorMessage);
        Logger.saveLog();
    }

    private static List<Decimal> convertStringListToDecimal(List<String> visnFilterValues) {
        List<Decimal> filterValListDec = new List<Decimal>();
        for (String visnIdString : visnFilterValues) {
            Decimal visnIdNumber = Decimal.valueOf(visnIdString);
            filterValListDec.add(visnIdNumber);
        }
        return filterValListDec;
    }

    /**
     * @description - This method takes in an Id and some field information from the cmp, creates an SObject, and attempts to update it with doUpdate
     *                Contains some legacy code from previous versions but with repo powered update.
     * @param recordId - The Id of the object we want to update
     * @param recordField - The Api name of the field we want updated
     * @param recordValue - The desired new value of the field
     *
     * @return String - Reports if the update was successful or not
     */
    @AuraEnabled
    public static String updateRecord(String recordId, String recordField, String recordValue) {
        return caseRepo.updateRecord(recordId, recordField, recordValue);
    }

    /**
     * @description - This method takes in an SObject from the cmp and attempts to delete it using doDelete
     * @param deleteTarget - The object to delete
     *
     * @return String - Reports if the deletion was successful or not
     */
    @AuraEnabled
    public static String deleteRecord(SObject deleteTarget) {
        return caseRepo.deleteRecord(deleteTarget);
    }

    /**
     * @description - Retrieves the Kanban Config back to Aura
     * @return TUC_Kanban_Config__mdt - The Kanban Config
     */
    @AuraEnabled
    public static TUC_Kanban_Config__mdt getKanbanConfig() {
        return caseRepo.fetchKanbanConfigMetadata();
    }

    /**
     * @description - Retrieves the VISN set for the kanban board to appropriately filter and query for VISNs the user is assigned to
     * @return String - String of the VISN filter
     */
    @AuraEnabled
    public static String getVISNFilter() {
        List<Id> groupIdList = new List<Id>();
        String visnSet = '';
        for (GroupMember member : groupMemberRepo.fetchByUserOrGroupId(UserInfo.getUserId())) {
            groupIdList.add(member.GroupId);
        }
        for (Group groupName : groupRepo.fetchByGroupIdList(groupIdList)) {
            String caseIns = groupName.DeveloperName.toLowerCase();
            if (caseIns.startsWith('tuc_')) {
                String truncatedName = caseIns.substring(3, 6).replaceAll('_', '');
                if (truncatedName.isNumericSpace()) {
                    visnSet = visnSet.length() > 0 ? visnSet + ',' + truncatedName : '' + truncatedName;
                }
            }
        }
        return visnSet;
    }

    /**
     * @description - Sends the topic channel name to the PushTopic repo and returns the result
     * @param topicName - Name for the channel the Aura cmp expects to exist
     */
    public static void setPushTopic(String topicName) {
        TUC_PushTopicRepo pushTopicRepo = new TUC_PushTopicRepo();
        pushTopicRepo.setTeleECKanbanPushTopic(topicName);
    }

    /**
     * @description          Gets fields from case to be sent to the TUC_HomeChildKanbanCRd Aura cmp
     * @param recordId       a String of the passed in Case Id
     * @return               'LinkDetails' list of field values to display
     */
    @AuraEnabled
    public static LinkDetails loadRecord(String recordId) {
        try {
            LinkDetails details = new LinkDetails();

            details.objectName = 'Case';
            Map<String, String> fieldNames = caseRepo.kanbanConfig.fieldsToDisplayOnPopup;

            SObject keyFieldsForAuraPopover = caseRepo.fetchById(recordId, new Set<String>(fieldNames.keySet()));

            Map<String, Object> fieldsToValue = keyFieldsForAuraPopover.getPopulatedFieldsAsMap();

            List<FieldAttribute> fieldAttributeList = new List<FieldAttribute>();
            for (String fieldName : fieldsToValue.keySet()) {
                FieldAttribute fieldAttribute = new FieldAttribute();
                fieldAttribute.apiName = fieldName;
                fieldAttribute.label = fieldNames.get(fieldName);
                fieldAttribute.value = String.valueOf(fieldsToValue.get(fieldName));
                fieldAttributeList.add(fieldAttribute);
            }
            details.fields = fieldAttributeList;
            return details;
        } catch (Exception unexpectedException) {
            String errorMessage =
                'TUC_HomeChildKanbanController.loadRecord caught an unexpected exception. The message is: ' +
                unexpectedException.getMessage();
            Logger.error(errorMessage);
            Logger.saveLog();
            throw new AuraHandledException(errorMessage);
        }
    }

    /**
     * @description          calls tucCommonUtils to check a user's permissions
     * @param permName       a String of the permission name to be checked
     * @return               Boolean, true if the user has this perm set, false if they do not
     */
    @AuraEnabled
    public static Boolean checkCustomPermission(String permName) {
        return tucCommonUtils.checkCustomPermission(permName);
    }

    /**
     * @description - Used in loadRecord() to contain the details for the card popup as a return DTO
     */
    public class LinkDetails {
        @AuraEnabled
        public String objectName;
        @AuraEnabled
        public List<FieldAttribute> fields;
    }

    /**
     * @description - Used in LinkDetails
     */
    public class FieldAttribute {
        @AuraEnabled
        public String apiName;
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
    }
}
