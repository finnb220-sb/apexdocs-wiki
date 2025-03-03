public with sharing class VCC_MpiPackageTrait {
    public VCC_MpiPackageTrait() {
        return; // for test coverage
    }

    public interface PatientSearch {
        MPIDynamicPersonSearchController.ResponseWrap mpiPatientSearch(String reqBody, String businessUnit);
    }

    public interface SaveForm {
        sObject saveForm(String objectApiName, String mpiSalesforceInsertFieldMap, String mpiVetRecord, String businessUnit, String userName);
    }

    public interface SetCorrelation {
        String setCorrelation(sObject record, String mpiSalesforceFieldName, String mpiVetRecord, String userId, String userName, String businessUnit);
    }

    public interface GetIdentityFieldMapping {
        MPIDynamicPersonSearchController.MpiFieldMappingWrap getCustomMetadataMpiFieldMapping(String businessUnit);
    }
}
