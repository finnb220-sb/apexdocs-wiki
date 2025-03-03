/**
 * @description This repository is for User_UI_Event__c
 * @author Booz Allen Hamilton
 * @since 05/2024
 */
public virtual inherited sharing class VCR_UserUIEventRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_RecordTypeRepo. Calls super constructor which sets this.sObjectType to
     * User_UI_Event__c
     */
    public VCR_UserUIEventRepo() {
        super(User_UI_Event__c.sObjectType);
    }
}
