/**
 * @description Test for VCC_PageRefHelper
 *              The class builds a page reference to the flow
 *  */

@IsTest
private class VCC_PageRefHelperTests {
    final static User VAVET_BASE;
    static {
        VAVET_BASE = new VATEST_UserBuilder().withUserProfile('VAVET Base Profile').withStandardData().build(true);
    }

    @IsTest
    static void testGetFlowRedirectPageReferenceValidParameters() {
        // Arrange
        String targetFlowName = 'Test_Flow';
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCC_PageRefHelper pageRefHelper = new VCC_PageRefHelper();
        Pagereference result;

        // Act
        Test.startTest();
        System.runAs(VAVET_BASE) {
            result = pageRefHelper.getFlowRedirectPageReference(targetFlowName, targetRecordId);
        }
        Test.stopTest();

        // Assert
        Assert.areNotEqual(null, result, 'The result should not be null.');
        Assert.areEqual('/flow/Test_Flow?recordId=' + targetRecordId, result.getUrl(), 'The URL does not match the expected format.');
    }

    @IsTest
    static void testGetFlowRedirectPageReferenceWithEmptyFlowName() {
        // Arrange
        String targetFlowName = '';
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCC_PageRefHelper pageRefHelper = new VCC_PageRefHelper();
        Pagereference result;

        // Act
        Test.startTest();
        System.runAs(VAVET_BASE) {
            result = pageRefHelper.getFlowRedirectPageReference(targetFlowName, targetRecordId);
        }
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'The result should be null when the flow name is empty.');
    }

    @IsTest
    static void testGetFlowRedirectPageReferenceWithEmptyRecordId() {
        // Arrange
        String targetFlowName = 'Test_Flow';
        String targetRecordId = '';
        VCC_PageRefHelper pageRefHelper = new VCC_PageRefHelper();
        PageReference result;
        // Act
        Test.startTest();
        System.runAs(VAVET_BASE) {
            result = pageRefHelper.getFlowRedirectPageReference(targetFlowName, targetRecordId);
        }
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'The result should be null when the record ID is empty.');
    }

    @IsTest
    static void testGetFlowRedirectPageReferenceWithNullFlowName() {
        // Arrange
        String targetFlowName = null;
        String targetRecordId = VATEST_IdFactory.get('ServiceAppointment');
        VCC_PageRefHelper pageRefHelper = new VCC_PageRefHelper();
        Pagereference result;

        // Act
        Test.startTest();
        System.runAs(VAVET_BASE) {
            result = pageRefHelper.getFlowRedirectPageReference(targetFlowName, targetRecordId);
        }
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'The result should be null when the flow name is null.');
    }

    @IsTest
    static void testGetFlowRedirectPageReferenceWithNullRecordId() {
        // Arrange
        String targetFlowName = 'Test_Flow';
        String targetRecordId = null;
        VCC_PageRefHelper pageRefHelper = new VCC_PageRefHelper();
        Pagereference result;

        // Act
        Test.startTest();
        System.runAs(VAVET_BASE) {
            result = pageRefHelper.getFlowRedirectPageReference(targetFlowName, targetRecordId);
        }
        Test.stopTest();

        // Assert
        Assert.areEqual(null, result, 'The result should be null when the record ID is null.');
    }
}
