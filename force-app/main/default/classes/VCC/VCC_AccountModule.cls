public with sharing class VCC_AccountModule extends VCC_ModuleService.Module {
    private VCC_IdModule idModule = (VCC_IdModule) VCC_ModuleService.getModule(VCC_IdModule.class);

    public String getIcn(Object recordId) {
        if (idModule.isId(recordId) == false) {
            return null;
        }
        return getIcn((Id) recordId);
    }

    public String getIcn(String recordId) {
        if (idModule.isId(recordId) == false) {
            return null;
        }
        return getIcn((Id) recordId);
    }

    public String getIcn(Id recordId) {
        if (idModule.isIdOfType(recordId, Account.getSObjectType()) == false) {
            return null;
        }
        List<Account> accountList = (new VCC_AccountSelector()).selectById(new Set<Id>{ recordId });
        if (accountList == null || accountList.isEmpty()) {
            return null;
        }
        return accountList[0].VCC_MVI_External_Id__pc;
    }

    public void validateAccountId(Object recordId) {
        if (!idModule.isIdOfType(recordId, Account.getSObjectType())) {
            throw new InvalidAccountIdException('The provided Account Id is invalid.');
        }
    }

    public Boolean isRunningUsersAccount(Id recordId) {
        if (!idModule.isIdOfType(recordId, Account.getSObjectType())) {
            throw new InvalidAccountIdException('The provided Account Id is invalid.');
        }

        List<Account> accountList = (new VCC_AccountSelector()).selectById(new Set<Id>{ (Id) recordId });

        if (accountList == null || accountList.isEmpty()) {
            throw new AccountNotFoundException('An Account was not found for the given Id.');
        }

        String icn = [
            SELECT MVIICN__c
            FROM User
            WHERE Id = :UserInfo.getUserId()
            WITH USER_MODE
            LIMIT 1
        ]
        .MVIICN__c;

        if (icn != accountList[0].VCC_MVI_External_Id__pc) {
            return false;
        }

        return true;
    }

    public class InvalidAccountIdException extends Exception {
    }
    public class AccountNotFoundException extends Exception {
    }
}
