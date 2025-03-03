public with sharing class VCC_DirectivesService {
    public static VCC_DirectivesService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_DirectivesService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_DirectivesService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub directivesServiceStub = new VCC_Stub(VCC_DirectivesService.class);
        VCC_DirectivesService.privateInstance = (VCC_DirectivesService) directivesServiceStub.instance;
        return directivesServiceStub;
    }

    /**
     * A somewhat 'flattened' version of VCC_BridgNotesRS.DocumentSite that
     * includes a method to add directives, and a couple properties to
     * determine if there are more notes at the particular 'DocumentSite'
     *
     * Dev Note (Patrick S.):
     * I found that, at least in QA environments, its possible to see notes
     * for more than one site (ex. Notes from 982 and 541) under the
     * same DocumentSite object. API team says it may be because 982 is a test
     * site that was cloned from 541.
     *
     * tl;dr It's a little confusing to call this a 'site'. It might be more accurate
     * to refer to it as a 'system'. That's why I included domain and systemId properties.
     */
    public class Site {
        public Boolean isMaxRecordsError;

        public List<VCC_BridgRSCommon.FpdsError> errors;

        public Map<String, List<VCC_BridgNotesRS.DocumentItem>> facilityIdToDirectivesMap;

        public Set<String> facilityNumberSet;

        public Long maxRequested;

        public Long totalItems;

        public String domain;

        public String systemId;

        public Boolean hasMore {
            get {
                if (this.maxRequested == null || this.totalItems == null) {
                    return false;
                }
                return (this.totalItems >= this.maxRequested) ? true : false;
            }
        }

        public Datetime minDate;

        public void addDirective(VCC_FacilityService.FacilityId facilityId, VCC_BridgNotesRS.DocumentItem directive) {
            if (!VCC_DirectivesService.instance.isDirective(directive)) {
                return;
            }
            String lowerCaseFacilityIdKey = facilityId.toString().toLowerCase();
            if (!this.facilityIdToDirectivesMap.containsKey(lowerCaseFacilityIdKey)) {
                facilityIdToDirectivesMap.put(lowerCaseFacilityIdKey, new List<VCC_BridgNotesRS.DocumentItem>());
            }
            List<VCC_BridgNotesRS.DocumentItem> directives = this.facilityIdToDirectivesMap.get(lowerCaseFacilityIdKey);
            directives.add(directive);
        }

        public Site() {
            this.facilityIdToDirectivesMap = new Map<String, List<VCC_BridgNotesRS.DocumentItem>>();
            this.facilityNumberSet = new Set<String>();
        }
    }

    public List<VCC_DirectivesService.Site> getDirectives(VCC_BridgNotesRQ bridgNotesRq) {
        return this.getDirectives(bridgNotesRq, new VCC_BridgClient());
    }

    @TestVisible
    private List<VCC_DirectivesService.Site> getDirectives(VCC_BridgNotesRQ bridgNotesRq, VCC_BridgClient bridgClient) {
        //performing callout
        VCC_BaseClient.BaseResponse notesBaseRs = bridgClient.notesBase(bridgNotesRq);
        System.debug('notesBaseRs = ' + notesBaseRs);
        List<VCC_DirectivesService.Site> siteList = new List<VCC_DirectivesService.Site>();

        if (notesBaseRs.statusCode != 200) {
            throw new DirectivesServiceException(notesBaseRs.httpResponse.getBody());
        }

        VCC_BridgNotesRS bridgNotesRs = new VCC_BridgNotesRS(notesBaseRs);

        VCC_DirectivesService.Site site = new VCC_DirectivesService.Site();

        site.isMaxRecordsError = bridgNotesRs.isMaxRecordsError;

        for (VCC_BridgNotesRS.DocumentSite documentSite : bridgNotesRs.sites) {
            // Brought site(line 96) outside the for loop so it can be used by other variables that are not inside bridgNotesRs.sites
            // Site site = new Site();
            site.errors = documentSite?.errorSection?.fatalErrors;
            site.maxRequested = VCC_LongService.instance.valueOf(bridgNotesRq.max);
            site.totalItems = VCC_LongService.instance.valueOf(documentSite?.data?.totalItems);
            site.domain = documentSite?.params?.domain;
            site.systemId = documentSite?.params?.systemId;
            siteList.add(site);

            for (
                VCC_BridgNotesRS.DocumentItem documentItem : (documentSite?.data?.items == null)
                    ? new List<VCC_BridgNotesRS.DocumentItem>()
                    : documentSite.data.items
            ) {
                VCC_FacilityService.FacilityId documentFacilityId = VCC_FacilityService.instance.parseFacilityId(
                    documentItem.facilityCode
                );

                Datetime referenceDatetime = VCC_DatetimeService.instance.parse(documentItem.referenceDateTime);

                site.minDate = VCC_DatetimeService.instance.min(site.minDate, referenceDatetime);

                site.facilityNumberSet.add(documentFacilityId.facilityNumber);

                site.addDirective(documentFacilityId, documentItem);
            }
        }

        return siteList;
    }

    public Boolean isDirective(VCC_BridgNotesRS.DocumentItem documentItem) {
        if (documentItem == null) {
            return false;
        }
        if (
            documentItem.documentTypeName != null &&
            (documentItem.documentTypeName.equalsIgnoreCase('Advanced Directive') ||
            documentItem.documentTypeName.equalsIgnoreCase('Advance Directive'))
        ) {
            return true;
        }
        if (documentItem.localTitle == null) {
            return false;
        }
        if (documentItem.localTitle.containsIgnoreCase('consent')) {
            return true;
        }
        if (documentItem.localTitle.containsIgnoreCase('dnr')) {
            return true;
        }
        if (documentItem.localTitle.containsIgnoreCase('advance')) {
            return true;
        }
        if (documentItem.localTitle.containsIgnoreCase('directive')) {
            return true;
        }
        if (documentItem.localTitle.containsIgnoreCase('release')) {
            return true;
        }
        if (documentItem.localTitle.containsIgnoreCase('power of attorney')) {
            return true;
        }
        return false;
    }

    public class DirectivesServiceException extends Exception {
    }
}
