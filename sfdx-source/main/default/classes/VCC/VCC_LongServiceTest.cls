@IsTest
public with sharing class VCC_LongServiceTest {
    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub longServiceStub = VCC_LongService.stub();
        System.assert(longServiceStub.instance === VCC_LongService.instance, 'Expected stub instance and service instance to be the same.');
        Test.stopTest();
    }

    @IsTest
    static void minTest() {
        Test.startTest();
        Long l_1 = 1;
        Long l_2 = 2;
        Long l_3 = 12;
        Long l_4 = null;

        System.assert(VCC_LongService.instance.min(l_1, l_2) == l_1, 'Extected the minimum of the two Longs.');
        System.assert(VCC_LongService.instance.min(l_2, l_1) == l_1, 'Extected the minimum of the two Longs.');
        System.assert(VCC_LongService.instance.min(l_4, l_3) == l_3, 'Extected the minimum of the two Longs.');
        System.assert(VCC_LongService.instance.min(l_3, l_4) == l_3, 'Extected the minimum of the two Longs.');
        Test.stopTest();
    }

    @IsTest
    static void maxTest() {
        Test.startTest();
        Long l_1 = 1;
        Long l_2 = 2;
        Long l_3 = 12;
        Long l_4 = null;

        System.assert(VCC_LongService.instance.max(l_1, l_2) == l_2, 'Extected the maximum of the two Longs.');
        System.assert(VCC_LongService.instance.max(l_2, l_1) == l_2, 'Extected the maximum of the two Longs.');
        System.assert(VCC_LongService.instance.max(l_4, l_3) == l_3, 'Extected the maximum of the two Longs.');
        System.assert(VCC_LongService.instance.max(l_3, l_4) == l_3, 'Extected the maximum of the two Longs.');
        Test.stopTest();
    }

    @IsTest
    static void valueOfTest() {
        Test.startTest();
        System.assert(VCC_LongService.instance.valueOf(null) == null, 'Expected null.');
        System.assert(VCC_LongService.instance.valueOf('') == null, 'Expected null.');
        System.assert(VCC_LongService.instance.valueOf('abcd1') == null, 'Expected null.');
        System.assert(VCC_LongService.instance.valueOf('0') == 0, 'Expected zero.');
        System.assert(VCC_LongService.instance.valueOf('-100') == -100, 'Expected -100.');
        System.assert(VCC_LongService.instance.valueOf('100') == 100, 'Expected 100.');
        Test.stopTest();
    }

    @IsTest
    static void intValueTest() {
        Test.startTest();
        Long l = 31531;
        System.assert(l.intValue() == VCC_LongService.instance.intValue(l), 'Expected values to match.');
        Test.stopTest();
    }

    @IsTest
    static void formatTest() {
        Test.startTest();
        Long l = 5819573;
        System.assert(l.format() == VCC_LongService.instance.format(l), 'Expected values to match.');
        Test.stopTest();
    }
}
