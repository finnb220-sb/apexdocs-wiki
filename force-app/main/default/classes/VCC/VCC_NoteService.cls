/**
 * @description Used to create and send request object for writeNote, signNote, addSigners, and createAddendum
 * @author      Booz Allen
 * @see         VCC_VdifRSCommon
 * @see         VCC_Vdif_PatientAndProviderParams
 * @see         VCC_Vdif_NoteAndEncounterParams
 * @see         VCC_VdifCreateAddendumRQ
 * @see         VCC_VdifSignNoteRQ
 * @see         VCC_VdifGetAdditionalSignersRQ
 * @see         VCC_VdifCreateAddendumRS
 * @see         VCC_VdifSignNoteRS
 * @see         VCC_VdifGetAdditionalSignersRS
 */
public class VCC_NoteService {
    /**
     * @description      Creates createAddendumRQ with a recordId and calls vdifClient to send HTTP request
     * @param addendumText `String` also known as criteria
     * @param noteAndEncounterParams `VCC_Vdif_NoteAndEncounterParams` note params
     * @param patientAndProviderParams `VCC_Vdif_PatientAndProviderParams` patient params
     * @param recordId `Id` of addendum
     * @return                         `VCC_VdifRSCommon.TextTO`
     */
    public static VCC_VdifRSCommon.TextTO createAddendum(
        String addendumText,
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams,
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams,
        Id recordId
    ) {
        VCC_VdifCreateAddendumRQ createAddendumRQ = new VCC_VdifCreateAddendumRQ(
            noteAndEncounterParams.itemId,
            noteAndEncounterParams.noteAndEncounterNoteTitleIen,
            addendumText,
            patientAndProviderParams.providerLoginSiteCode,
            patientAndProviderParams.providerUserId
        );
        createAddendumRQ.recordId = recordId;

        return (new VCC_VdifClient()).createAddendum(createAddendumRQ).createAddendumTextTO;
    }

    /**
     * @description   Creates SignNoteRQ with a recordId and calls VdifClient to send http request. Used in VCC_ProgressNoteController flow invocable apex method.
     * @param noteAndEncounterParams `VCC_Vdif_NoteAndEncounterParams` note params
     * @param patientAndProviderParams `VCC_Vdif_PatientAndProviderParams` patient params
     * @param recordId `Id` for progresss note or addendum
     * @return                         `VCC_VdifRSCommon.TextTO`
     */
    public static VCC_VdifRSCommon.TextTO signNote(
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams,
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams,
        Id recordId
    ) {
        VCC_VdifSignNoteRQ signNoteRQ = new VCC_VdifSignNoteRQ(
            patientAndProviderParams.eSig,
            patientAndProviderParams.providerLoginSiteCode,
            patientAndProviderParams.providerName,
            patientAndProviderParams.providerUserId,
            noteAndEncounterParams.itemId,
            patientAndProviderParams.authorDUZ
        );
        signNoteRQ.recordId = recordId;

        return (new VCC_VdifClient()).signNote(signNoteRQ).signNoteTextTO;
    }

    /**
     * @description           Creates write note RQ with a record Id and calls vdifClient to send HTTP request
     * @param noteText `String` progress note text
     * @param noteAndEncounterParams `VCC_Vdif_NoteAndEncounterParams` note params
     * @param patientAndProviderParams `VCC_Vdif_PatientAndProviderParams` patient params
     * @param recordId `Id` of progress note
     * @return                         `VCC_VdifWriteNoteRS.NoteResultTO`
     */
    public static VCC_VdifWriteNoteRS.NoteResultTO writeNote(
        String noteText,
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams,
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams,
        Id recordId
    ) {
        VCC_VdifWriteNoteRQ writeNoteRQ = new VCC_VdifWriteNoteRQ(
            noteAndEncounterParams.encounterString,
            noteText,
            patientAndProviderParams.providerName,
            patientAndProviderParams.providerLoginSiteCode,
            patientAndProviderParams.providerUserId,
            String.valueOf(patientAndProviderParams.patientLocalPid),
            noteAndEncounterParams.noteAndEncounterNoteTitleIen
        );
        writeNoteRQ.recordId = recordId;
        writeNoteRQ.patientLocalSiteId = patientAndProviderParams.patientLocalSiteId;
        writeNoteRQ.authorDUZ = patientAndProviderParams.authorDUZ;

        return (new VCC_VdifClient()).writeNote(writeNoteRQ).noteResultTO;
    }

    /**
     * @description     Overload method incorporates recordId param
     * @param noteAndEncounterParams
     * @param patientAndProviderParams
     * @param providerDuzList
     * @param recordId
     * @return                         `VCC_VdifGetAdditionalSignersRS`
     */
    public static VCC_VdifGetAdditionalSignersRS addSigners(
        VCC_Vdif_NoteAndEncounterParams noteAndEncounterParams,
        VCC_Vdif_PatientAndProviderParams patientAndProviderParams,
        List<String> providerDuzList,
        Id recordId
    ) {
        VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ(
            patientAndProviderParams.providerName,
            patientAndProviderParams.providerUserId,
            patientAndProviderParams.providerLoginSiteCode,
            noteAndEncounterParams.itemId,
            providerDuzList
        );
        getAdditionalSignersRQ.recordId = recordId;

        return (new VCC_VdifClient()).getAdditionalSigners(getAdditionalSignersRQ);
    }

    public class NoteServiceException extends Exception {
    }
}
