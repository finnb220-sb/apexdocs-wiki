/**
 * Author:Jaren Yach
 *  Created Date 05/06/2022
 *  Purpose: This class  is used to query Organization records
 */
public inherited sharing class OrganizationSelector {
    /**
     * Gets the Organization record
     * @return Organization record
     */
    public Organization getRecord() {
        return [SELECT Id, Name, InstanceName, IsSandbox FROM Organization][0];
    }
}
