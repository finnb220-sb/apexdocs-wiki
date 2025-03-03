/**
 * VCC_UserSelector
 * @description Selector for Users.
 * @author Liberty
 * @date 12/15/2021
 *
 * updated 01/07/2024 by Lung Joe - corrections to satisfy PMD warnings
 */

public with sharing virtual class VCC_UserSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{ User.Id, User.EmployeeNumber, User.FirstName, User.LastName, User.Username };

    /**
     * @description Returns the sobject type of a user
     * @return  `Schema.SObjectType`
     */
    public Schema.SObjectType getSObjectType() {
        return User.SObjectType;
    }

    /**
     * @description Returns the list of fields of the sobjecet type
     * @return  `List<Schema.SObjectField>`
     */
    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }

    /**
     * @description Adds fields to the sObjectFields variable if they aren't already in the list
     * @param sObjectFields
     */
    public void addSObjectFields(List<Schema.SObjectField> sObjectFields) {
        if (sObjectFields != null && !sObjectFields.isEmpty()) {
            for (Schema.SObjectField field : sObjectFields) {
                if (!this.sObjectFields.contains(field)) {
                    this.sObjectFields.add(field);
                }
            }
        }
    }

    /**
     * @description Returns a list of users given the IDs as input
     * @param ids
     * @return  `List<User>`
     */
    public List<User> selectById(Set<Id> ids) {
        return (List<User>) selectSObjectsById(ids);
    }
}
