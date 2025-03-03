/**
 * @description This repository is for the TUC_VISN_Pause_Control__mdt Metadata.
 * @author Booz Allen Hamilton
 * @see TUC_VISNPauseControlRepoTest
 */
public with sharing class TUC_VISNPauseControlRepo extends VTC_BaseRepo {
    /**
     * @description Create an instance of a Repository
     */
    public TUC_VISNPauseControlRepo() {
        super(TUC_VISN_Pause_Control__mdt.sObjectType);
    }

    /**
     * @description retrieves all instances of the metadata that are active ie TUC Operating Hours Enabled = TRUE
     * @return `List<TUC_VISN_Pause_Control__mdt>` - list of the TUC Pause Control metadata
     */
    public List<TUC_VISN_Pause_Control__mdt> getAllActiveTucVisnPauseControlRecords() {
        List<TUC_VISN_Pause_Control__mdt> pauseControlList = new List<TUC_VISN_Pause_Control__mdt>();
        for (TUC_VISN_Pause_Control__mdt tucVisnPauseControls : TUC_VISN_Pause_Control__mdt.getAll().values()) {
            if (tucVisnPauseControls.TUC_Operating_Hours_Enabled__c == true) {
                pauseControlList.add(tucVisnPauseControls);
            }
        }
        return pauseControlList;
    }
}
