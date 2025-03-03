/**
 * @description Vdif Note Object
 *
 * @author Liberty
 * @since 01/08/2024
 * @group VAHC
 */
public with sharing class VCC_VdifNote {
    @AuraEnabled
    public List<String> additionalSigners;

    @AuraEnabled
    public String itemId;

    @AuraEnabled
    public String encounterString;

    @AuraEnabled
    public String noteTitleIen;

    @AuraEnabled
    public String consultIen;

    @AuraEnabled
    public String prfIen;

    @AuraEnabled
    public String text;

    /**
     * @description default constructor
     */
    public VCC_VdifNote() {
        this.additionalSigners = new List<String>();
    }
}
