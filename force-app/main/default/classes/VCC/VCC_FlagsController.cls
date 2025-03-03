/**
 * @author Kumar Balan
 * @group API - Bridg - Flags
 * @description Controller class for Flags
 */
public with sharing class VCC_FlagsController {
    public static final String TYPE_FLAG = 'Flags';
    public static String enviornment;
    public static final String FLAG_NAME_HIGH_RISK_FOR_SUICIDE = 'HIGH RISK FOR SUICIDE';

    @AuraEnabled(Cacheable=true Scope='global')
    /**
     * @description
     * @param flagReqWrp
     *
     * @return VCC_FlagResponseWrp
     */
    public static VCC_FlagResponseWrp getFlags(VCC_FlagLightningRequestWrp flagReqWrp) {
        return new VCC_FlagService().getFlags(flagReqWrp);
    }

    @AuraEnabled
    /**
     * @description
     * @param recordId
     *
     * @return String
     */
    public static String acknowledgeFlag(String recordId) {
        String accountId = recordId;

        //CCCM-21695
        VCC_RecentViewHelper.acknowledge(recordId, VCC_RecentViewHelper.TYPE_FLAGS);

        Map<String, Object> resp = new Map<String, Object>();
        resp.put('status', true);
        return JSON.serializePretty(resp);
    }

    @InvocableMethod(Label='Get Flag Status' Callout=true Description='make callout to flag service and return status')
    /**
     * @description
     * @param recordIds
     * @description retrieves flag status for patient
     * @return List<FlagStatusResult>
     */
    public static List<FlagStatusResult> getFlagStatus(List<String> recordIds) {
        String recordId = recordIds[0];
        String facility = '613';
        String env = VCC_ApiSettingUtility.getEnviornment();
        if (String.isBlank(enviornment)) {
            enviornment = env;
        }
        String responseBody = '';
        Integer responseCode = 0;
        String accountId = recordId;
        String sObjName = Id.valueOf(recordId).getSobjectType().getDescribe().getName();
        if (sObjName == 'VCC_Progress_Note__c') {
            accountId = [
                SELECT VCC_Case__r.AccountId
                FROM VCC_Progress_Note__c
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
            ][0]
            .VCC_Case__r.AccountId;
        } else if (sObjName == 'Case') {
            accountId = [
                SELECT AccountId
                FROM Case
                WHERE Id = :recordId
                WITH SECURITY_ENFORCED
            ][0]
            .AccountId;
        }

        if (VCC_TrainingModeService.isTrainingModeEnabled()) {
            responseBody = VCC_TrainingModeService.getFlagsByAccountId(accountId);
            responseCode = 200;
        } else {
            if (enviornment == VCC_ApiSettingUtility.ENV_PROD) {
                HttpResponse flagCalloutResponse = new VCC_FlagService()
                    .retrieveFlagCallout(recordId, facility, null, null);
                responseBody = flagCalloutResponse.getBody();
                responseCode = flagCalloutResponse.getStatusCode();
            } else {
                responseBody = [
                        SELECT Id, Body
                        FROM StaticResource
                        WHERE Name = 'VCC_FlagJsonExample'
                        WITH SECURITY_ENFORCED
                        LIMIT 1
                    ][0]
                    .Body.toString();
                responseCode = 200;
            }
        }
        Boolean isHighRiskForSuicide = false;
        if (responseCode == 200) {
            VCC_FlagModal flagModalObj = (VCC_FlagModal) VCC_JSONUtil.deserialize(
                responseBody,
                Type.forName('VCC_FlagModal')
            );
            List<VCC_FlagModal.FlagsSite> sites = flagModalObj.sites;
            for (VCC_FlagModal.FlagsSite siteObj : sites) {
                //if(siteObj.results != null && siteObj.results.flags != null && siteObj.results.flags.flag != null){
                List<VCC_FlagModal.FlagsFlag> flagList = siteObj?.results?.flags?.flag;
                if (flagList != null) {
                    for (VCC_FlagModal.FlagsFlag flagObj : flagList) {
                        if (flagObj.name.value == FLAG_NAME_HIGH_RISK_FOR_SUICIDE) {
                            isHighRiskForSuicide = true;
                            break;
                        }
                    }
                }
            }
        }
        FlagStatusResult flagStatusResultObj = new FlagStatusResult();
        flagStatusResultObj.isHighRiskForSuicide = isHighRiskForSuicide;
        return new List<FlagStatusResult>{ flagStatusResultObj };
    }

    /**
     * @author Allan Flores
     * @group BAH
     * @description invocable variable used in flows
     */
    public class FlagStatusResult {
        @InvocableVariable(Label='is High Risk For Suicide' Description='Flag contains High Risk For Suicide Flag')
        public Boolean isHighRiskForSuicide;
    }
}
