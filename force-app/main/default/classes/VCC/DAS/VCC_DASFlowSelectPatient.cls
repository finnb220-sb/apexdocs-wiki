/**
 * @description Flow Invocable for DAS API selectPatient
 * @author Booz Allen Hamilton
 */
public with sharing class VCC_DASFlowSelectPatient {
    /**
     * @description Invocable method. Calls DAS API selectPatient
     * @param flowSelectPatientRequestList
     * @return `List<Result>`
     */
    @InvocableMethod(label='Select Patient' description='DAS Integration' callout=true category='DAS')
    public static List<Result> selectPatient(List<Request> flowSelectPatientRequestList) {
        try {
            Request flowSelectPatientRequest = flowSelectPatientRequestList[0];
            VCC_DASSelectPatientRQ selectPatientRq = new VCC_DASSelectPatientRQ();

            selectPatientRq.providerLoginSiteCode = flowSelectPatientRequest?.providerLoginSiteCode;
            selectPatientRq.providerName = flowSelectPatientRequest?.providerName;
            selectPatientRq.providerUserId = flowSelectPatientRequest?.providerUserId;
            selectPatientRq.patientLocalPid = flowSelectPatientRequest?.patientLocalPid;
            selectPatientRq.patientLocalSiteId = flowSelectPatientRequest?.patientLocalSiteId;

            VCC_DAS das = new VCC_DAS(
                new VCC_DAS.State(
                    new VCC_SiteId(flowSelectPatientRequest?.providerLoginSiteCode),
                    Label.VCC_VAHC_AppName,
                    flowSelectPatientRequest?.recordId
                )
            );

            return new List<Result>{ new Result(das.selectPatient(selectPatientRq)) };
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new FlowWriteNoteException(e);
        }
    }

    /**
     * @description Input to the invocable method selectPatient
     */
    public class Request {
        @InvocableVariable(label='Progress Note or Addendum record Id' required=true)
        public Id recordId;

        @InvocableVariable(label='Provider Site Code' required=true)
        public String providerLoginSiteCode;

        @InvocableVariable(label='Provider Name' required=true)
        public String providerName;

        @InvocableVariable(label='Token' required=true)
        public String providerUserId;

        @InvocableVariable(label='Patient Local Pid' required=true)
        public List<String> patientLocalPid;

        @InvocableVariable(label='Patient Local Site Id' required=true)
        public String patientLocalSiteId;
    }

    /**
     * @description result of the invocable method selectPatient
     */
    public class Result {
        @InvocableVariable
        public List<VCC_DASSelectPatientRS> selectPatientRSList;

        /**
         * @description constructs the flow result
         * @param selectPatientRS
         */
        public Result(List<VCC_DASSelectPatientRS> selectPatientRS) {
            this.selectPatientRSList = selectPatientRS;
        }
    }

    /**
     * @description Exception that wraps other exceptions thrown by this class that are not VCC_DASException's
     */
    public class FlowWriteNoteException extends VCC_DASException {
    }
}
