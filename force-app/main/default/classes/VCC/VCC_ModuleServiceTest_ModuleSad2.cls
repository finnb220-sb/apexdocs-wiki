@isTest
public with sharing class VCC_ModuleServiceTest_ModuleSad2 extends VCC_ModuleService.Module implements Database.Batchable<Account> {
    public List<Account> start(Database.BatchableContext bc) {
        return null;
    }
    public void execute(Database.BatchableContext bc, List<Account> al) {
        return;
    }
    public void finish(Database.BatchableContext bc) {
        return;
    }
}
