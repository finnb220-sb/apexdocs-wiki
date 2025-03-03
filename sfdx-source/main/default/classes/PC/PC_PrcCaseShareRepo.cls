/**
 * @description Repository class for the PC_Case__Share object to hold its respective query and DML logic.
 * @author      Booz Allen
 * @since       2024
 * @justification Allowing unsafe operations for PC_Case__Share because Share creation needs to be ran in System mode.
 */
public inherited sharing class PC_PrcCaseShareRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for PC_PrcCaseShareRepo. Calls super constructor which sets this.sObjectType to 'PC_Case__Share'
     */
    public PC_PrcCaseShareRepo() {
        super(PC_Case__Share.sObjectType, true);
    }

    /**
     * @description Overrides doCreate to perform unsafe Insert in System Mode.
     * @param record SObject record to be inserted.
     */
    public void performCreateUnsafe(SObject record) {
        try {
            this.doCreateUnsafe(record);
        } catch (DmlException caughtException) {
            Logger.error('Failed to create the PrC Case Share record: ' + caughtException.getMessage());
            throw new PC_CustomException(caughtException.getMessage());
        } finally {
            Logger.saveLog();
        }
    }
}
