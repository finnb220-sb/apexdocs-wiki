public with sharing class VCC_MainMenuAccessUtility {
    /*
    public static List<String> getAccessibleTabs(String profileName){
        List<String> accessSet = new List<String>();
        List<VCC_Main_Menu_Access__mdt> mainMenuAccessList  =
            [
                SELECT  
                    Id,
                    VCC_Tab_Name__c,
                    VCC_Tab_Order__c
                FROM VCC_Main_Menu_Access__mdt
                //WHERE Profile__c =: profileName
                ORDER BY VCC_Tab_Order__c asc
            ];
        for(VCC_Main_Menu_Access__mdt mainMenuAccess : mainMenuAccessList){
            accessSet.add(mainMenuAccess.VCC_Tab_Name__c);
        }
        return accessSet;
    }
    */

    public static List<String> getAccessibleTabs(List<String> permissionSetNames) {
        List<String> accessSet = new List<String>();
        List<VCC_Main_Menu_Access__mdt> mainMenuAccessList = [
            SELECT Id, VCC_Tab_Name__c, VCC_Permission_Set__c, VCC_Tab_Order__c
            FROM VCC_Main_Menu_Access__mdt
            WHERE VCC_Permission_Set__c IN :permissionSetNames
            WITH SECURITY_ENFORCED
            ORDER BY VCC_Tab_Order__c ASC
        ];
        for (VCC_Main_Menu_Access__mdt mainMenuAccess : mainMenuAccessList) {
            accessSet.add(mainMenuAccess.VCC_Tab_Name__c);
        }
        return accessSet;
    }
}
