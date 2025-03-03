public with sharing class VCC_BridgAdditionalSignersRS extends VCC_BaseClient.BaseResponse {
    public AdditionalSignersStatus additionalSignersStatus { get; set; }

    public class AdditionalSignersStatus {
        public Patient patient;
        public ErrorSection errorSection;
    }

    public class Patient {
        public String requestedNationalId;
        public ResolvedIdentifierType requestedResolvedIdentifiers;
        public IncludedIdentifierType requestedIncludedIdentifiers;
        public ResultantIdentifierType resultantIdentifiers;
        public ClinicalDocumentSigners clinicalDocumentSigners;
    }

    public class ResolvedIdentifierType {
        public VCC_BridgRSCommon.HL72PersonIdentifier requestedResolvedIdentifier;
    }

    public class IncludedIdentifierType {
        public VCC_BridgRSCommon.HL72PersonIdentifier requestedIncludedIdentifier;
    }

    public class ResultantIdentifierType {
        public VCC_BridgRSCommon.HL72PersonIdentifier resultantIdentifier;
    }

    public class ClinicalDocumentSigners {
        public List<ClinicalDocumentSigner> clinicalDocumentSigner;

        public ClinicalDocumentSigners() {
            this.clinicalDocumentSigner = new List<ClinicalDocumentSigner>();
        }
    }

    public class ErrorSection {
        public Warnings warnings;
        public FatalErrors fatalErrors;
        public Errors errors;
    }

    public class FatalErrors {
        public List<ASErrors> fatalError;

        public FatalErrors() {
            this.fatalError = new List<ASErrors>();
        }
    }
    public class Warnings {
        public List<ASErrors> warning;

        public Warnings() {
            this.warning = new List<ASErrors>();
        }
    }

    public class Errors {
        public List<ASErrors> error;

        public Errors() {
            this.error = new List<ASErrors>();
        }
    }

    public class ASErrors {
        public string errorID;
        public String exception_s;
        public String exceptionMessage;
        public String errorCode;
        public String displayMessage;
    }

    public class ClinicalDocumentSigner {
        public string documentNumber;
        public string error;
        public AdditionalSigners additionalSigners;
        public ClinicalDocumentSigner() {
            this.additionalSigners = new AdditionalSigners();
        }
    }

    public class AdditionalSigners {
        public List<AdditionalSigner> additionalSigner;

        public AdditionalSigners() {
            this.additionalSigner = new List<AdditionalSigner>();
        }
    }

    public class AdditionalSigner {
        public VCC_BridgRSCommon.PractitionerLite expectedSigner;
        public String cosignatureNeeded;
        public VCC_BridgRSCommon.PointInTime signatureDate;
        public ManagedPractitionerParticipationLite signer;
        public String signedBySurrogate;

        public AdditionalSigner() {
            this.expectedSigner = new VCC_BridgRSCommon.PractitionerLite();
            this.signatureDate = new VCC_BridgRSCommon.PointInTime();
            this.signer = new ManagedPractitionerParticipationLite();
        }
    }

    public class ManagedPractitionerParticipationLite {
        public VCC_BridgRSCommon.PractitionerLite practitioner;
        public String participationType;
        public VCC_BridgRSCommon.PointInTime participationDate;
        public String signatureBlockName;
        public String signatureBlockTitle;
        public VCC_BridgRSCommon.HL72CodedElementLite signatureMode;

        public ManagedPractitionerParticipationLite() {
            this.practitioner = new VCC_BridgRSCommon.PractitionerLite();
            this.participationDate = new VCC_BridgRSCommon.PointInTime();
            this.signatureMode = new VCC_BridgRSCommon.HL72CodedElementLite();
        }
    }

    public VCC_BridgAdditionalSignersRS() {
        this.additionalSignersStatus = new AdditionalSignersStatus();
    }

    public VCC_BridgAdditionalSignersRS(VCC_BaseClient.BaseResponse baseResponse) {
        super(baseResponse);
        try {
            this.additionalSignersStatus = ((VCC_BridgAdditionalSignersRS) JSON.deserialize(
                    baseResponse.httpResponse.getBody().replace('"exception"', '"exception_s"'),
                    VCC_BridgAdditionalSignersRS.class
                ))
                .additionalSignersStatus;
        } catch (Exception e) {
            this.exceptions.add(e);
        }
    }
}
