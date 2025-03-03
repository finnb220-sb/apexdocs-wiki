@IsTest
public with sharing class VCC_MpiPackageExceptionTest {
    @IsTest
    static void it_creates_an_exception_from_type_kind_and_string() {
        VCC_MpiPackageException.Kind kind = VCC_MpiPackageException.Kind.FOR_UNIT_TEST;
        System.Type packageTrait = VCC_MpiPackageTrait.PatientSearch.class;
        String message = 'test';

        Test.startTest();
        try {
            VCC_MpiPackageException mpiPackageException = VCC_MpiPackageException.newFrom(packageTrait, kind, message);
            System.Assert.isNotNull(mpiPackageException, 'Expected non-null value');
            System.Assert.isTrue(mpiPackageException.getMessage().contains(mpiPackageException.transactionId), 'Expected transaction Id in message.');
            System.Assert.areEqual(kind, mpiPackageException.kind, 'Expected to find test value.');
            System.Assert.areEqual(packageTrait, mpiPackageException.packageTrait, 'Expected to find test value.');
            System.Assert.isTrue(mpiPackageException.getMessage().contains('test'), 'Expected to find value in exception message.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_creates_an_exception_from_type_kind_stringToFormat_and_formattingArguments() {
        VCC_MpiPackageException.Kind kind = VCC_MpiPackageException.Kind.FOR_UNIT_TEST;
        System.Type packageTrait = VCC_MpiPackageTrait.PatientSearch.class;
        String stringToFormat = 'test {0}';
        List<String> formattingArguments = new List<String>{ 'test' };

        Test.startTest();
        try {
            VCC_MpiPackageException mpiPackageException = VCC_MpiPackageException.newFrom(packageTrait, kind, stringToFormat, formattingArguments);
            System.Assert.isNotNull(mpiPackageException, 'Expected non-null value');
            System.Assert.isTrue(mpiPackageException.getMessage().contains(mpiPackageException.transactionId), 'Expected transaction Id in message.');
            System.Assert.areEqual(kind, mpiPackageException.kind, 'Expected to find test value.');
            System.Assert.areEqual(packageTrait, mpiPackageException.packageTrait, 'Expected to find test value.');
            System.Assert.isTrue(mpiPackageException.getMessage().contains('test test'), 'Expected to find formatted value in exception message.');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_creates_an_exception_from_type_and_exception() {
        System.Type packageTrait = VCC_MpiPackageTrait.PatientSearch.class;
        AuraHandledException testException = new AuraHandledException('test');

        Test.startTest();
        try {
            VCC_MpiPackageException mpiPackageException = VCC_MpiPackageException.newFrom(packageTrait, testException);
            System.Assert.isNotNull(mpiPackageException, 'Expected non-null value');
            System.Assert.isTrue(mpiPackageException.getMessage().contains(mpiPackageException.transactionId), 'Expected transaction Id in message.');
            System.Assert.areEqual(VCC_MpiPackageException.Kind.OTHER_CAUSE_EXCEPTION, mpiPackageException.kind, 'Expected to find OTHER_CAUSE_EXCEPTION kind.');
            System.Assert.areEqual(packageTrait, mpiPackageException.packageTrait, 'Expected to find test value.');
            System.Assert.isTrue(
                mpiPackageException.getMessage()
                    .contains(
                        String.format(
                            VCC_MpiPackageException.EXCEPTION_CAUSE_CONSTRUCTOR_TEMPLATE,
                            new List<String>{ String.valueOf(testException), testException.getStackTraceString() }
                        )
                    ),
                'Expected to find value in exception message.'
            );
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
