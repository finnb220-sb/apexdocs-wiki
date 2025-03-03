/**
 * @description Give flows the ability to refresh the UI of a page without refreshing the browser
 * @author VAHC CRM Pharmacy Development Team
 * @since 11/20/2022
 */

public with sharing class VCC_RefreshUI_Invocable {
    @InvocableMethod(Label='Update UI W/O refresh' Description='Updates the UI of Record with UI Manager Component ' category='UI')
    public static void refreshUI() {
        EventBus.publish(new VCC_Update_UI__e());
    }
}
