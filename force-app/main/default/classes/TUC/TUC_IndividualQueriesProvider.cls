/**
 * @description       : Individual Query implementation of TUC_GetKanbanStrategyInterface
 * @author            : Booz Allen Hamilton
 *
 * @see TUC_GetKanbanStrategyInterface
 **/
public with sharing class TUC_IndividualQueriesProvider implements TUC_GetKanbanStrategyInterface {
    private TUC_CaseRepo.KanbanMetadataConfig config;
    private static final String CLOSED_STRING = 'Closed';

    /**
     * @description - Sets the config for the interface to the config of the TUC_CaseRepo passed in
     * @param config - TUC_CaseRepo.KanbanMetadataConfig
     */
    public void setConfig(TUC_CaseRepo.KanbanMetadataConfig config) {
        this.config = config;
    }

    /**
     * @description - Fetches a map of case data using passed in VISN and repo data
     * @param visnIds - A list of Decimals pertaining to the VISNs the current user is assigned to
     * @param repo - The repo we wish to use
     * @return sortedCases - A Map<String, List<<Case>> representing the Kanban case set sorted into lists by status
     */
    public Map<String, List<Case>> fetchCasesForKanbanForVisns(List<Decimal> visnIds, TUC_CaseRepo repo) {
        Map<String, List<Case>> sortedCases = new Map<String, List<Case>>();
        /// fail fast, fail safe.
        if (visnIds == null || visnIds.size() == 0) {
            return sortedCases;
        }

        for (String status : config.includedCaseStatuses) {
            List<Case> caseList;
            if (repo.kanbanConfig.tucWaitTimeStatuses.contains(status)) {
                caseList = repo.fetchCasesSortedByWaitTime(status);
            } else if (status == CLOSED_STRING) {
                caseList = repo.fetchClosedCases(status);
            } else {
                caseList = repo.fetchCasesByStatus(status);
            }
            sortedCases.put(status, caseList);
        }

        return sortedCases;
    }
}
