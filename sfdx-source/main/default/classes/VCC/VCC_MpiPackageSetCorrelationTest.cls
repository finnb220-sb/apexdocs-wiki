@IsTest
public with sharing class VCC_MpiPackageSetCorrelationTest {
    @IsTest
    static void it_constructs() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_MpiPackageSetCorrelation(), 'Expected a non-null value.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_throws_an_exception_when_sobject_is_not_supported() {
        VCC_MpiPackageSetCorrelation mpiPackageSetCorrelation = new VCC_MpiPackageSetCorrelation();
        SObject testRecord = (SObject) new VCC_Progress_Note__c();
        Test.startTest();
        try {
            mpiPackageSetCorrelation.setCorrelation(testRecord, '', '', '', '', '');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected correct exception type.');
            VCC_MpiPackageException mpiPackageException = (VCC_MpiPackageException) e;
            System.Assert.areEqual(VCC_MpiPackageException.Kind.UNSUPPORED_SOBJECT, mpiPackageException.kind, 'Expected correct exception kind.');
            System.Assert.isTrue(e.getMessage().contains(VCC_MpiPackageSetCorrelation.UNSUPPORTED_SOJBECT_MESSAGE), 'Expected correct exception message.');
        }
        Test.stopTest();
    }

    @IsTest
    static void it_throws_an_exception_when_sobject_has_no_id() {
        VCC_MpiPackageSetCorrelation mpiPackageSetCorrelation = new VCC_MpiPackageSetCorrelation();
        SObject testRecord = (SObject) new VA_Identity__c();
        Test.startTest();
        try {
            mpiPackageSetCorrelation.setCorrelation(testRecord, '', '', '', '', '');
            System.Assert.fail('Expected an exception.');
        } catch (Exception e) {
            System.Assert.isInstanceOfType(e, VCC_MpiPackageException.class, 'Expected correct exception type.');
            VCC_MpiPackageException mpiPackageException = (VCC_MpiPackageException) e;
            System.Assert.areEqual(VCC_MpiPackageException.Kind.UNSUPPORED_SOBJECT, mpiPackageException.kind, 'Expected correct exception kind.');
            System.Assert.isTrue(e.getMessage().contains(VCC_MpiPackageSetCorrelation.UNSUPPORTED_SOJBECT_MESSAGE), 'Expected correct exception message.');
        }
        Test.stopTest();
    }

    @IsTest
    static void it_runs() {
        VCC_MpiPackageSetCorrelation mpiPackageSetCorrelation = new VCC_MpiPackageSetCorrelation();
        VA_Identity__c vaId = new VA_Identity__c();
        insert vaId;

        Test.startTest();
        try {
            mpiPackageSetCorrelation.setCorrelation((SObject) vaId, JSON.serialize(new Map<String, Object>{}), JSON.serialize(new Map<String, Object>{}), '', '', '');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
