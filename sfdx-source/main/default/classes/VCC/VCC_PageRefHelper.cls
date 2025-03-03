/**
 * @description A helper class full of instant methods that can be used reused
 * @author      Booz Allen Hamilton
 * @since       2-7-24
 */
public class VCC_PageRefHelper {
    /**
     * @description getFlowRedirectPageReference retrieves a PageReference to the specified Flow, adding the current record ID as a parameter and adding the flow name
     *                                           allowing automatic redirection to the flow when called.
     * @param targetFlowName Name of the flow to start
     * @param targetRecordId Incoming Record ID
     * @return PageReference Redirect to the Flow page with the current record ID as a parameter.
     *
     * @example 'new VCC_PageRefHelper().getFlowRedirectPageReference(targetFlowName, targetRecordId);'
     */
    public PageReference getFlowRedirectPageReference(String targetFlowName, String targetRecordId) {
        if (String.isBlank(targetFlowName) || String.isBlank(targetRecordId)) {
            return null;
        }
        String recordId = targetRecordId;
        String flowName = targetFlowName;
        PageReference flowPageRef = new PageReference('/flow/' + flowName);
        flowPageRef.getParameters().put('recordId', recordId);
        flowPageRef.setRedirect(true);
        return flowPageRef;
    }
}
