public with sharing class VCC_MpiPackageSetCorrelation implements VCC_MpiPackageTrait.SetCorrelation {
    @TestVisible
    private static final String MPIE_CORRELATION_STATUS_SUCCESS_VALUE = System.Label.MPIE_CorrelationStatus_Success_Value;

    @TestVisible
    private static final String UNSUPPORTED_SOJBECT_MESSAGE = 'SObject provided for correlation is not supported or invalid';

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public virtual String setCorrelation(sObject record, String mpiSalesforceFieldName, String mpiVetRecord, String userId, String userName, String businessUnit) {
        String resultString;
        try {
            validateSObject(record);
            resultString = MPIpersonCorrelationController.setCorrelation(record, mpiSalesforceFieldName, mpiVetRecord, userId, userName, businessUnit);
        } catch (VCC_MpiPackageException mpiPackageException) {
            throw mpiPackageException;
        } catch (Exception e) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.SetCorrelation.class, e);
        }
        return resultString;
    }

    public void validateSObject(SObject record) {
        try {
            if (record.Id.getSobjectType() == VA_Identity__c.getSObjectType()) {
                return;
            }
            // if (record.Id.getSobjectType() == Permitted_SObject.class){ return; }
        } catch (Exception e) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.SetCorrelation.class, VCC_MpiPackageException.Kind.UNSUPPORED_SOBJECT, UNSUPPORTED_SOJBECT_MESSAGE);
        }
    }
}
