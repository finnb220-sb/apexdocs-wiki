@isTest
public with sharing class VCC_CodeSetSelectorTest {
    @isTest
    public static void instantiationTest() {
        Test.startTest();
        VCC_CodeSetSelector css = new VCC_CodeSetSelector();
        Test.stopTest();

        Assert.isNotNull(css, 'Did not instantiate as expected.');
    }

    @isTest
    public static void addSObjectFieldsTest() {
        VCC_CodeSetSelector css = new VCC_CodeSetSelector();

        System.assert(!css.getSObjectFieldList().contains(CodeSet.isActive), 'Selector already contains the field to test.');

        Test.startTest();
        css.addSObjectFields(new List<SObjectField>{ CodeSet.isActive });
        Test.stopTest();

        Assert.isTrue(css.getSObjectFieldList().contains(CodeSet.isActive), 'Selector did not add SObject field correctly.');
    }

    @isTest
    public static void selectByIdsTest() {
        VCC_CodeSetSelector css = new VCC_CodeSetSelector();
        CodeSet cs = new CodeSet(Code = 'ZZZ33.3', Name = 'ZZZ33.3');
        insert cs;

        Test.startTest();
        List<CodeSet> csList = css.selectByIds(new Set<Id>{ cs.Id });
        Test.stopTest();

        Assert.areEqual(1, csList.size(), 'Expected one record returned.');
    }
}
