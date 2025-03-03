public virtual with sharing class VCC_MpiPackageException extends Exception {
    @TestVisible
    private static final String STRING_CONSTRUCTOR_TEMPLATE = '({0}) {1}';

    @TestVisible
    private static final String EXCEPTION_CAUSE_CONSTRUCTOR_TEMPLATE = 'An exception occurred caused by: \n{0}';

    public static final String MISSING_BUSINESS_UNIT_MESSAGE = 'Business unit was not specified.';

    @AuraEnabled
    public Kind kind;

    @AuraEnabled
    public Type packageTrait;

    @AuraEnabled
    public String transactionId = System.Request.getCurrent().getRequestId();

    public enum Kind {
        //general
        FOR_UNIT_TEST,
        MISSING_BUSINESS_UNIT,
        OTHER_CAUSE_EXCEPTION,
        UNSUPPORED_SOBJECT,
        NULL_RESPONSE,
        BAD_RESPONSE,
        INSERT_FAILED
    }

    private VCC_MpiPackageException setFields(System.Type packageTrait, Kind exceptionKind, String message) {
        this.setMessage(String.format(STRING_CONSTRUCTOR_TEMPLATE, new List<String>{ this.transactionId, message }));
        this.kind = exceptionKind;
        this.packageTrait = packageTrait;
        return this;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    private VCC_MpiPackageException setFields(System.Type packageTrait, Kind exceptionKind, String stringToFormat, List<String> formattingArguments) {
        return this.setFields(packageTrait, exceptionKind, String.format(stringToFormat, formattingArguments));
    }

    public static VCC_MpiPackageException newFrom(System.Type packageTrait, Kind exceptionKind, String message) {
        VCC_MpiPackageException mpiPackageException = new VCC_MpiPackageException();
        return mpiPackageException.setFields(packageTrait, exceptionKind, message);
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public static VCC_MpiPackageException newFrom(System.Type packageTrait, Kind exceptionKind, String stringToFormat, List<String> formattingArguments) {
        VCC_MpiPackageException mpiPackageException = new VCC_MpiPackageException();
        return mpiPackageException.setFields(packageTrait, exceptionKind, stringToFormat, formattingArguments);
    }

    public static VCC_MpiPackageException newFrom(System.Type packageTrait, Exception e) {
        VCC_MpiPackageException mpiPackageException = new VCC_MpiPackageException(e);
        return mpiPackageException.setFields(packageTrait, Kind.OTHER_CAUSE_EXCEPTION, EXCEPTION_CAUSE_CONSTRUCTOR_TEMPLATE, new List<String>{ String.valueOf(e) });
    }
}
