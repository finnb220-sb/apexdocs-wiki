@IsTest
public with sharing class VCC_ResultTest {
    @IsTest
    static void kind_string_is_correct() {
        Test.startTest();
        try {
            System.Assert.areEqual('ERR', VCC_Result.err(new AuraHandledException('err')).kindString, 'Expected correct string');
            System.Assert.areEqual('OK', VCC_Result.ok('test').kindString, 'Expected correct string');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void ok_constructs() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_Result.Ok('test'), 'Expected non-null value');
            System.Assert.isNotNull(VCC_Result.ok('test'), 'Expected non-null value');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_casts_as_ok() {
        Test.startTest();
        try {
            VCC_Result testResult = VCC_Result.ok('test');
            System.Assert.isNotNull(VCC_Result.asOk(testResult), 'Expected non-null value');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void err_constructs() {
        Test.startTest();
        try {
            System.Assert.isNotNull(new VCC_Result.Err(new AuraHandledException('err')), 'Expected non-null value');
            System.Assert.isNotNull(VCC_Result.err(new AuraHandledException('err')), 'Expected non-null value');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void it_casts_as_err() {
        Test.startTest();
        try {
            VCC_Result testResult = VCC_Result.err(new AuraHandledException('test'));
            System.Assert.isNotNull(VCC_Result.asErr(testResult), 'Expected non-null value');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void isOk_returns_true() {
        Test.startTest();
        try {
            System.Assert.isTrue(VCC_Result.isOk(VCC_Result.ok('test')), 'Expected true');
            System.Assert.isTrue(VCC_Result.isOk(new VCC_Result.Ok('test')), 'Expected true');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void isErr_returns_true() {
        Test.startTest();
        try {
            System.Assert.isTrue(VCC_Result.isErr(VCC_Result.err(new AuraHandledException('err'))), 'Expected true');
            System.Assert.isTrue(VCC_Result.isErr(new VCC_Result.Err(new AuraHandledException('err'))), 'Expected true');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void isOk_returns_false() {
        Test.startTest();
        try {
            System.Assert.isFalse(VCC_Result.isOk(VCC_Result.err(new AuraHandledException('err'))), 'Expected false');
            System.Assert.isFalse(VCC_Result.isOk(new VCC_Result.Err(new AuraHandledException('err'))), 'Expected false');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }

    @IsTest
    static void isErr_returns_false() {
        Test.startTest();
        try {
            System.Assert.isFalse(VCC_Result.isErr(VCC_Result.ok('test')), 'Expected false');
            System.Assert.isFalse(VCC_Result.isErr(new VCC_Result.Ok('test')), 'Expected false');
        } catch (Exception e) {
            System.Assert.fail('Unexpected exception: ' + e.getMessage() + '\n' + e.getStackTraceString());
        }
        Test.stopTest();
    }
}
