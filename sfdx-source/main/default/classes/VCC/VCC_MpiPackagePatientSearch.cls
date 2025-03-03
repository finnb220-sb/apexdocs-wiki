public virtual with sharing class VCC_MpiPackagePatientSearch implements VCC_MpiPackageTrait.PatientSearch {
    @TestVisible
    private static final String ZERO_RESULTS_FOUND_ERROR_TYPE = 'ZeroResultsFound';

    @TestVisible
    private static final String FOUR_ZERO_FOUR_STATUS_CODE = '404';

    @TestVisible
    private static final String NULL_RESPONSE_TEMPLATE = 'An unknown exception occurred in MPIDynamicPersonSearchController.mpiPatientSearch';

    @TestVisible
    private static final String BAD_RESPONSE_TEMPLATE = 'MPIDynamicPersonSearchController.mpiPatientSearch bad response code "{0}", error type "{1}"';

    public virtual MPIDynamicPersonSearchController.ResponseWrap mpiPatientSearch(String reqBody, String businessUnit) {
        try {
            MPIDynamicPersonSearchController.ResponseWrap responseWrap = MPIDynamicPersonSearchController.mpiPatientSearch(reqBody, businessUnit);
            validateResponse(responseWrap);
            return responseWrap;
        } catch (VCC_MpiPackageException mpiPackageException) {
            throw mpiPackageException;
        } catch (Exception e) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.PatientSearch.class, e);
        }
    }

    private void validateResponse(MPIDynamicPersonSearchController.ResponseWrap responseWrap) {
        if (responseWrap == null) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.PatientSearch.class, VCC_MpiPackageException.Kind.NULL_RESPONSE, NULL_RESPONSE_TEMPLATE);
        }

        if (responseWrap.status != '200' || String.isNotBlank(responseWrap?.errorType)) {
            if (responseWrap.status == FOUR_ZERO_FOUR_STATUS_CODE && responseWrap.errorType == ZERO_RESULTS_FOUND_ERROR_TYPE) {
                return;
            }
            throw VCC_MpiPackageException.newFrom(
                VCC_MpiPackageTrait.PatientSearch.class,
                VCC_MpiPackageException.Kind.BAD_RESPONSE,
                BAD_RESPONSE_TEMPLATE,
                new List<String>{ responseWrap.status, responseWrap.errorType }
            );
        }
    }
}
