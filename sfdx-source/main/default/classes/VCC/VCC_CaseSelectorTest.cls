@IsTest
public with sharing class VCC_CaseSelectorTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_CaseSelector caseSelector = new VCC_CaseSelector();
        Test.stopTest();

        System.assert(caseSelector != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void addSObjectFields() {
        Test.startTest();
        VCC_CaseSelector caseSelector = new VCC_CaseSelector();
        Integer fieldCount = caseSelector.getSObjectFieldList().size();
        caseSelector.addSObjectFields(new List<SObjectField>{ Account.LastModifiedDate });
        Integer newFieldCount = caseSelector.getSObjectFieldList().size();
        Test.stopTest();

        System.assertEquals(fieldCount + 1, newFieldCount, 'Field count should have been increased by 1 field.');
    }

    @IsTest
    private static void selectById() {
        Case createdCase = new Case(Subject = 'selectById');
        createdCase.RecordTypeId = Case.SObjectType.getDescribe().getRecordTypeInfosByName().get('Clinical Triage Case').getRecordTypeId();
        insert createdCase;

        Test.startTest();
        List<Case> cases = new VCC_CaseSelector().selectById(new Set<Id>{ createdCase.Id });
        Test.stopTest();

        System.assert(cases != null);
        System.assertEquals(1, cases.size(), 'Expected only 1 item in the list.');
        System.assertEquals(createdCase.Id, cases[0].Id, 'Expected Org Ids to match.');
    }
}
