/**
 * Layer of abstraction to enable stubbing of the MPI package
 */
public with sharing class VCC_MpiPackageConnector {
    @TestVisible
    private static final String VAHC_BUSINESS_UNIT = 'VAHC';

    @TestVisible
    private Traits traits;

    public VCC_MpiPackageConnector(Traits traits) {
        this.traits = traits;
    }

    public VCC_MpiPackageConnector() {
        this(new Traits());
    }

    public MPIDynamicPersonSearchController.MpiFieldMappingWrap getIdentityFieldMapping() {
        return this.traits.getIdentityFieldMappingImpl.getCustomMetadataMpiFieldMapping(VAHC_BUSINESS_UNIT);
    }

    public MPIDynamicPersonSearchController.ResponseWrap mpiPatientSearch(String reqBody) {
        return this.traits.patientSearchImpl.mpiPatientSearch(reqBody, VAHC_BUSINESS_UNIT);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public sObject saveForm(String objectApiName, String mpiSalesforceInsertFieldMap, String mpiVetRecord, String userName) {
        return this.traits.saveFormImpl.saveForm(objectApiName, mpiSalesforceInsertFieldMap, mpiVetRecord, VAHC_BUSINESS_UNIT, userName);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public String setCorrelation(sObject record, String mpiSalesforceFieldName, String mpiVetRecord, String userId, String userName) {
        return this.traits.setCorrelationImpl.setCorrelation(record, mpiSalesforceFieldName, mpiVetRecord, userId, userName, VAHC_BUSINESS_UNIT);
    }

    public class Traits {
        public VCC_MpiPackageTrait.PatientSearch patientSearchImpl {
            get {
                if (patientSearchImpl == null) {
                    patientSearchImpl = new VCC_MpiPackagePatientSearch();
                }
                return patientSearchImpl;
            }
            set;
        }

        public VCC_MpiPackageTrait.SaveForm saveFormImpl {
            get {
                if (saveFormImpl == null) {
                    saveFormImpl = new VCC_MpiPackageSaveForm();
                }
                return saveFormImpl;
            }
            set;
        }

        public VCC_MpiPackageTrait.SetCorrelation setCorrelationImpl {
            get {
                if (setCorrelationImpl == null) {
                    setCorrelationImpl = new VCC_MpiPackageSetCorrelation();
                }
                return setCorrelationImpl;
            }
            set;
        }

        public VCC_MpiPackageTrait.GetIdentityFieldMapping getIdentityFieldMappingImpl {
            get {
                if (getIdentityFieldMappingImpl == null) {
                    getIdentityFieldMappingImpl = new VCC_MpiPackageGetFieldMapping();
                }
                return getIdentityFieldMappingImpl;
            }
            set;
        }
    }
}
