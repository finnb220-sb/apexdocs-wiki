/**
 *
 * Class Description
 *  Add logic for trigger actions to this class for User sObject
 * @author Lamar Barnett
 * @version 1.0.0
 */

public with sharing class VCC_UserDomain extends DomainActionBase {
    public override void ProcessAction(TriggerRequest request) {
        if (request.targetSObject == User.SObjectType) {
            String triggerAction = request.action + request.process;

            switch on triggerAction {
                when 'BeforeInsert' {
                    beforeInsert(request);
                }
                when 'BeforeUpdate' {
                    beforeUpdate(request);
                }
                when 'BeforeDelete' {
                    beforeDelete(request);
                }
                when 'AfterInsert' {
                    afterInsert(request);
                }
                when 'AfterUpdate' {
                    afterUpdate(request);
                }
                when 'AfterDelete' {
                    afterDelete(request);
                }
            }
        }
        return;
    }

    public void beforeInsert(TriggerRequest request) {
    }
    public void beforeUpdate(TriggerRequest request) {
    }
    public void beforeDelete(TriggerRequest request) {
    }
    public void afterInsert(TriggerRequest request) {
    }
    public void afterUpdate(TriggerRequest request) {
    }
    public void afterDelete(TriggerRequest request) {
    }
}
