/**
 * @description Apex controller for vccClearTriageWrapper LWC.
 * @author Booz Allen
 */

public with sharing class VCC_ClearTriageWrapperController {
    /**
     * @description return this class so the data source can be changed without requiring LWC change.
     * @return CTAccessSecurity class
     */
    public class CTAccessSecurity {
        @AuraEnabled
        public String ctAccessUrl;
        @AuraEnabled
        public String ctAccessKey;
    }

    /**
     * @description if an external data source repo doesn\'t exist yet, instantiate an external data source repo
     */
    @TestVisible
    private static VCR_ExternalDataSourceRepo externalDataSourceRepo {
        get {
            return externalDataSourceRepo = externalDataSourceRepo ?? new VCR_ExternalDataSourceRepo();
        }
        set;
    }

    /**
     * @description get the external datasource content needed for the Clear Triage authentication
     * @return      `CTAccessSecurity`
     */
    @AuraEnabled(cacheable=true)
    public static CTAccessSecurity getCTAccessSecurity(String visn) {
        CTAccessSecurity ctas = new CTAccessSecurity();

        try {
            String exDataSourceName = 'CT_Access_Security';

            if (String.isNotBlank(visn) && visn.contains('VISN ')) {
                exDataSourceName += visn.replace('VISN ', '_VISN_');
            }

            ExternalDataSource exDataSource = new ExternalDataSource();
            exDataSource = externalDataSourceRepo.fetchExternalDataSourceUsingSystemMode(exDataSourceName);
            ctas.ctAccessUrl = exDataSource.Endpoint;
            ctas.ctAccessKey = exDataSource.Repository;
        } catch (Exception unknownException) {
            Logger.error('Exception caught while fetching external data source: ' + unknownException);
            AuraHandledException exceptionForFrontEnd = new AuraHandledException(unknownException.getMessage());
            //This is required if you want anything other than Script-thrown exception.
            exceptionForFrontEnd.setMessage(unknownException.getMessage());
            throw exceptionForFrontEnd;
        } finally {
            Logger.saveLog();
        }

        return ctas;
    }
}
