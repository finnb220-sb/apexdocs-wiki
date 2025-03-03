public virtual with sharing class VCC_MpiPackageSaveForm implements VCC_MpiPackageTrait.SaveForm {
    @TestVisible
    private static final String BAD_SOBJECT_TYPE_TEMPLATE = 'Unable to execute MPIDynamicPersonSearchController.saveForm because "{0}" is not an SObject';

    @TestVisible
    private static final String SAVE_FORM_INSERT_FAILED_TEMPLATE = 'MPIDynamicPersonSearchController.saveForm failed to insert a new record due to an unknown error.';

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public virtual sObject saveForm(String objectApiName, String mpiSalesforceInsertFieldMap, String mpiVetRecord, String businessUnit, String userName) {
        SObject resultingSObject;
        try {
            validateSObjectApiName(objectApiName);
            resultingSObject = MPIDynamicPersonSearchController.saveForm(objectApiName, mpiSalesforceInsertFieldMap, mpiVetRecord, businessUnit, userName);
            validateResult(resultingSObject);
            return resultingSObject;
        } catch (VCC_MpiPackageException mpiPackageException) {
            throw mpiPackageException;
        } catch (Exception e) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.SaveForm.class, e);
        }
    }

    protected void validateSObjectApiName(String objectApiName) {
        if (objectApiName == null || System.Type.forName(objectApiName) == null || !SObject.class.isAssignableFrom(System.Type.forName(objectApiName))) {
            throw VCC_MpiPackageException.newFrom(
                VCC_MpiPackageTrait.SaveForm.class,
                VCC_MpiPackageException.Kind.UNSUPPORED_SOBJECT,
                BAD_SOBJECT_TYPE_TEMPLATE,
                new List<String>{ objectApiName }
            );
        }
    }

    private void validateResult(SObject resultingSObject) {
        if (resultingSObject == null || resultingSObject.get('Id') == null) {
            throw VCC_MpiPackageException.newFrom(VCC_MpiPackageTrait.SaveForm.class, VCC_MpiPackageException.Kind.INSERT_FAILED, SAVE_FORM_INSERT_FAILED_TEMPLATE);
        }
    }
}
