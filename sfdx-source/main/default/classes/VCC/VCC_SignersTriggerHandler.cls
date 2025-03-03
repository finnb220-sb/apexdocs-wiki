/**
 * @description       : Apex Handler for the VCC_Signer__c Object
 * @author            : Rajeev Hoare
 * @group             :
 * @last modified on  :
 * @last modified by  :
 **/
@SuppressWarnings('PMD') //Apex Comment PMD
public with sharing class VCC_SignersTriggerHandler {
    /* @description Trigger to prevent VAHC End-Users from Deleting VCC_Signers__c
     * records when the associated Progress Note or Addendum is signed
     */
    public static void Prevent_Deletion(List<VCC_Signers__c> sLst) {
        /* @description Attempt to Delete Signer Records after signed.
         * @param List of Signers populated from Signer Trigger
         */

        Set<Id> progNoteId = new Set<Id>();
        Set<Id> addNoteId = new Set<Id>();
        for (VCC_Signers__c s : sLst) {
            progNoteId.add(s.VCC_Progress_Note__c);
            addNoteId.add(s.VCC_Addendum__c);
        }

        Map<Id, VCC_Progress_Note__c> pnMap = new Map<Id, VCC_Progress_Note__c>(
            [
                SELECT Id, VCC_Signed__c
                FROM VCC_Progress_Note__c
                WHERE Id IN :progNoteId
                WITH SECURITY_ENFORCED
            ]
        );
        Map<Id, VCC_Addendum__c> adMap = new Map<Id, VCC_Addendum__c>(
            [
                SELECT Id, VCC_Signed__c
                FROM VCC_Addendum__c
                WHERE Id IN :addNoteId
                WITH SECURITY_ENFORCED
            ]
        );

        // Check to see if Progress Note Record or Addendum has been signed
        for (VCC_Signers__c s : sLst) {
            VCC_Progress_Note__c p = pnMap.get(s.VCC_Progress_Note__c);
            VCC_Addendum__c a = adMap.get(s.VCC_Addendum__c);
            if (p != null && p.VCC_Signed__c) {
                s.addError('You cannot delete signers after a Progress Note has been signed.');
            } else if (a != null && a.VCC_Signed__c) {
                s.addError('You cannot delete signers after an Addendum has been signed.');
            }
        }
    }
}
