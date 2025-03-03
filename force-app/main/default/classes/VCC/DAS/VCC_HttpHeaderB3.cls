/**
 * @description This class represents an HTTP header field specifically for the B3 Header
 * @author      Booz Allen Hamilton
 * @see         VCC_HttpHeaderField
 */
public with sharing class VCC_HttpHeaderB3 extends VCC_HttpHeaderField {
    public static final String VCC_HEADER_NAME_B3 = System.label.VCC_HeaderName_B3;

    /**
     * @description Constructor
     * @param transactionId `VCC_TransactionId` used to identify the transaction
     */
    public VCC_HttpHeaderB3(VCC_TransactionId transactionId) {
        super(VCC_HEADER_NAME_B3, String.valueOf(transactionId));
    }
}
