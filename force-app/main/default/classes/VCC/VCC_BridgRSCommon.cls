public with sharing class VCC_BridgRSCommon {
    public class HL72PersonIdentifier {
        public String identity;
        public String assigningFacility;
        public String assigningAuthority;
    }

    public class HL72PersonName {
        public String prefix;
        public String given;
        public String middle;
        public String family;
        public String suffix;
        public String title;
        public String displayName;
    }

    public class HL72EntityIdentifier {
        public String identity;
        public String namespaceId;
        public String universalId;
        public String universalIdType;
    }

    public class HL72CodedElementLite {
        public String code;
        public String displayText;
        public String codingSystem;
    }

    public class HL72CodedElement {
        public String code;
        public String displayText;
        public String codingSystem;
        public String alternateCode;
        public String alternateDisplayText;
        public String alternateCodingSystem;
    }

    public class HL72FacilityIdentifier {
        public String namespaceId;
        public String universalId;
        public String universalIdType;
    }

    public class HL72OrganizationIdentifier {
        public String identity;
        public String name;
        public String assigningAuthority;
    }
    public class HL72Severity {
        public HL72CodedElementLite value;
    }

    public class VACode {
        public String conceptVuid;
        public String designationVuid;
        public String valueSetVuid;
        public String displayText;
        public String alternateCode;
        public String alternateCodingSystem;
        public Double alternateCodingSystemVersion;
        public String alternateDisplayText;
        public String alternateReason;
    }

    public class PointInTime {
        public String literal;
    }

    public class ProviderType {
        public String namePrefix;
        public String nameGiven;
        public String nameMiddle;
        public String nameFamily;
        public String nameSuffix;
        public String nameTitle;
        public String displayName;
        public String defaultProvider;
    }

    public class TimeInterval {
        public PointInTime low;
        public PointInTime high;
        public PointInTime width;

        public TimeInterval() {
            this.low = new PointInTime();
            this.high = new PointInTime();
            this.width = new PointInTime();
        }
    }

    public class ProvidersType {
        public List<ProviderType> provider;

        public ProvidersType() {
            this.provider = new List<ProviderType>();
        }
    }

    public class PatientLite {
        public HL72PersonIdentifier identifier;
        public HL72PersonName name;

        public PatientLite() {
            this.identifier = new HL72PersonIdentifier();
            this.name = new HL72PersonName();
        }
    }

    public class PractitionerLite {
        public HL72PersonIdentifier identifier;
        public HL72PersonName name;
        public String idSourceTable;

        public PractitionerLite() {
            this.identifier = new HL72PersonIdentifier();
            this.name = new HL72PersonName();
        }
    }

    public class HospitalLocation {
        public HL72OrganizationIdentifier identifier;
        public String telephone;
        public Institution institution;

        public HospitalLocation() {
            this.identifier = new HL72OrganizationIdentifier();
            this.institution = new Institution();
        }
    }

    public class Institution {
        public HL72OrganizationIdentifier identifier;
        public String shortName;
        public String stationNumber;
        public String officialVAName;

        public Institution() {
            this.identifier = new HL72OrganizationIdentifier();
        }
    }

    public class RequestedResolvedIdentifiers {
        public List<HL72PersonIdentifier> requestedResolvedIdentifier;

        public RequestedResolvedIdentifiers() {
            this.requestedResolvedIdentifier = new List<HL72PersonIdentifier>();
        }
    }
    public class RequestedExcludedIdentifiers {
        public List<HL72PersonIdentifier> requestedExcludedIdentifier;

        public RequestedExcludedIdentifiers() {
            this.requestedExcludedIdentifier = new List<HL72PersonIdentifier>();
        }
    }
    public class ResultantIdentifiers {
        public List<HL72PersonIdentifier> resultantIdentifier;

        public ResultantIdentifiers() {
            this.resultantIdentifier = new List<HL72PersonIdentifier>();
        }
    }

    public class CdsErrorSection {
        public List<CdsError> errors;
        public List<CdsError> fatalErrors;
        public List<CdsError> warnings;

        public CdsErrorSection() {
            this.errors = new List<CdsError>();
            this.fatalErrors = new List<CdsError>();
            this.warnings = new List<CdsError>();
        }
    }

    public class CdsError {
        public String errorId;
        public String exception_s;
        public String exceptionMessage;
        public String errorCode;
        public String displayMessage;
    }

    public class FpdsError {
        public String errorId;
        public String exception_s;
        public String exceptionMessage;
        public String errorCode;
        public String displayMessage;
    }

    public class FpdsErrorSection {
        public List<FpdsError> errors;
        public List<FpdsError> fatalErrors;
        public List<FpdsError> warnings;

        public FpdsErrorSection() {
            this.errors = new List<FpdsError>();
            this.fatalErrors = new List<FpdsError>();
            this.warnings = new List<FpdsError>();
        }
    }

    public class PathwaysError {
        public String errorId;
        public String exception_s;
        public String exceptionMessage;
        public String errorCode;
        public String displayMessage;
    }

    public class PathwaysErrorSection {
        public Errors errors;
        public FatalErrors fatalErrors;
        public Warnings warnings;
    }

    public class Errors {
        public List<PathwaysError> error;

        public Errors() {
            this.error = new List<PathwaysError>();
        }
    }
    public class FatalErrors {
        public List<PathwaysError> fatalError;

        public FatalErrors() {
            this.fatalError = new List<PathwaysError>();
        }
    }
    public class Warnings {
        public List<PathwaysError> warning;

        public Warnings() {
            this.warning = new List<PathwaysError>();
        }
    }
}
