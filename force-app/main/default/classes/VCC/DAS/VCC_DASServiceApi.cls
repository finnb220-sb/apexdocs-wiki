/**
 * @description DAS Callouts
 * @author Booz Allen
 */
public with sharing class VCC_DASServiceApi {
    /**
     * @description calls DAS getAdditionalSigners
     * @param getAdditionalSignersRq A `VCC_DASGetAdditionalSignersRQ` which is serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASGetAdditionalSignersRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASGetAdditionalSignersRS getAdditionalSigners(
        VCC_DASGetAdditionalSignersRQ getAdditionalSignersRq,
        VCC_DAS.State dasStateVariables
    ) {
        try {
            return (VCC_DASGetAdditionalSignersRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(getAdditionalSignersRq, dasStateVariables),
                VCC_DASGetAdditionalSignersRS.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS createAddendum
     * @param createAddendumRq A `VCC_DASCreateAddendumRQ` which is serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASCreateAddendumRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASCreateAddendumRS createAddendum(
        VCC_DASCreateAddendumRQ createAddendumRq,
        VCC_DAS.State dasStateVariables
    ) {
        try {
            return (VCC_DASCreateAddendumRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(createAddendumRq, dasStateVariables),
                VCC_DASCreateAddendumRS.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS isValidEsig
     * @param isValidEsigRq A `VCC_DASIsValidEsigRQ` which is then serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASIsValidEsigRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASIsValidEsigRS isValidEsig(VCC_DASIsValidEsigRQ isValidEsigRq, VCC_DAS.State dasStateVariables) {
        try {
            return (VCC_DASIsValidEsigRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(isValidEsigRq, dasStateVariables),
                VCC_DASIsValidEsigRS.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS saveNoteAndEncounterRq
     * @param saveNoteAndEncounterRq A `VCC_DASSaveNoteAndEncounterRQ` which is then serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASSaveNoteAndEncounterRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASSaveNoteAndEncounterRS saveNoteAndEncounter(
        VCC_DASSaveNoteAndEncounterRQ saveNoteAndEncounterRq,
        VCC_DAS.State dasStateVariables
    ) {
        try {
            return (VCC_DASSaveNoteAndEncounterRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(saveNoteAndEncounterRq, dasStateVariables),
                VCC_DASSaveNoteAndEncounterRS.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS signNote
     * @param signNoteRq A `VCC_DASSignNoteRQ` which is then serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASSignNoteRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASSignNoteRS signNote(VCC_DASSignNoteRQ signNoteRq, VCC_DAS.State dasStateVariables) {
        try {
            return (VCC_DASSignNoteRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(signNoteRq, dasStateVariables),
                VCC_DASSignNoteRS.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS writeNote
     * @param writeNoteRq A `VCC_DASWriteNoteRQ` which is then serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASWriteNoteRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASWriteNoteRS writeNote(VCC_DASWriteNoteRQ writeNoteRq, VCC_DAS.State dasStateVariables) {
        try {
            return (VCC_DASWriteNoteRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(writeNoteRq, dasStateVariables),
                VCC_DASWriteNoteRS.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS selectPatient
     * @param selectPatientRq A `VCC_DASSelectPatientRQ` which is then serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASSelectPatientRS` which is the HttpResponse body through JSON.deserialize
     */
    public List<VCC_DASSelectPatientRS> selectPatient(
        VCC_DASSelectPatientRQ selectPatientRq,
        VCC_DAS.State dasStateVariables
    ) {
        try {
            return (List<VCC_DASSelectPatientRS>) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(selectPatientRq, dasStateVariables)
                    .replace('"number"', '"number_s"')
                    .replace('"end"', '"end_s"'),
                List<VCC_DASSelectPatientRS>.class
            );
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS writeNote
     * @param writeNoteAndSignRq A `VCC_DASWriteNoteAndSignRQ` which is then serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASWriteNoteSignSuccessRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASWriteNoteSignSuccessRS writeNoteAndSign(
        VCC_DASWriteNoteAndSignRQ writeNoteAndSignRq,
        VCC_DAS.State dasStateVariables
    ) {
        try {
            return (VCC_DASWriteNoteSignSuccessRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(writeNoteAndSignRq, dasStateVariables),
                VCC_DASWriteNoteSignSuccessRS.class
            );
        } catch (VCC_DASServiceHttp.StatusCodeException statusCodeException) {
            try {
                VCC_DASWriteNoteSignFailureRS failureRS = (VCC_DASWriteNoteSignFailureRS) JSON.deserialize(
                    statusCodeException.responseBody,
                    VCC_DASWriteNoteSignFailureRS.class
                );
                throw new VCC_DASConsolidatedEndpointException(failureRS);
            } catch (System.JSONException jsonException) {
                throw statusCodeException;
            }
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description calls DAS createAddendumAndSign
     * @param createAddendumAndSignRq A `VCC_DASCreateAddendumAndSignRQ` which is serialized into the HttpRequest body.
     * @param dasStateVariables
     * @return A `VCC_DASCreateAddendumAndSignSuccessRS` which is the HttpResponse body through JSON.deserialize
     */
    public VCC_DASCreateAddendumAndSignSuccessRS createAddendumAndSign(
        VCC_DASCreateAddendumAndSignRQ createAddendumAndSignRq,
        VCC_DAS.State dasStateVariables
    ) {
        try {
            return (VCC_DASCreateAddendumAndSignSuccessRS) JSON.deserialize(
                VCC_DAS.SERVICES.HTTP.send(createAddendumAndSignRq, dasStateVariables),
                VCC_DASCreateAddendumAndSignSuccessRS.class
            );
        } catch (VCC_DASServiceHttp.StatusCodeException statusCodeException) {
            try {
                VCC_DASCreateAddendumAndSignFailureRS failureRS = (VCC_DASCreateAddendumAndSignFailureRS) JSON.deserialize(
                    statusCodeException.responseBody,
                    VCC_DASCreateAddendumAndSignFailureRS.class
                );
                throw new VCC_DASConsolidatedEndpointException(failureRS);
            } catch (System.JSONException jsonException) {
                throw statusCodeException;
            }
        } catch (VCC_DASException dasException) {
            throw dasException;
        } catch (Exception e) {
            throw new ApiServiceException(e);
        }
    }

    /**
     * @description Exception that wraps other exceptions thrown in this class
     */
    public class ApiServiceException extends VCC_DASException {
    }
}
