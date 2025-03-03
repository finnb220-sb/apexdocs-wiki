/**
 * @author Booz Allen Hamilton
 * @description A DAS Service for things that don't have a home yet. The hope is that all things have a good home eventually.
 */
public with sharing class VCC_DASServiceUtilities {
    /**
     * @description creates transaction Id that will be added as a http header to the http request
     * @param dasEndpoint         `VCC_DAS.Endpoint` DAS endpoint
     * @param progressNoteOrAddendumId `Id` progress note or addendum record id
     * @return                         `String` transactionId
     */
    public String generateTransactionId(VCC_DAS.Endpoint dasEndpoint, Id progressNoteOrAddendumId) {
        String transactionId = (new VCC_TransactionId(dasEndpoint, progressNoteOrAddendumId)).toString();
        VCC_DAS.SERVICES.LOGGER.debug(transactionId);
        return transactionId;
    }

    /**
     * @description get the provider duz for the given user id
     * @param userId The `Id` of the user who's duz is needed
     * @param siteCode The `String` siteCode of where the duz is located
     * @return `String` the duz
     */
    public String getProviderDuz(Id userId, String siteCode) {
        return (Test.isRunningTest()) ? 'test' : VCC_ProviderService.getProviderDuz(userId, siteCode);
    }

    /**
     * @description Gives the record type for vdif/das-related sobjects. As I write this I wonder if this could be future proofed in the case that Addendums get record types.
     * @param noteSObject The note sobject
     * @return `String` record type for `VCC_Progress_Note__c`. For `VCC_Addendum__c`, returns "VCC_Addendum__c". `null` otherwise.
     */
    public String getRecordTypeApiName(SObject noteSObject) {
        try {
            switch on noteSObject {
                when VCC_Addendum__c addendum {
                    return 'VCC_Addendum__c';
                }
                when VCC_Progress_Note__c progressNote {
                    if (progressNote.RecordTypeId == null && progressNote.Id == null) {
                        return null;
                    }
                    if (progressNote.RecordTypeId == null) {
                        VCC_Progress_Note__c pn = [
                            SELECT RecordTypeId
                            FROM VCC_Progress_Note__c
                            WHERE Id = :progressNote.Id
                            WITH USER_MODE
                            LIMIT 1
                        ]; //NOPMD
                        if (pn.RecordTypeId == null) {
                            return null;
                        }
                        return getRecordTypeApiName(pn);
                    }
                    return VCC_Progress_Note__c.getSObjectType()
                        .getDescribe()
                        .getRecordTypeInfosById()
                        .get(progressNote.RecordTypeId)
                        .getDeveloperName();
                }
                when else {
                    return null;
                }
            }
        } catch (Exception e) {
            throw new GetRecordTypeApiNameException(e.getMessage());
        }
    }

    /**
     * @description Exception class for getRecordTypeApiName method
     */
    public class GetRecordTypeApiNameException extends VCC_DASException {
    }
}
