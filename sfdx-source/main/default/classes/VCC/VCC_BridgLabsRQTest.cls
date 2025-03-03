/**
 * @description VCC Bridg Labs RQ Test
 */

@IsTest
private with sharing class VCC_BridgLabsRQTest {
    @IsTest
    private static void ctor() {
        Integer months = 12;
        VCC_BridgLabsRQ bridgLabsRQ = new VCC_BridgLabsRQ();

        System.assert(bridgLabsRQ != null, 'Expected the class to be initialized.');
        System.assertEquals(null, bridgLabsRQ.nationalId, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.ien, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.assigningAuthority, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.assigningFacility, 'Expected property to be initialized with a different value.');
        System.assertEquals(System.now().addMonths(-months).format('yyyy-MM-dd'), bridgLabsRQ.startDate, 'Expected property to be initialized with a different value.');
        System.assertEquals(System.now().format('yyyy-MM-dd'), bridgLabsRQ.stopDate, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.max, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.type, 'Expected property to be initialized with a different value.');
    }

    @IsTest
    private static void ctorOverride() {
        Integer months = 4;
        VCC_BridgLabsRQ bridgLabsRQ = new VCC_BridgLabsRQ('nationalId', 'assigningAuthority', months);

        System.assert(bridgLabsRQ != null, 'Expected the class to be initialized.');
        System.assertEquals('nationalId', bridgLabsRQ.nationalId, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.ien, 'Expected property to be initialized with a different value.');
        System.assertEquals('assigningAuthority', bridgLabsRQ.assigningAuthority, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.assigningFacility, 'Expected property to be initialized with a different value.');
        System.assertEquals(System.now().addMonths(-months).format('yyyy-MM-dd'), bridgLabsRQ.startDate, 'Expected property to be initialized with a different value.');
        System.assertEquals(System.now().format('yyyy-MM-dd'), bridgLabsRQ.stopDate, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.max, 'Expected property to be initialized with a different value.');
        System.assertEquals(null, bridgLabsRQ.type, 'Expected property to be initialized with a different value.');
    }

    @IsTest
    private static void isValidTrue() {
        VCC_BridgLabsRQ bridgLabsRQ = new VCC_BridgLabsRQ('nationalId', 'assigningAuthority');
        System.assertEquals(true, bridgLabsRQ.isValid(), 'Expected validation to fail.');
    }

    @IsTest
    private static void isValidFalse() {
        VCC_BridgLabsRQ bridgLabsRQ = new VCC_BridgLabsRQ();
        System.assertEquals(false, bridgLabsRQ.isValid(), 'Expected validation to fail.');
    }
}
