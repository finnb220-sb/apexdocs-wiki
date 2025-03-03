public with sharing class VCC_IdService {
    public static VCC_IdService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_IdService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_IdService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub idService = new VCC_Stub(VCC_IdService.class);
        VCC_IdService.privateInstance = (VCC_IdService) idService.instance;
        return idService;
    }

    public Boolean isId(Object possibleId) {
        if (possibleId == null) {
            return false;
        }
        try {
            Id recordId = (Id) possibleId;
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    public Boolean isIdOfType(Id recordId, SobjectType sobjectType) {
        if (recordId == null || sobjectType == null) {
            return false;
        }
        try {
            if (recordId.getSobjectType() === sobjectType) {
                return true;
            }
            return false;
        } catch (System.SObjectException e) {
            return false;
        }
    }
}
