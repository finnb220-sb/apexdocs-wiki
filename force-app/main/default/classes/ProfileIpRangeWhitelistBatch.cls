/**
 * Author:Jaren Yach
 *  Created Date 05/13/2022
 *  Purpose: This class is to update ip login range to 0.0.0.0 - 255.255.255.255
 *  that have been white listed.
 *  Without sharing is used because this needs to run in a system context.
 */
public without sharing class ProfileIpRangeWhitelistBatch implements Database.Batchable<String>, Database.AllowsCallouts {
    public Iterable<String> start(Database.BatchableContext context) {
        List<String> objList = new List<String>();
        DTCSandboxRefreshSettingSelector refreshSettingSelector = (DTCSandboxRefreshSettingSelector) Injector.getInjector().instantiate('DTCSandboxRefreshSettingSelector');
        DTC_Sandbox_Refresh_Setting__mdt setting = refreshSettingSelector.getSettingForOrg();

        //Only update ip range in sandbox and not production
        if (DTCUtils.getOrgInfo().IsSandbox && setting.Run_Ip_Range_Whitelist__c) {
            //Get records that are white listed
            ProfileIpWhitelistSettingSelector settingSelector = (ProfileIpWhitelistSettingSelector) Injector.getInjector().instantiate('ProfileIpWhitelistSettingSelector');
            for (DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt rec : settingSelector.getAllRecords()) {
                objList.add(rec.ProfileId__c);
            }
        }
        return objList;
    }

    public void execute(Database.BatchableContext context, List<String> objList) {
        Set<Id> profileIds = new Set<Id>();
        for (String itemId : objList) {
            profileIds.add(itemId);
        }

        //Get the profile api name which will allow for updates to profile
        SalesforceToolingApi.QueryResult queryResults = new SalesforceToolingApi().getProfileByIds(profileIds);
        Set<String> profileApiNames = new Set<String>();
        for (SalesforceToolingApi.Record record : queryResults.records) {
            profileApiNames.add(record.FullName);
        }

        for (String profileName : profileApiNames) {
            //Build xml request
            String xmlReq = '<?xml version="1.0" encoding="UTF-8"?>';
            xmlReq += '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tns="http://soap.sforce.com/2006/04/metadata">';
            xmlReq += '<soapenv:Header>';
            xmlReq += '<tns:SessionHeader>';
            xmlReq += '<tns:sessionId>{0}</tns:sessionId>';
            xmlReq += '</tns:SessionHeader>';
            xmlReq += '</soapenv:Header>';
            xmlReq += '<soapenv:Body xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">';
            xmlReq += '<tns:updateMetadata>';
            xmlReq += '<tns:metadata xsi:type="tns:Profile">';
            xmlReq += '<tns:fullName>{1}</tns:fullName>';
            xmlReq += '<tns:loginIpRanges>';
            xmlReq += '<tns:startAddress>{2}</tns:startAddress>';
            xmlReq += '<tns:endAddress>{3}</tns:endAddress>';
            xmlReq += '</tns:loginIpRanges>';
            xmlReq += '</tns:metadata>';
            xmlReq += '</tns:updateMetadata>';
            xmlReq += '</soapenv:Body>';
            xmlReq += '</soapenv:Envelope>';
            xmlReq = String.format(xmlReq, new List<Object>{ UserInfo.getSessionId(), profileName, '0.0.0.0', '255.255.255.255' });

            //If though this is an update, the metadata api requires a post call
            SalesforceRestApi restApi = new SalesforceRestApi();
            restApi.setURL('/services/Soap/m/' + SalesforceRestApi.API_VERSION).setHeader('Content-Type', 'text/xml').setHeader('SOAPAction', 'login').setBody(xmlReq).doPost();
        }
    }

    public void finish(Database.BatchableContext context) {
        DTCUtils.sendCompletedBatchJobEmail(context.getJobId());
    }

    /**
     * Easy way to run this batch job
     *
     * @return Job Id
     */
    public static String run() {
        //Only perform updating 10 profiles at a time.  May need to adjust if this fails
        return Database.executeBatch(new ProfileIpRangeWhitelistBatch(), 5);
    }
}
