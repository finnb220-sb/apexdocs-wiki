/**
 * @description Vdif Ecnounter object
 *
 * @author Liberty
 * @since 01/07/2024
 * @group VAHC
 */
public with sharing class VCC_VdifEncounter {
    @AuraEnabled
    public String noteTitleIen;

    @AuraEnabled
    public String locationIen;

    @AuraEnabled
    public String consultIen;

    @AuraEnabled
    public String serviceCategory;

    @AuraEnabled
    public String providers;

    @AuraEnabled
    public String procedures;

    @AuraEnabled
    public String diagnoses;

    @AuraEnabled
    public String immunizations;

    @AuraEnabled
    public String healthFactors;

    @AuraEnabled
    public String visitRelatedTos;

    @AuraEnabled
    public String comments;
}
