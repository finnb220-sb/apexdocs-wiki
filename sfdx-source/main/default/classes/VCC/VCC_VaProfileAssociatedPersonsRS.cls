/**
 * @description VCC_VaProfileAssociatedPersonsRS object definition
 * @author Liberty
 * @since 01/07/2024
 */
public with sharing class VCC_VaProfileAssociatedPersonsRS {
    // example: SUCCESS
    // Status
    @AuraEnabled
    public String status;

    // example: 6cbbf5ad-c7ab-45fd-8ffb-ddac4dc5b453
    // Tx Audit Id
    @AuraEnabled
    public String txAuditId;

    // example: VHA ES Update Service returned message: ...
    // Message
    @AuraEnabled
    public String message;
}
