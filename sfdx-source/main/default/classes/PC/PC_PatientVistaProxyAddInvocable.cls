/**
 * @description This class holds methods used by Flows to that does a callout into Vista external system and adds Patient to its database
 * @author      Booz Allen
 */
public with sharing class PC_PatientVistaProxyAddInvocable {
    @TestVisible
    private static String response;

    @TestVisible
    private static PC_VistaProxyAddHelper vistaProxyAdd = new PC_VistaProxyAddHelper();

    /**
     * @description    Invocable entry point accessible from a Flow used to initiate the vistaProxyAdd callout
     * @param  paflowInput Input from the Flow (contains patient's Account Id)
     * @return 'List<ProxyAddFlowOutput>' output for Flow (contains the results from vistaProxyAdd)
     */
    @InvocableMethod
    public static List<ProxyAddFlowOutput> getPatientInfoFromFlow(List<ProxyAddFlowInput> paflowInput) {
        List<ProxyAddFlowOutput> results = new List<ProxyAddFlowOutput>();
        ProxyAddFlowOutput paflowOutput = new ProxyAddFlowOutput();

        if (String.isBlank(paflowInput?.get(0)?.patientAccountId) || String.isBlank(paflowInput?.get(0)?.stationId)) {
            paflowOutput.calloutResult = '\n Error: Patient Id and a valid Station Id are needed';
            results.add(paflowOutput);
        } else {
            String proxyAddResult = vistaProxyAdd.vistaProxyAddCallout(
                paflowInput[0].patientAccountId,
                paflowInput[0].stationId
            );
            paflowOutput.calloutResult = proxyAddResult;
            results.add(paflowOutput);
        }

        return results;
    }

    /**
     * @description This inner class will handle the flow inputs
     */
    public class ProxyAddFlowInput {
        @InvocableVariable(required=true)
        public Id patientAccountId;
        @InvocableVariable(required=true)
        public String stationId;
    }

    /**
     * @description This inner class will handle the flow outputs
     */
    public class ProxyAddFlowOutput {
        @InvocableVariable
        public String calloutResult;
    }
}
