/**
 * @description Repository class for the PC_Specialist_Unavailability__c object to hold its respective query and DML logic.
 * @author Booz Allen
 * @since
 */
public inherited sharing class PC_SpecialistUnavailabilityRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_SpecialistUnavailabilityRepo. Calls super constructor which sets this.sObjectType to 'PC_Specialist_Unavailability__c'
     */
    public PC_SpecialistUnavailabilityRepo() {
        super(PC_Specialist_Unavailability__c.SObjectType);
    }

    /**
     * @description   Inserts PC_Specialist_Unavailability__c
     * @param pcSpecialistUnavailability PC_Specialist_Unavailability__c to be inserted when when a specialist is unavailable (Running user's perspective)
     * @return        PC_Specialist_Unavailability__c` PC_Specialist_Unavailability__c record post-insert
     */
    public PC_Specialist_Unavailability__c insertPCSpecialistUnavailability(
        PC_Specialist_Unavailability__c pcSpecialistUnavailability
    ) {
        this.doCreate(pcSpecialistUnavailability);

        return pcSpecialistUnavailability;
    }
}
