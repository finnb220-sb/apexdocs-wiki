/**
 * @description This class performs a callout to Vista external system and adds Patient to its database
 * @author      Booz Allen
 */
public with sharing class PC_VistaProxyAddHelper {
    /**
     * @description Static instance of VCR_AccountRepo.
     */
    @TestVisible
    private static VCR_AccountRepo vcrAccountRepo {
        get {
            return vcrAccountRepo = vcrAccountRepo ?? new VCR_AccountRepo();
        }
        set;
    }

    /**
     * @description     This methods builds a payload to make the vistaAddProxy callout
     * @param accId Account of the Patient (Veteran)
     * @param stnId Specialist's facility retrieved from Service Resource record's Facility Id field
     * @return 'String' Response String from Callout
     */
    public String vistaProxyAddCallout(Id accId, String stnId) {
        String calloutResult = '';

        Set<String> addProxyCalloutFields = new Set<String>{
            'FirstName',
            'LastName',
            'VCC_MVI_External_Id__pc',
            'HealthCloudGA__Gender__pc',
            'PersonBirthdate'
        };
        Account patientAcct = (Account) vcrAccountRepo.fetchById(accId, addProxyCalloutFields);

        MPIVistaProxyBody proxyBody = new MPIVistaProxyBody(
            UserInfo.getUserId(),
            patientAcct.LastName,
            patientAcct.FirstName,
            patientAcct.VCC_MVI_External_Id__pc,
            patientAcct.HealthCloudGA__Gender__pc,
            String.valueOf(patientAcct.PersonBirthdate),
            stnId,
            'MILITARY RETIREE', //This value not tracked in CRM, explicitly set here and not utilized in Vista
            null,
            null
        );

        MPIVistaProxyService vpa = new MPIVistaProxyService();
        MPIVistaProxyResponse res = vpa.proxyAdd('VAHC', proxyBody);
        calloutResult = res.mpiResult;

        return calloutResult;
    }
}
