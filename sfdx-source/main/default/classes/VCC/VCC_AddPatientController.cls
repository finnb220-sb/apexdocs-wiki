/**
 * @description VCC_AddPatientController for the associated vccAddPatientController Lightning Web Component
 */
public with sharing class VCC_AddPatientController {
    @TestVisible
    private static VCC_AddPatientModule addPatientModule = new VCC_AddPatientModule();

    @AuraEnabled
    /**
     * @description Called from vccAddPatientController to search MPI for a veteran record.
     * @param params A JavaScript object.
     * @return SearchMpiResponse
     */
    public static VCC_Result searchMpi(Map<String, Object> params) {
        try {
            Logger.suspendSaving();
            return VCC_Result.ok(new SearchMpiResponse(addPatientModule.searchMpi(params)));
        } catch (Exception e) {
            Logger.error('searchMpi exception', e);
            Logger.resumeSaving();
            Logger.saveLog(Logger.SaveMethod.SYNCHRONOUS_DML);
            return VCC_Result.err(new ControllerError(e));
        }
    }

    @AuraEnabled
    /**
     * @description Called from vccAddPatientController to search Salesforce for a veteran record.
     * @param params A JavaScript object.
     * @return SearchCrmResponse
     */
    public static VCC_Result searchCrm(Map<String, Object> params) {
        try {
            Logger.suspendSaving();
            return VCC_Result.ok(new SearchCrmResponse(addPatientModule.searchCrm(params)));
        } catch (Exception e) {
            Logger.error('searchCrm exception', e);
            Logger.resumeSaving();
            Logger.saveLog(Logger.SaveMethod.SYNCHRONOUS_DML);
            return VCC_Result.err(new ControllerError(e));
        }
    }

    @AuraEnabled
    /**
     * @description Called from vccAddPatientController to add a veteran to CRM
     * @param params A JavaScript object.
     * @return AddVeteranResponse
     */
    public static VCC_Result addVeteran(Map<String, Object> params) {
        try {
            Logger.suspendSaving();
            return VCC_Result.ok(new AddVeteranResponse(addPatientModule.addVeteran(params, Database.setSavepoint())));
        } catch (Exception e) {
            Logger.error('addVeteran exception', e);
            Logger.resumeSaving();
            Logger.saveLog(Logger.SaveMethod.SYNCHRONOUS_DML);
            return VCC_Result.err(new ControllerError(e));
        }
    }

    /**
     * @description This class is the response shape for it's associated AuraEnabled method.
     */
    public class SearchMpiResponse {
        @AuraEnabled
        public List<Object> allData = new List<Object>();

        public SearchMpiResponse(MPIDynamicPersonSearchController.ResponseWrap responseWrap) {
            try {
                this.filterAndConsume((List<Object>) JSON.deserializeUntyped(responseWrap.allData));
            } catch (Exception e) {
                return;
            }
        }

        /**
         * @description Loops through responseWrap.allData and filters it. Only those who don't meet filter critera are added to this.allData.
         * @param allData responseWrap.allData
         */
        private void filterAndConsume(List<Object> allData) {
            for (Object datum : allData) {
                Map<String, Object> searchResult = (Map<String, Object>) datum;
                if (this.meetsFilterCriteria(searchResult) == false) {
                    this.allData.add(searchResult);
                }
            }
        }

        /**
         * @description Determines if a MPI search result meets the filter criteria
         * @return Boolean true if the searchResult meets the criteria (and should be filtered out), false otherwise.
         * @param searchResult The MPI search result
         */
        private Boolean meetsFilterCriteria(Map<String, Object> searchResult) {
            try {
                if (searchResult == null) {
                    return true;
                }
                String personType = (String) searchResult.get('personType');
                String dod = (String) searchResult.get('dod');
                List<Object> medicalCenterFacilities = (List<Object>) searchResult.get('medicalCenterFacilities');

                if (String.isNotBlank(dod)) {
                    return true;
                }
                if (
                    (personType == null || (!personType.contains('PAT') && !personType.contains('VET'))) && (medicalCenterFacilities == null || medicalCenterFacilities.size() == 0)
                ) {
                    return true;
                }
                return false;
            } catch (Exception e) {
                Logger.error('Error when checking filter conditions.', e);
                return false;
            }
        }
    }

    /**
     * @description This class is the response shape for it's associated AuraEnabled method.
     */
    public class SearchCrmResponse {
        @AuraEnabled
        public List<Account> accountList;

        public SearchCrmResponse(VCC_AddPatientModule.SearchCrmResult searchCrmResult) {
            this.accountList = searchCrmResult?.accountList;
        }
    }

    /**
     * @description This class is the response shape for it's associated AuraEnabled method.
     */
    public class AddVeteranResponse {
        @AuraEnabled
        public Boolean patientExists;

        @AuraEnabled
        public Id accountId;

        public AddVeteranResponse(VCC_AddPatientModule.AddVeteranResult addVeteranResult) {
            this.patientExists = addVeteranResult?.patientExists;
            this.accountId = addVeteranResult?.accountId;
        }
    }

    public class ControllerError {
        @AuraEnabled
        public String type { get; private set; }

        @AuraEnabled
        public String message { get; private set; }

        public ControllerError(Exception e) {
            this.type = e.getTypeName();
            this.message = e.getMessage();
        }
    }
}
