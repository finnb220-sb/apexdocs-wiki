/**
 * Author:Jaren Yach
 *  Created Date 05/12/2022
 *  Purpose: This class is used for querying User_Deactivation_Whitelist__mdt records
 */
public inherited sharing class UserDeactivationWhitelistSelector {
    public List<User_Deactivation_Whitelist__mdt> getAllRecords() {
        return User_Deactivation_Whitelist__mdt.getAll().values();
    }
}
