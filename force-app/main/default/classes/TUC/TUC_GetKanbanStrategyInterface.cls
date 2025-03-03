/**
 * @description       : Interface Class for TUC_CaseRepo fetch strategies
 * @author            : Booz Allen Hamilton
 *
 * @see TUC_CaseRepo
 * @justification - Codescan is pinging this for having no sharing rule, but interface classes cannot have a sharing rule
 **/
public interface TUC_GetKanbanStrategyInterface {
    /**
     * @description - Sets the config for the interface to the config of the TUC_CaseRepo passed in
     * @param config - TUC_CaseRepo.KanbanMetadataConfig
     */
    void setConfig(TUC_CaseRepo.KanbanMetadataConfig config);

    /**
     * @description - Fetches a map of case data using passed in VISN and repo data
     * @param visnIds - A list of Decimals pertaining to the VISNs the current user is assigned to
     * @param repo - The repo we wish to use
     * @return Map<String, List<<Case>> - A map representing the Kanban case set sorted into lists by status
     */
    Map<String, List<Case>> fetchCasesForKanbanForVisns(List<Decimal> visnIds, TUC_CaseRepo repo);
}
