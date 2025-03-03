/**
 * @description This class provides methods to fetch organization settings.
 *              The metadata has a field that is a boolean indicating
 *              whether Enable SSO Mocking should be used.
 *
 */
public virtual inherited sharing class VCR_SSOMockingRepo {
    /**
     * @description
     * @param orgId
     * @return      `List<SObject>`
     */
    public List<VCC_Org_Settings__mdt> fetchByOrgId(Id orgId) {
        for (VCC_Org_Settings__mdt orgSetting : VCC_Org_Settings__mdt.getAll().values()) {
            if (orgSetting.vccOrgId__c == orgId) {
                return new List<VCC_Org_Settings__mdt>{ orgSetting };
            }
        }
        return new List<VCC_Org_Settings__mdt>();
    }
}
