/**
 * VCC_UoWDomain
 * @description VCC_UoWDomain class for creating units of work.
 * @author Liberty
 * @date 1/16/2024
 */

public with sharing class VCC_UoWDomain {
    /**
     * @description creating a unit of work
     */
    public static fflib_SObjectUnitOfWork createUoW() {
        return new fflib_SObjectUnitOfWork(
            new List<Schema.SObjectType>{
                Account.SObjectType,
                Contact.SObjectType,
                Opportunity.SObjectType,
                Case.SObjectType,
                Task.SObjectType,
                VCC_Progress_Note__c.SObjectType,
                VCC_Update_UI__e.SObjectType,
                VA_Identity__c.SObjectType
            }
        );
    }
}
