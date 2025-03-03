public with sharing class VCC_IdModule extends VCC_ModuleService.Module {
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

    public Boolean isIdOfType(Object recordId, SobjectType sobjectType) {
        if (this.isId(recordId) == false) {
            return false;
        }
        return this.isIdOfType((Id) recordId, sobjectType);
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
