/**
 * @description class exists as the controller for the apex page that will pass and environment variable and an ICN into
 * the ccowComponent, which contains the Js required to send into to CCOW on the desktop for CPRS's use.
 *
 */

public class TUC_OrdersContextController {
    /**
     * @description ICN is the patientID that will send via CCOW to CPRS...
     */
    public String icn { get; private set; }
    /**
     * @description Environment variable to know if we are in a sandbox or prod...
     */
    public String env {
        get {
            return new VCR_OrgRepo().orgInfo.isSandbox ? 'test' : 'prod';
        }
        private set;
    }

    /**
     * @description Used to fetch ICN from page params to send to CCOW
     * @param currentRecordId current RecordId
     */
    @TestVisible
    private void fetchICNFromPageParams(Id currentRecordId) {
        try {
            this.icn = VCC_lwc_Utils.getICN(currentRecordId);
        } catch (Exception myException) {
            AuraHandledException ahe = new AuraHandledException('Error fetching ICN: ' + myException.getMessage());
            ahe.setMessage('Error fetching ICN: ' + myException.getMessage());
            throw ahe;
        }
    }

    /**
     * @description Constructor will get the current ID of the record the page is on and use to fetch the related patient ID (ICN)
     */
    public TUC_OrdersContextController() {
        String currentRecordId = ApexPages.CurrentPage().getparameters().get('Id').escapeHtml4();

        fetchICNFromPageParams(currentRecordId);
    }
}
