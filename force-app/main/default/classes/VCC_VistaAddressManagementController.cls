/**
 * @description VCC Vista Address Management Controller
 * @author Booz Allen
 */
public with sharing class VCC_VistaAddressManagementController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';
    private static final String APPLICATION_STRING = 'application';
    private static final String ICN_NAME = 'icn';
    private static final String FACILITY_IDS = 'facilityIds';
    private static final String NEW_ADDRESS = 'newAddress';
    private static final String SITE = 'site';

    /**
     * @description If a recentview repo doesn't exist yet, instantiate a recentview repo.
     */
    @TestVisible
    private static VCR_RecentViewRepo recentViewRepo {
        get {
            return recentViewRepo = recentViewRepo ?? new VCR_RecentViewRepo();
        }
        set;
    }

    /**
     * @description If a pharmacy repo doesn't exist yet, instantiate a pharmacy repo (responsible for interfacing with VTC).
     */
    @TestVisible
    private static VCR_PharmacyRepo pharmacyRepo {
        get {
            return pharmacyRepo = pharmacyRepo ?? new VCR_PharmacyRepo();
        }
        set;
    }

    /**
     * @description - Get Mailing Addresses through VTC
     * @param args - Arguments for the mailing addresses VTC call in the form of Map<String, Object>, example "icn" => {'123456789'}, "facilityIds" => {['984','982']}
     * @return VTC_DataModel - The data model containing the mailing addresses data. If no data is found or if the input argument(s) are invalid/null, a null is returned.
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel getMailingAddressesVTC(Map<String, Object> args) {
        if (args == null || args.get(ICN_NAME) == null || args.get(FACILITY_IDS) == null) {
            return null;
        }
        args.put(APPLICATION_STRING, APPLICATION);
        args = convertListAnyToListString(args, FACILITY_IDS);

        return pharmacyRepo.getMailingAddresses(args);
    }

    /**
     * @description - Get Temporary Addresses through VTC
     * @param args - Arguments for the temporary addresses VTC call in the form of Map<String, Object>, example "icn" => {'123456789'}, "facilityIds" => {['984','982']}
     * @return VTC_DataModel - The data model containing the temporary addresses data. If no data is found or if the input argument(s) are invalid/null, a null is returned.
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel getTemporaryAddressesVTC(Map<String, Object> args) {
        if (args == null || args.get(ICN_NAME) == null || args.get(FACILITY_IDS) == null) {
            return null;
        }
        args.put(APPLICATION_STRING, APPLICATION);
        args = convertListAnyToListString(args, FACILITY_IDS);

        return pharmacyRepo.getTemporaryAddresses(args);
    }

    /**
     * @description - Get most recent VCC_Recent_View__c record for User
     * @return VCC_Recent_View__c - The most recent VCC_Recent_View__c record for the User
     */
    @AuraEnabled
    public static List<VCC_Recent_View__c> getRecentView() {
        return recentViewRepo.getRecentViewFromUser();
    }

    /**
     * @description - Update Mailing Addresses through VTC
     * @param args - Arguments for the mailing addresses VTC call in the form of Map<String, Object>
     * args example: "icn" => {'123456789'}, "facilityIds" => {['984','982']}, "newAddress" => {'street1':'123 Main St', 'city':'Austin', 'state':'TX', 'zip':'78701'}
     * @return VTC_DataModel - The data model containing the results from updating mailing addresses
     */
    @AuraEnabled
    public static VTC_DataModel updateMailingAddressesVTC(Map<String, Object> args) {
        if (
            args == null ||
            args.get(ICN_NAME) == null ||
            args.get(FACILITY_IDS) == null ||
            args.get(NEW_ADDRESS) == null
        ) {
            return null;
        }
        args.put(APPLICATION_STRING, APPLICATION);

        VTC_Site vtcSite = new VTC_Site();
        vtcSite.Id = (String) args.get(ICN_NAME);

        String newAddress = JSON.serialize((Map<Object, Object>) args.get(NEW_ADDRESS));

        for (Object facilityId : (List<Object>) args.get(FACILITY_IDS)) {
            VTC_Address vtcAddress = (VTC_Address) JSON.deserialize(newAddress, VTC_Address.class);
            vtcAddress.siteCode = (String) facilityId;
            vtcSite.records.add(vtcAddress);
        }
        args.put(SITE, vtcSite);
        return pharmacyRepo.updateMailingAddresses(args);
    }

    /**
     * @description Converts the standard List<ANY> from javascript into a List<String>
     * @param args - Map<String, Object> - The list of objects to convert.
     * @param key - String - The map's key to swap the value from Type List<Object> to List<String>
     * @return Map<String, Object> - The values that apex will accept from converted Js params.
     */
    private static Map<String, Object> convertListAnyToListString(Map<String, Object> args, String key) {
        List<String> tempList = new List<String>();
        for (Object obj : (List<Object>) args.get(key)) {
            tempList.add((String) obj);
        }
        args.remove(key);
        args.put(key, tempList);
        return args;
    }
}
