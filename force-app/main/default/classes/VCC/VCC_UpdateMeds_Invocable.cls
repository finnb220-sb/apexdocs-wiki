/**
 * VCC_UpdateMeds_Invocable
 * @description Invocable class LWC
 * @author Liberty
 * @date 01/16/2024
 * @version 1.0.0
 */
public with sharing class VCC_UpdateMeds_Invocable {
    @InvocableMethod(Label='Update Meds W/O refresh' Description='Updates the Meds LWC on this page' category='UI')
    public static void updateMeds() {
        EventBus.publish(new VCC_Update_UI__e(isMeds__c = true));
    }
}
