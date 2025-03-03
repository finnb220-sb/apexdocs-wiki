@IsTest
private with sharing class VCC_EnumTest {
    @IsTest
    static void testCtor() {
        VCC_Enum enumInstance = new VCC_Enum();
        System.assert(enumInstance != null, 'Expected enum class be instantiated');
    }
}
