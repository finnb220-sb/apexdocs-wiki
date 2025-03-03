/**
 * @description VA Profile controller for upserting associated persons i.e. next of kin and emergency contact
 * @author Booz Allen Hamilton
 * @see VCC_VaProfileAssociatedPersonsRQ
 * @see VCC_VaProfileAssociatedPersonsRS
 */
public with sharing class VCC_VaProfileController {
    @TestVisible
    private static final String BAD_ID = 'Record ID provided is invalid.';
    @TestVisible
    private static final String BAD_ICN = 'Unable to obtain ICN from account record.';

    private static VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);
    private static VCC_AccountModule accountModule = (VCC_AccountModule) VCC_ModuleService.getModule(
        VCC_AccountModule.class
    );
    private static VCC_VaProfileService vaProfileService = (VCC_VaProfileService) VCC_ModuleService.getModule(
        VCC_VaProfileService.class
    );

    private static final String SPACE_STRING = ' ';
    private static final String T_STRING = 'T';
    private static final String Z_STRING = 'Z';
    private static final String DATE_FORMAT = 'yyyy-MM-dd HH:mm:ss.SSS';
    private static final String UPDATE_DATE_AND_COMMA = '"updateDate":"",';
    private static final String SOURCE_DATE_AND_COMMA = '"sourceDate":"",';
    private static final String UPDATE_DATE = '"updateDate":"';
    private static final String SOURCE_DATE = '"sourceDate":"';
    private static final String COMMA = '",';

    @AuraEnabled
    /**
     * @description Builds the upsert request for AssociatedPersons and sends it to vaProfileService to be processed
     * @param recordId
     * @param associatedPersons
     * @return  `VCC_VaProfileAssociatedPersonsRS`
     * @exception
     */
    public static VCC_VaProfileAssociatedPersonsRS upsertAssociatedPersons(Id recordId, String associatedPersons) {
        //validate Id
        if (!idModule.isIdOfType(recordId, Account.getSObjectType())) {
            throw new VCC_InternalException(BAD_ID);
        }

        String icn = accountModule.getIcn((Id) recordId);

        //validate icn
        if (icn == null) {
            throw new VCC_InternalException(BAD_ICN);
        }

        // update blank date fields
        associatedPersons = updateDateFields(associatedPersons);

        //construct request
        VCC_VaProfileAssociatedPersonsRQ associatedPersonRequest = new VCC_VaProfileAssociatedPersonsRQ();
        associatedPersonRequest.userId = 'acumen';
        associatedPersonRequest.id = icn;
        associatedPersonRequest.idType = 'ICN';
        associatedPersonRequest.vaProfileAssociatedPersons = (List<VCC_VaProfileAssociatedPersonsRQ.VCC_AssociatedPerson>) JSON.deserialize(
            associatedPersons,
            List<VCC_VaProfileAssociatedPersonsRQ.VCC_AssociatedPerson>.class
        );

        for (
            VCC_VaProfileAssociatedPersonsRQ.VCC_AssociatedPerson associatedPerson : associatedPersonRequest.vaProfileAssociatedPersons
        ) {
            associatedPerson.sourceDate = Datetime.now();
            associatedPerson.updateDate = Datetime.now();
        }

        //callout and return
        return vaProfileService.upsertAssociatedPersons(associatedPersonRequest);
    }

    /**
     * @description   Formats and adds the current date to updateDate and sourceDate in the associatedPersons string.
     *  This is needed so that the deserialization does not fail because of blank fields (CCCM-42337).
     * @param associatedPersons
     * @return                  `String`
     */
    public static String updateDateFields(String associatedPersons) {
        // get current date
        String currentDate = Datetime.now().format(DATE_FORMAT);

        // format date like yyyy-mm-ddThh:mm:ss.fffZ
        String formattedDate =
            currentDate.substringBefore(SPACE_STRING) +
            T_STRING +
            currentDate.substringAfter(SPACE_STRING) +
            Z_STRING;

        // replace strings in associatedPersons
        associatedPersons = associatedPersons.replace(UPDATE_DATE_AND_COMMA, UPDATE_DATE + formattedDate + COMMA);
        associatedPersons = associatedPersons.replace(SOURCE_DATE_AND_COMMA, SOURCE_DATE + formattedDate + COMMA);

        return associatedPersons;
    }
}
