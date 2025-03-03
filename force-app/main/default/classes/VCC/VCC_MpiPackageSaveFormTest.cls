@IsTest
public with sharing class VCC_MpiPackageSaveFormTest {
    @IsTest
    static void it_constructs() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_MpiPackageSaveForm(), 'Expected a non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_throws_an_exception_when_sobject_name_is_not_valid() {
        String badSObjectName = 'VCC_VdifClient';

        Test.startTest();
        try {
            VCC_MpiPackageSaveForm mpiPackageSaveForm = new VCC_MpiPackageSaveForm();
            mpiPackageSaveForm.saveForm(badSObjectName, '', '', 'VAHC', 'Test');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected an exception of type VCC_MpiPackageException.');
            System.Assert.areEqual(VCC_MpiPackageException.Kind.UNSUPPORED_SOBJECT, ((VCC_MpiPackageException) e).kind, 'Expected correct exception Kind.');
            System.Assert.isTrue(e.getMessage().contains(badSObjectName), 'Expected bad SObject name to be present in exception message.');
        }
        Test.stopTest();
    }

    @IsTest
    static void it_throws_an_exception_when_saveForm_fails_to_insert_record() {
        Test.startTest();
        try {
            VCC_MpiPackageSaveForm mpiPackageSaveForm = new VCC_MpiPackageSaveForm();
            mpiPackageSaveForm.saveForm('Account', JSON.serialize(new Map<String, Object>{}), JSON.serialize(new Map<String, Object>{}), 'VAHC', 'Test');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected an exception of type VCC_MpiPackageException.');
            System.Assert.areEqual(VCC_MpiPackageException.Kind.INSERT_FAILED, ((VCC_MpiPackageException) e).kind, 'Expected correct exception Kind.');
            System.Assert.isTrue(e.getMessage().contains(VCC_MpiPackageSaveForm.SAVE_FORM_INSERT_FAILED_TEMPLATE), 'Expected correct exception message.');
        }
        Test.stopTest();
    }

    @IsTest
    static void it_succeeds() {
        Test.startTest();
        try {
            VCC_MpiPackageSaveForm mpiPackageSaveForm = new VCC_MpiPackageSaveForm();
            mpiPackageSaveForm.saveForm('VA_Identity__c', JSON.serialize(new Map<String, Object>{}), JSON.serialize(new Map<String, Object>{}), 'VAHC', 'Test');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
