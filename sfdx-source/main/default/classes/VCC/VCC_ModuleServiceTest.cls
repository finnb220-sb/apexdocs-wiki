@IsTest
public with sharing class VCC_ModuleServiceTest {
    public class VCC_ModuleServiceTestModuleFail extends VCC_ModuleService.Module {
    }

    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    static void getModuleTestSad1() {
        System.runAs(getTestUser()) {
            VCC_ModuleService.ModuleServiceException expectedException;

            Test.startTest();
            try {
                VCC_ModuleService.getModule(VCC_ModuleServiceTest_ModuleSad1.class);
            } catch (VCC_ModuleService.ModuleServiceException e) {
                expectedException = e;
            }
            Test.stopTest();

            System.assert(expectedException != null, 'Expected an exception.');
            System.assert(expectedException.getMessage().contains(VCC_ModuleService.DOES_NOT_IMPLEMENT_MODULE_INTERFACE), 'Expected correct exception message.');
        }
    }

    @IsTest
    static void getModuleTestSad2() {
        System.runAs(getTestUser()) {
            VCC_ModuleService.ModuleServiceException expectedException;

            Test.startTest();
            try {
                VCC_ModuleService.getModule(VCC_ModuleServiceTest_ModuleSad2.class);
            } catch (VCC_ModuleService.ModuleServiceException e) {
                expectedException = e;
            }
            Test.stopTest();

            System.assert(expectedException != null, 'Expected an exception.');
            System.assert(expectedException.getMessage().contains(VCC_ModuleService.NO_SYSTEM_BATCHABLE_MODULE), 'Expected correct exception message.');
        }
    }

    @IsTest
    static void getModuleTestSad4() {
        System.runAs(getTestUser()) {
            VCC_ModuleService.ModuleServiceException expectedException;

            Test.startTest();
            try {
                VCC_ModuleService.getModule(VCC_ModuleServiceTest.VCC_ModuleServiceTestModuleFail.class);
            } catch (VCC_ModuleService.ModuleServiceException e) {
                expectedException = e;
            }
            Test.stopTest();

            System.assert(expectedException != null, 'Expected an exception.');
            System.assert(expectedException.getMessage().contains(VCC_ModuleService.NO_INNER_CLASS_MODULE), 'Expected correct exception message.');
        }
    }

    @IsTest
    static void badModuleConstruction() {
        System.runAs(getTestUser()) {
            VCC_ModuleService.ModuleServiceException expectedException;

            Test.startTest();
            try {
                new VCC_ModuleServiceTest.VCC_ModuleServiceTestModuleFail();
            } catch (VCC_ModuleService.ModuleServiceException e) {
                expectedException = e;
            }
            Test.stopTest();

            System.assert(expectedException != null, 'Expected an exception.');
            System.assert(expectedException.getMessage().contains(VCC_ModuleService.BAD_CONSTRUCTION), 'Expected correct exception message.');
        }
    }

    @IsTest
    static void getModuleTestHappy() {
        System.runAs(getTestUser()) {
            Test.startTest();
            System.assert(VCC_ModuleService.getModule(VCC_ModuleServiceTest_ModuleHappy.class) != null, 'Expected non-null.');
            Test.stopTest();
        }
    }

    @IsTest
    static void stubModuleTest() {
        System.runAs(getTestUser()) {
            VCC_Stub testModuleStub = VCC_ModuleService.stubModule(VCC_ModuleServiceTest_ModuleHappy.class);

            Test.startTest();
            System.assert(VCC_ModuleService.getModule(VCC_ModuleServiceTest_ModuleHappy.class) === testModuleStub.instance, 'Expected module instance to be the stub.');
            Test.stopTest();
        }
    }

    @IsTest
    static void validateAllModules() {
        System.runAs(getTestUser()) {
            Test.startTest();
            for (ApexTypeImplementor typeImplementor : [SELECT ClassName FROM ApexTypeImplementor WHERE InterfaceName = 'VCC_ModuleService.Module']) {
                if (typeImplementor.ClassName.contains('VCC_ModuleServiceTest')) {
                    continue;
                }
                VCC_ModuleService.validateAndInstantiate(Type.forName(typeImplementor.ClassName));
            }
            System.assert(true, 'Implied assert.');
            Test.stopTest();
        }
    }
}
