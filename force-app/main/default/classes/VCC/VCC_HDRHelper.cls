/**
 * @author Liberty IT: VAHC
 * @since 9/2/2021
 * @description Helper methods for VAHC HDR integration
 * @group API - Bridg - Meds
 *
 */

public with sharing class VCC_HDRHelper {
    /**
     * @description From LWC, we need to provide sObjectName and record Id
     *
     * @param record HDR service to generate request body for.
     * @param numRecords If applicable: number of records to return from API call.
     * @param recordId Id of current Salesforce record.
     * @param sfObject Salesforce object to query ICN against.
     * @return HDR request body
     */
    public static String generateBRIDG(String recordId, String service, String currentObject, Boolean initialCallout) {
        return generateBRIDG(recordId, service, currentObject, initialCallout, String.valueOf(Date.today().addYears(-1)).substring(0, 10), '2050-01-01');
    }

    /**
     * @description created a request to HDR
     */

    public static String generateBRIDG(String recordId, String service, String currentObject, Boolean initialCallout, String startDate, String stopDate) {
        VCC_EHRM_Settings__mdt settings = [SELECT Id, DeveloperName, Max__c, Initial__c FROM VCC_EHRM_Settings__mdt WHERE DeveloperName = 'vccEHRM' WITH USER_MODE LIMIT 1][0];

        if (!String.isBlank(recordId) && !String.isBlank(currentObject)) {
            String icn;

            /**
             * Get ICN based on what object is passed in.
             */

            switch on currentObject {
                when 'Account' {
                    SObject sfObject = Database.query(
                        'SELECT Id, VCC_MVI_External_Id__pc FROM ' + String.escapeSingleQuotes(currentObject) + ' WHERE Id = \'' + String.escapeSingleQuotes(recordId) + '\''
                    );
                    Account acct = (Account) sfObject;
                    icn = acct.VCC_MVI_External_Id__pc;
                }
                when 'Case' {
                    SObject sfObject = Database.query(
                        'SELECT Id, account.VCC_MVI_External_Id__pc FROM ' +
                            String.escapeSingleQuotes(currentObject) +
                            ' WHERE Id = \'' +
                            String.escapeSingleQuotes(recordId) +
                            '\''
                    );
                    case oCase = (case) sfObject;
                    icn = oCase.Account.VCC_MVI_External_Id__pc;
                }
                when 'VCC_Progress_Note__c' {
                    SObject sfObject = Database.query(
                        'SELECT Id, ac.VCC_MVI_External_Id__pc FROM VCC_Progress_Note__c pn, pn.VCC_Case__r cs, cs.Account ac WHERE Id = \'' +
                            String.escapeSingleQuotes(recordId) +
                            '\''
                    );
                    VCC_Progress_Note__c progressNoteVitals = (VCC_Progress_Note__c) sfObject;
                    icn = progressNoteVitals.VCC_Case__r.Account.VCC_MVI_External_Id__pc;
                }
            }
            switch on service {
                when 'vccBridgNotes' {
                    /**
                     * if first callout, only return first limited set of
                     * else return all records
                     */
                    if (initialCallout == true) {
                        return JSON.serialize(
                            new Map<Object, Object>{
                                'assigningAuthority' => 'USVHA',
                                'nationalId' => icn,
                                'assigningFacility' => '',
                                'startDate' => '1950-01-01',
                                'stopDate' => '2050-01-01',
                                'max' => settings.Initial__c
                            }
                        );
                    } else {
                        // EHRM API REQUEST
                        return JSON.serialize(
                            new Map<Object, Object>{
                                'assigningAuthority' => 'USVHA',
                                'nationalId' => icn,
                                'assigningFacility' => '',
                                'startDate' => startDate,
                                'stopDate' => stopDate,
                                'max' => settings.Max__c
                            }
                        );
                    }
                }
                when 'vccBridgMeds' {
                    if (!String.isBlank(icn)) {
                        return JSON.serialize(new Map<Object, Object>{ 'nationalId' => icn, 'assigningAuthority' => 'USVHA', 'assigningFacility' => '613', 'vaType' => 'O' });
                    } else {
                        return null;
                    }
                }
                when 'vccBridgVitals' {
                    return JSON.serialize(
                        new Map<Object, Object>{ 'nationalId' => icn, 'assigningAuthority' => 'USVHA', 'assigningFacility' => '', 'startDate' => startDate, 'stopDate' => stopDate }
                    );
                }
            }
        }

        return null;
    }
}
