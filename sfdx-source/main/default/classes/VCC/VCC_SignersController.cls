/**
 * @description Used for adding, deleting or searching signers
 * @author  Booz Allen
 * @group Object - VCC_Signers__c
 */
public with sharing class VCC_SignersController {
    /**
     * @description    Calls VCC_SignersServifce to retrive list of signers for a progress note or addendum
     * @param recordId `Id` of progress note or addendum
     * @return         `List<VCC_Signers__c>`
     */
    @AuraEnabled
    public static List<VCC_Signers__c> getSignersForRecord(Id recordId) {
        return VCC_SignersService.instance.getSignersForRecord(recordId);
    }

    // Whitespace change to trigger the tests to run.

    /**
     * @description      Returns vista user based on search string
     * @param searchString `String` signer's name
     * @param site         `String` facility site
     * @return             `List<VCC_Vista_User__c>`
     */
    @AuraEnabled
    public static List<VCC_Vista_User__c> searchProviders(String searchString, String site) {
        if (String.isBlank(searchString)) {
            return new List<VCC_Vista_User__c>();
        }
        if (searchString.length() < 3) {
            return new List<VCC_Vista_User__c>();
        }
        if (String.isBlank(site)) {
            return new List<VCC_Vista_User__c>();
        }

        if (site.length() > 3) {
            site = site.substring(0, 3);
        }

        return [
            SELECT
                Id,
                VCC_StaffName__c,
                VCC_NPI__c,
                VCC_PositionTitle__c,
                VCC_FirstName__c,
                VCC_ServiceSection__c,
                VCC_OfficePhone__c,
                VCC_SignatureBlockName__c,
                VCC_LastName__c,
                VCC_StaffIEN__c,
                VCC_Station__c
            FROM VCC_Vista_User__c
            WHERE VCC_Station__c = :site AND VCC_StaffName__c LIKE :('%' + searchString + '%')
            WITH USER_MODE
            LIMIT 10
        ];
    }

    /**
     * @description       Adds signer to progress note or addendum record
     * @param vistaUserList `List<VCC_Vista_User__c> ` list of vista users
     * @param recordId      `Id` of progress note or addendum
     * @return              `Boolean`
     */
    @AuraEnabled
    public static Boolean addSignersToRecord(List<VCC_Vista_User__c> vistaUserList, Id recordId) {
        if (vistaUserList.isEmpty()) {
            return false;
        }
        if (String.isBlank((String) recordId)) {
            return false;
        }

        try {
            SObjectType recordSObjectType = recordId.getSobjectType();
            Id progressNoteId;
            Id addendumId;

            if (recordSObjectType === Schema.VCC_Progress_Note__c.SObjectType) {
                progressNoteId = recordId;
            } else if (recordSObjectType === Schema.VCC_Addendum__c.SObjectType) {
                addendumId = recordId;
            }

            List<VCC_Signers__c> signersListForInsert = new List<VCC_Signers__c>();
            for (VCC_Vista_User__c vistaUser : vistaUserList) {
                signersListForInsert.add(convertVistaUserToSigner(vistaUser, progressNoteId, addendumId));
            }
            insert as user signersListForInsert;
        } catch (Exception e) {
            Logger.debug(e.getMessage());
            Logger.debug(e.getStackTraceString());
            return false;
        }
        return true;
    }

    /**
     * @description       Creates signer based on vista user
     * @param vistaUser      ` VCC_Vista_User__c`
     * @param progressNoteId `Id`
     * @param addendumId     `Id`
     * @return               `VCC_Signers__c`
     */
    private static VCC_Signers__c convertVistaUserToSigner(
        VCC_Vista_User__c vistaUser,
        Id progressNoteId,
        Id addendumId
    ) {
        return new VCC_Signers__c(
            Name = vistaUser.VCC_StaffName__c,
            VCC_DUZ__c = vistaUser.VCC_StaffIEN__c,
            VCC_Location__c = vistaUser?.VCC_Station__c,
            VCC_Role__c = null,
            VCC_Title__c = vistaUser?.VCC_PositionTitle__c,
            VCC_Addendum__c = addendumId,
            VCC_Progress_Note__c = progressNoteId
        );
    }

    /**
     * @description   Deletes list of signers
     * @param signers `List<VCC_Signers__c>` signers List
     * @return        `Boolean`
     */
    @AuraEnabled
    public static Boolean deleteSigners(List<VCC_Signers__c> signers) {
        if (signers.isEmpty()) {
            return false;
        }
        delete as user signers;
        return true;
    }

    /**
     * @description      Used in LWC to search provider and send HTTP request
     * @param providerUserId
     * @param siteId
     * @param providerSearchString
     * @param recordId
     * @return                     `String`
     */
    @AuraEnabled
    public static String getProvidersBySite(
        String providerUserId,
        String siteId,
        String providerSearchString,
        Id recordId
    ) {
        return JSON.serialize(
            VCC_FacilityService.searchProviders(siteId, providerSearchString, providerUserId, recordId)
        );
    }

    private class VISNExistanceException extends Exception {
    }
}
