/**
 * @description This repository is for PushTopic
 * @author Booz Allen Hamilton
 *
 * @see VTC_BaseRepo
 * @see VCR_PushTopicRepo
 * @see TUC_PushTopicRepoTest
 */
public inherited sharing class TUC_PushTopicRepo extends VCR_PushTopicRepo {
    private static final String HIGH_ACUITY_TYPE_STRING = 'Tele_Urgent_Care_0_2_Hours';
    private static final String INTERMEDIATE_ACUITY_TYPE_STRING = 'Tele_Urgent_Care_2_8_Hours_Case';
    private static final String APOSTROPHE_CONSTANT_STRING = '\'';
    private static final String COMMA_CONSTANT_STRING = ',';

    /**
     * @description - Complete legacy method, we use PushTopics for the Kanban refresh. We have plans to rework back to event driven
     *                refreshes, possibly AWS events. Will remove this method in the future.
     *                This method sees if the PushTopic channel exists, and if it doesn't, it creates it
     * @param topicName - Name for the channel the Aura cmp expects to exist
     */
    public void setTeleECKanbanPushTopic(String topicName) {
        List<PushTopic> pushTopicList = this.getCurrentPushTopic(topicName);
        if (pushTopicList.isEmpty()) {
            try {
                Set<String> recTypeIds = new Set<String>();
                VCR_CaseRepo caseRepo = new VCR_CaseRepo();
                recTypeIds.add(caseRepo.recordTypeConstant.fromDeveloperName(HIGH_ACUITY_TYPE_STRING).Id);
                recTypeIds.add(caseRepo.recordTypeConstant.fromDeveloperName(INTERMEDIATE_ACUITY_TYPE_STRING).Id);
                String idString =
                    APOSTROPHE_CONSTANT_STRING +
                    String.join(
                        recTypeIds,
                        APOSTROPHE_CONSTANT_STRING + COMMA_CONSTANT_STRING + APOSTROPHE_CONSTANT_STRING
                    ) +
                    APOSTROPHE_CONSTANT_STRING;

                PushTopic pushTopic = new PushTopic();
                pushTopic.Name = topicName;
                pushTopic.Query = 'SELECT Id,Status FROM Case WHERE RecordTypeId IN (' + idString + ')';
                pushTopic.ApiVersion = 62.0;
                pushTopic.NotifyForOperationCreate = true;
                pushTopic.NotifyForOperationUpdate = true;
                pushTopic.NotifyForOperationUndelete = true;
                pushTopic.NotifyForOperationDelete = true;
                pushTopic.NotifyForFields = 'Referenced';
                this.doCreate(pushTopic);
            } catch (exception wildException) {
                Logger.error('Tele-EC Kanban PushTopic attempted topic channel: ' + topicName);
                Logger.error('Tele-EC Kanban PushTopic error: ' + wildException.getMessage(), wildException);
            } finally {
                Logger.saveLog();
            }
        }
    }

    private List<PushTopic> getCurrentPushTopic(String topicName) {
        String selectClause = 'SELECT Id,Name ';
        String fromClause = 'FROM PushTopic ';
        String whereClause = 'WHERE Name = :topicName LIMIT 1';
        String query = selectClause + fromClause + whereClause;
        Map<String, Object> bindParams = new Map<String, Object>{ 'topicName' => topicName };

        return this.fetch(query, bindParams);
    }
}
