/**
 * @description This class represents an HTTP header field specifically for the Conversation ID.
 * @author      Booz Allen Hamilton
 * @see         VCC_HttpHeaderConversationIdTest
 */
public with sharing class VCC_HttpHeaderConversationId extends VCC_HttpHeaderField {
    public static final String HEADER_NAME = System.label.VCC_HeaderName_ConversationId;

    /**
     * @description Constructor for VCC_HttpHeaderConversationId. Initializes the header name and value by calling the superclass constructor.
     * @param value The value of the ConversationID header.
     */

    public VCC_HttpHeaderConversationId(VCC_TransactionId value) {
        super(HEADER_NAME, validateValue(value));
    }

    private static String validateValue(VCC_TransactionId value) {
        if (value == null) {
            throw new IllegalArgumentException(
                'Failed to construct VCC_HttpHeaderConversationId, argument VCC_TransactionId is null'
            );
        }
        return value.toString();
    }
}
