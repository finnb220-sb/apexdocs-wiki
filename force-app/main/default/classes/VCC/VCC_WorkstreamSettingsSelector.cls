/**
 * @description Workstream Settings Selector
 */

@SuppressWarnings('PMD.ApexDoc')
public with sharing class VCC_WorkstreamSettingsSelector {
    public VCC_Workstream_Settings__mdt settings { public get; private set; }

    public VCC_WorkstreamSettingsSelector(VCC_Enum.VCC_WorkstreamSettingsTypeEnum workstreamSettingsType) {
        if (workstreamSettingsType == null) {
            this.settings = VCC_Workstream_Settings__mdt.getInstance('Default');
        } else {
            this.settings = VCC_Workstream_Settings__mdt.getInstance(workstreamSettingsType.name());
        }
    }
}
