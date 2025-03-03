public with sharing class VCC_AllergyListController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    @TestVisible
    private static VCR_AllergyRepo allergyRepo {
        get {
            if (allergyRepo == null) {
                allergyRepo = new VCR_AllergyRepo();
            }
            return allergyRepo;
        }
        set;
    }

    /**
     * @description Get Allergies by ICN
     * @param args - Auxiliary arguments to pass to the repo
     * @return VTC_DataModel - The data model containing the radiology data
     */
    @AuraEnabled(Cacheable=true)
    public static VTC_DataModel fetchAllergies(Map<String, Object> args) {
        args.put('application', APPLICATION);

        try {
            return allergyRepo.fetchAllergies(args);
        } catch (Exception caughtException) {
            Logger.error('Fetch orders came back with an exception: ', caughtException);
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => RETRY_CMD,
                'VTC_CalloutException' => RETRY_CMD,
                'VTC_TimeoutException' => RETRY_CMD
            };
            throw VCC_ExceptionUtils.createAuraHandledException(caughtException, cmdMap, NO_RETRY_CMD);
        } finally {
            Logger.saveLog();
        }
    }
}
