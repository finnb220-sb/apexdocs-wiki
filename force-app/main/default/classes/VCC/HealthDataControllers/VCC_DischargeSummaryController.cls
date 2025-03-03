/**
 * @description Contains methods to callout via VTC to get a patients discharge summmaries.
 * @author BAH
 *
 * @see VCC_HealthDataRepo
 * @see VCC_WorkstreamSettingsController
 * @see VCC_LabController
 */
public with sharing class VCC_DischargeSummaryController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';
    @TestVisible
    private static final String ICN_KEY = 'icn';
    @TestVisible
    private static final String ENCOUNTER_KEY = 'uid';

    /**
     * @description Singleton instance of a VCR_DischargeSummaryRepo. Contains method to call out via VTC for discharge summaries.
     */
    @TestVisible
    private static VCR_DischargeSummaryRepo dischargeRepo {
        get {
            dischargeRepo = dischargeRepo ?? new VCR_DischargeSummaryRepo();
            return dischargeRepo;
        }
        set;
    }
    /**
     * @description Singleton instance of a VCR_VisitRepo. Contains method to call out via VTC for Visits.
     */
    @TestVisible
    private static VCR_VisitRepo visitRepo {
        get {
            visitRepo = visitRepo ?? new VCR_VisitRepo();
            return visitRepo;
        }
        set;
    }

    /**
     * @description Singleton instance of a VCR_Healthdata Repo. Contains method to get patient birthYear and workstream settings needed for loadMore functionality.
     *
     * @see VCC_WorkstreamSettingsController
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            healthDataRepo = healthDataRepo ?? new VCR_HealthDataRepo('dischargeSummary');
            return healthDataRepo;
        }
        set;
    }

    /**
     * @description Goes and fetches a patients discharge summaries via VTC.
     * @param args Contains a stopDate, startDate, Max and icn argument required to get back discharge summary records.
     *
     * @return `VTC_DataModel` returns Discharge summary records related to the current patient.
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel getDischargeSummary(Map<String, Object> args) {
        //Guard against first call where args aren't populated;
        if (args == null || args.values().size() == 0) {
            return null;
        }
        try {
            args.put('application', APPLICATION);
            return dischargeRepo.fetchDischargeSummary(args);
        } catch (Exception ex) {
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => 'RETRY_CMD',
                'VTC_CalloutException' => 'RETRY_CMD',
                'VTC_TimeoutException' => 'RETRY_CMD'
            };
            throw VCC_ExceptionUtils.createAuraHandledException(ex, cmdMap, 'NO_RETRY_CMD');
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
     * @param icn - icn to query org against
     * @return Returns patient birthyear, and workstream settings
     */
    @AuraEnabled(Cacheable=true)
    public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
        //Guard against null/blank icn.
        if (String.isBlank(icn)) {
            return null;
        }
        try {
            healthDataRepo.setPatientByICN(icn);
            return healthDataRepo.fetchHealthDataConfig();
        } catch (Exception unknownException) {
            throw VCC_ExceptionUtils.createAuraHandledException(
                'Unknown exception thrown fetching health data config!\n',
                unknownException,
                ''
            );
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description Given a patients icn and an encounterId, go get visits and manually search for the encounter based on an ID in the format of a URN.
     * The DIP API counter-intuitively accepts an encounterId yet does not filter on it, so we have to do that work for it.
     * There is no guarantee that what is returned will actually have the encounter we're searching for so we throw exceptions in that case.
     * @param args `Map<String,Object>` Arguments passed to the api. Must include icn, and encounterId.
     *
     * @return `String` Name of the location of the encounter passed in.
     * @throws AuraHandledException if we hit a limit, or if we receive a payload without our expected encounter in it.
     */
    @AuraEnabled
    public static String getLocationName(Map<String, Object> args) {
        if (!argsAreValid(args)) {
            return null;
        }
        try {
            args.put('application', 'VTC_Default');
            VTC_DataModel visits = visitRepo.fetchVisits(args);
            String encounterId = (String) args.get(ENCOUNTER_KEY);
            return new VCC_DischargeSummaryController().findLocationNameFromVisits(visits, encounterId);
        } catch (InvalidLocationDataException invalidLocationException) {
            throw VCC_ExceptionUtils.createAuraHandledException(invalidLocationException.getMessage());
        } catch (VTC_LimitException limitException) {
            throw VCC_ExceptionUtils.createAuraHandledException(
                'Limit exception thrown getting visits for patient.',
                limitException,
                ''
            );
        } catch (Exception unknownException) {
            throw VCC_ExceptionUtils.createAuraHandledException(
                'Unknown exception thrown fetching visits!\n',
                unknownException,
                ''
            );
        } finally {
            Logger.saveLog();
        }
    }

    /**
     *
     * @description Utility method used for validating arguments passed into getLocationName
     * @param args `Map<String,Object>` Map of key value pairs that should include a patients icn, and an encounterId
     *
     * @return `Boolean` True if args are not null,are not empty and do not contain an icn and an encounterId key value pair.
     * @see getLocationName
     */
    @TestVisible
    private static Boolean argsAreValid(Map<String, Object> args) {
        return args != null &&
            args.values().size() > 0 &&
            args.containsKey(ICN_KEY) &&
            args.containsKey(ENCOUNTER_KEY) &&
            args.get(ICN_KEY) != null &&
            args.get(ENCOUNTER_KEY) != null;
    }

    /**
     * @description Given a list of clinical visits and an encounters UID in the form of a URN...
     * find the visit with the matching encounterId and return that visits locationName.
     * @param visits `VTC_DataModel` Payload received from external service that potentially contains the encounter we are looking for.
     * @param encounterId Id of the encounter that contains the locations name that we are looking for.
     *
     * @return `String` Name of the location that the encounter took place at.
     * @throws InvalidLocationDataException If we do not find the locationName.
     *
     * @see VTC_DataModel
     */
    @TestVisible
    private String findLocationNameFromVisits(VTC_DataModel visits, String encounterId) {
        if (visits.sites == null || visits.sites.isEmpty()) {
            throw new InvalidLocationDataException('Callout returned no sites.');
        }
        List<VTC_Site> visitSites = visits.sites;
        //API returns the visit we're looking for as the first record.
        //If we do not get one record we need to throw an exception so that we can tell future devs why nothing was found as opposed to throwing an index out of bound exception.
        VTC_Site firstSite = visitSites.get(0);

        if (firstSite?.records == null || firstSite.records == null || firstSite.records.isEmpty()) {
            throw new InvalidLocationDataException(
                'Site returned without a related visit when searing for location name.'
            );
        }
        VTC_Visit firstVisitReturned = (VTC_Visit) firstSite.records?.get(0);

        if (firstVisitReturned.locationName == null) {
            throw new InvalidLocationDataException('No visit found with uid ' + encounterId);
        }

        return firstVisitReturned.locationName;
    }

    /**
     * @description Exception thrown when invalid visit and location data is returned from our callout.
     */
    public class InvalidLocationDataException extends Exception {
    }
}
