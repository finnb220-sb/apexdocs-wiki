/**
 * Author:Jaren Yach
 *  Created Date 05/06/2022
 *  Purpose: This class is used for querying DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt records
 */
public inherited sharing class ProfileIpWhitelistSettingSelector {
    public List<DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt> getAllRecords() {
        return DTC_Sandbox_Refresh_Profile_Ip_Whitelist__mdt.getAll().values();
    }
}
