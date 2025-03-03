/**
 * @description Unit tests for the VCC_HttpHeaderConversationId class.
 */
@IsTest
private with sharing class VCC_HttpHeaderConversationIdTest {
    /**
     * @description
     * This test:
     * 1. Verifies the header name is set correctly
     * 2. Verifies the value is set correctly
     * 3. Verifies the IllegalArgumentException is thrown when the TransactionId is null
     */
    @IsTest
    static void unitTestHttpHeaderConversationIdWithAValidTransactionIdPositive() {
        VCC_TransactionId headerValue = new VCC_TransactionId(
            VCC_DAS.Endpoint.CREATE_ADDENDUM,
            VATEST_IdFactory.get('VCC_Progress_Note__c')
        );
        VCC_HttpHeaderConversationId header = new VCC_HttpHeaderConversationId(headerValue);

        Test.startTest();
        Assert.areEqual(
            VCC_HttpHeaderConversationId.HEADER_NAME,
            header.name,
            'Expected the header name to match the custom label'
        );
        Assert.areEqual(headerValue.toString(), header.value, 'Expected the header value to match the provided value');
        Test.stopTest();
    }

    /**
     * @description This test verifies that an IllegalArgumentException is thrown when the TransactionId is null
     */
    @IsTest
    static void unitTestHttpHeaderConversationIdWithANullTransactionIdNegative() {
        Test.startTest();
        try {
            new VCC_HttpHeaderConversationId(null);
            Assert.fail('Expected IllegalArgumentException was not thrown');
        } catch (IllegalArgumentException e) {
            Assert.areEqual(
                'Failed to construct VCC_HttpHeaderConversationId, argument VCC_TransactionId is null',
                e.getMessage(),
                'Exception message does not match'
            );
        }
    }
}
