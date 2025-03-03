@IsTest
private class VCC_PharmacyLogRQTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     **/
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }

    @IsTest
    static void testIsValidTrue() {
        System.runAs(getTestUser()) {
            // Arrange
            VCC_PharmacyLogRQ rq = new VCC_PharmacyLogRQ('facility1', 'prescription1');

            // Act/Assert
            System.assertEquals(true, rq.isValid(), 'Expected Valid RQ');
        }
    }

    @IsTest
    static void testIsValidFalse() {
        System.runAs(getTestUser()) {
            // Arrange
            VCC_PharmacyLogRQ rq = new VCC_PharmacyLogRQ(null, 'prescription1');

            // Act/Assert
            System.assertEquals(false, rq.isValid(), 'Expected bad RQ');
        }
    }

    @IsTest
    static void testConstructorWithMap() {
        System.runAs(getTestUser()) {
            // Arrange
            Map<String, Object> jsObject = new Map<String, Object>{ 'facilityId' => 'facility1', 'prescriptionId' => 'prescription1' };

            // Act
            VCC_PharmacyLogRQ rq = new VCC_PharmacyLogRQ(jsObject);

            // Assert
            System.assertEquals('facility1', rq.facilityId, 'Expected facility id to be facility1');
            System.assertEquals('prescription1', rq.prescriptionId, 'Expected prescriptionid to be prescription1');
        }
    }

    @IsTest
    static void testConstructorWithMapNullInput() {
        System.runAs(getTestUser()) {
            // Arrange
            Map<String, Object> jsObject = new Map<String, Object>{ 'facilityId' => null, 'prescriptionId' => 'prescription1' };

            // Act
            VCC_PharmacyLogRQ rq = new VCC_PharmacyLogRQ(jsObject);

            // Assert
            System.assertEquals(null, rq.facilityId, 'Expected facility id to be null');
            System.assertEquals('prescription1', rq.prescriptionId, 'Expected prescription id to be prescription1');
        }
    }
}
