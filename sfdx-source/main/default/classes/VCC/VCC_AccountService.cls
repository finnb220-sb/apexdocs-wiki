public with sharing class VCC_AccountService {
    public static VCC_AccountService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_AccountService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_AccountService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub accountServiceStub = new VCC_Stub(VCC_AccountService.class);
        VCC_AccountService.privateInstance = (VCC_AccountService) accountServiceStub.instance;
        return accountServiceStub;
    }

    public String getIcn(Object recordId) {
        if (VCC_IdService.instance.isId(recordId) == false) {
            return null;
        }
        return getIcn((Id) recordId);
    }

    public String getIcn(String recordId) {
        if (VCC_IdService.instance.isId(recordId) == false) {
            return null;
        }
        return getIcn((Id) recordId);
    }

    public String getIcn(Id recordId) {
        if (VCC_IdService.instance.isIdOfType(recordId, Account.getSObjectType()) == false) {
            return null;
        }
        List<Account> accountList = (new VCC_AccountSelector()).selectById(new Set<Id>{ recordId });
        if (accountList == null || accountList.isEmpty()) {
            return null;
        }
        return accountList[0].VCC_MVI_External_Id__pc;
    }

    class AccountServiceException extends Exception {
    }
}
