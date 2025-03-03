/**
 * @class VCC_FacilityService
 * A class for processing and searching for providers in healthcare facility context.
 * @description This class is used to search for providers in a healthcare facility context. It also provides a method to parse a facility ID into three parts: prefix, facilityNumber, and postfix.
 */
public with sharing class VCC_FacilityService {
    /**
     * three matching groups:
     * 1: one or more lowercase letters followed by an underscore
     * 2: 3 or more digits
     * 3: one or more upper or lowercase letters
     * groups 1 and 3 are optional
     * @description This is the regular expression used to parse a facility ID.
     */
    private final static String FACILITY_ID_REGEX = '(?:([a-z]+)_)?([0-9]{3,})([A-Za-z]+)?';

    @TestVisible
    private static VCC_FacilityService privateInstance;

    /**
     * @description Searches for a list of providers using a Schema.Location object, a search string, and an authentication token.
     * @param facility The Schema.Location object which contains the details of the facility.
     * @param searchString The string that might match some criteria of the providers to be found.
     * @param vdifToken The authentication token used for the session or task.
     * @return List<VCC_VdifGetProvidersBySiteRS.ProviderTO> A list of ProviderTO objects that match the given search string in the provided facility.
     */
    public static List<VCC_VdifGetProvidersBySiteRS.ProviderTO> searchProviders(
        Schema.Location facility,
        String searchString,
        String vdifToken,
        Id recordId
    ) {
        /*, String cprsData*/
        return searchProviders(
            facility.VAF_Facility_ID__c.substringAfter('_').substring(0, 3),
            searchString,
            vdifToken,
            recordId /*, cprsData*/
        );
    }
    /**
     * @description This function is used to search for providers based on input parameters.
     * @param facility The healthcare facility object.
     * @param searchString A string value which could be part of a provider's name, id, etc.
     * @param vdifToken A token for authenticating the Vdif service.
     * @param recordId of the progress note or addendum
     * @return List<VCC_VdifGetProvidersBySiteRS.ProviderTO> Returns a list of provider objects associated with a given site.
     */
    public static List<VCC_VdifGetProvidersBySiteRS.ProviderTO> searchProviders(
        HealthcareFacility facility,
        String searchString,
        String vdifToken,
        Id recordId
    ) {
        /*, String cprsData*/
        return searchProviders(
            String.valueOf(facility.VCC_Site_Id__c),
            searchString,
            vdifToken,
            recordId /*, cprsData*/
        );
    }

    /**
     * @description Used to create GetProvideresBySite RQ with a record Id and calls VCC_VdifClient to send http request.
     * @param siteCode `String` that represents the site code where the search is conducted.
     * @param searchString `String` that represents the search query used to find the providers.
     * @param vdifToken `String` that represents the provider userId used for authentication in the request.
     * @param recordId `Id` of progress note or addendum
     * @return             `List<VCC_VdifGetProvidersBySiteRS.ProviderTO>` Returns a list of ProviderTO objects. The list might be empty if there is no provider that matches the condition.
     */
    public static List<VCC_VdifGetProvidersBySiteRS.ProviderTO> searchProviders(
        String siteCode,
        String searchString,
        String vdifToken,
        Id recordId
    ) {
        VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ = new VCC_VdifGetProvidersBySiteRQ();
        getProvidersBySiteRQ.providerLoginSiteCode = siteCode;
        getProvidersBySiteRQ.providerUserId = vdifToken;
        getProvidersBySiteRQ.providerName = UserInfo.getLastName() + ', ' + UserInfo.getFirstName();
        getProvidersBySiteRQ.target = searchString;
        getProvidersBySiteRQ.maxRecords = '10';
        getProvidersBySiteRQ.direction = '1';
        getProvidersBySiteRQ.recordId = recordId;

        VCC_VdifGetProvidersBySiteRS providersRS = (new VCC_VdifClient()).getProvidersBySite(getProvidersBySiteRQ);

        return providersRS?.taggedProviderArray?.providers?.providerTO;
    }
    /**
     * Legacy Facility Service Code End
     * ----------------------------------------------------------------------------------------------------------------------------------
     * New Facility Service Code Start
     * @description This method is used to search for providers using a facility ID, a search string, and an authentication token.
     */

    public static VCC_FacilityService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_FacilityService();
            return privateInstance;
        }
    }
    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub facilityServiceStub = new VCC_Stub(VCC_FacilityService.class);
        VCC_FacilityService.privateInstance = (VCC_FacilityService) facilityServiceStub.instance;
        return facilityServiceStub;
    }
    /**
     * @description This method is used to search for providers using a facility ID, a search string, and an authentication token.
     */
    public class FacilityId {
        public String prefix;

        public String facilityNumber;

        public String postfix;
        /**
         * @description This method is used to convert a facility ID into a string.
         * @return String Returns a string that represents the facility ID.
         */
        public override String toString() {
            return (((this.prefix == null) ? '' : this.prefix + '_') +
            ((this.facilityNumber == null) ? '' : this.facilityNumber) +
            ((this.postfix == null) ? '' : this.postfix));
        }
        /**
         * @description This method is used to compare two facility IDs.
         * @param obj The facility ID to be compared.
         * @return Boolean Returns true if the two facility IDs are equal; otherwise, returns false.
         */
        public Boolean equals(Object obj) {
            if (obj == null) {
                return false;
            }
            if (!(obj instanceof FacilityId)) {
                return false;
            }

            FacilityId facilityId = (FacilityId) obj;
            if (facilityId.prefix != this.prefix) {
                return false;
            }
            if (facilityId.facilityNumber != this.facilityNumber) {
                return false;
            }
            if (facilityId.postfix != this.postfix) {
                return false;
            }

            return true;
        }
        /**
         * @description This method is used to generate a hash code for the facility ID.
         * @return Integer Returns an integer that represents the hash code of the facility ID.
         */
        public Integer hashCode() {
            return this.toString().hashCode();
        }
    }
    /**
     * @description This method is used to parse a given facility ID.
     * @param facilityId The facility ID to be parsed.
     * @return FacilityId Returns a FacilityId object consisting of three parts: prefix, facilityNumber, and postfix. If the parsing does not find matches, it will return a new FacilityId object with all its fields set to null.
     */

    public FacilityId parseFacilityId(String facilityId) {
        if (facilityId == null) {
            return new FacilityId();
        }
        Matcher mchr = Pattern.compile(FACILITY_ID_REGEX).matcher(facilityId);
        if (mchr.find() == false) {
            return new FacilityId();
        }
        FacilityId parsedId = new FacilityId();
        parsedId.prefix = mchr.group(1);
        parsedId.facilityNumber = mchr.group(2);
        parsedId.postfix = mchr.group(3);
        return parsedId;
    }
}
