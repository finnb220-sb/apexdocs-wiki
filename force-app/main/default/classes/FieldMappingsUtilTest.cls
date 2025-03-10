/**
 * Created by DC Solutions on 2019-11-06.
 * Description: Unit test for FieldMappingsUtil class
 *
 * @group Field Mapping Utility
 * @see FieldMappingsUtil.cls
 * @see FieldMapping custom metadata type
 */
@IsTest
private class FieldMappingsUtilTest {

    @TestSetup static void buildData() {
        Account acct = new Account(Name='Test Account', Phone='7035551212',
                Website='www.testers-donotuse.com', Description='Test Description');
        insert acct;
        Contact testContact = new Contact(LastName='Testee  Tester',
                Phone='5557031212',
                Email='testee@testersrus.com', AccountId=acct.Id);
        insert testContact;
    }

    static List<Field_Mapping__mdt> buildTestMappings() {
        List<Field_Mapping__mdt> testMappings = new List<Field_Mapping__mdt>();

        testMappings.add(new Field_Mapping__mdt(Process_Name__c='TestProcess',
                Source_Object_Name__c='Account', Source_Field_Name__c='Phone',
                Target_Object_name__c='Contact', Target_Field_Name__c='Phone',
                Is_Active__c=true));
        testMappings.add(new Field_Mapping__mdt(Process_Name__c='TestProcess',
                Source_Object_Name__c='Account', Source_Field_Name__c='Description',
                Target_Object_name__c='Contact', Target_Field_Name__c='Description',
                Is_Active__c=true));
        testMappings.add(new Field_Mapping__mdt(Process_Name__c='TestProcess',
                Source_Object_Name__c='Account', Source_Field_Name__c='Owner.Name',
                Target_Object_name__c='Contact', Target_Field_Name__c='LastName',
                Is_Active__c=true));
        testMappings.add(new Field_Mapping__mdt(Process_Name__c='TestProcess',
                Source_Object_Name__c='Account', Source_Field_Name__c='CEO',
                Target_Object_name__c='Contact', Target_Field_Name__c='Title',
                Is_Active__c=true, Is_Static_Value__c=true));

        return testMappings;
    }

    @IsTest static void testGetFields() {
        FieldMappingsUtil.testMappings = buildTestMappings();
        FieldMappingsUtil util = new FieldMappingsUtil('TestProcess');
        Set<String> srcFields;
        String soqlQuery;
        Test.startTest();
            srcFields = util.getSrcFields('Contact');
            soqlQuery = util.buildSoqlQuery('Contact', true);
        Test.stopTest();
        System.assertEquals(4, srcFields.size(), 'Failed to return expected # of source fields.');
        System.assertEquals(true, srcFields.contains('Phone'), 'Failed to return expected fields.');
        System.assertEquals(true, soqlQuery.contains('Owner.Name') && soqlQuery.contains('Phone') && !soqlQuery.contains('CEO'),
                'Failed to add all source fields in query.');
    }

    @IsTest static void testMultipleTargetObjects() {
        FieldMappingsUtil.testMappings = buildTestMappings();
        FieldMappingsUtil.testMappings.add(new Field_Mapping__mdt(Process_Name__c='TestProcess',
                Source_Object_Name__c='Account', Source_Field_Name__c='Name',
                Target_Object_name__c='Opportunity', Target_Field_Name__c='Name',
                Is_Active__c=true, Is_Static_Value__c=false));
        FieldMappingsUtil.testMappings.add(new Field_Mapping__mdt(Process_Name__c='TestProcess',
                Source_Object_Name__c='Account', Source_Field_Name__c='Name',
                Target_Object_name__c='Contract', Target_Field_Name__c='Name',
                Is_Active__c=true, Is_Static_Value__c=false));

        FieldMappingsUtil util = new FieldMappingsUtil('TestProcess');
        Set<String> srcFields;
        String soqlQuery;
        Test.startTest();
            srcFields = util.getSrcFields('Contact');
            soqlQuery = util.buildSoqlQuery('Contact', true);
            System.assertEquals(4, srcFields.size(), 'Failed to return expected # of source fields.');
            System.assertEquals(true, srcFields.contains('Phone'), 'Failed to return expected fields.');
            System.assertEquals(true, soqlQuery.contains('Owner.Name') && soqlQuery.contains('Name'),
                'Failed to add all source fields in query.');

            soqlQuery = util.buildSoqlQuery('Opportunity', false);

        Test.stopTest();

        System.assertEquals(true, !soqlQuery.contains('Phone') && soqlQuery.contains('Name'),
                'Failed to add all target fields to query.');
    }

    @IsTest static void testValidations() {
        Test.startTest();
            System.assertEquals(true, FieldMappingsUtil.isValidObjectName('Account'),
                    'Failed to recognize staging object.');
            System.assertEquals(false, FieldMappingsUtil.isValidObjectName('InisValidObjectName'),
                'Should have failed when given wrong object name');
            System.assertEquals(true, FieldMappingsUtil.isValidField('Account', 'Name'),
                'Failed to recognize staging object field Log.');
            System.assertEquals(false, FieldMappingsUtil.isValidField('Account', 'InisValidFieldName'),
                'Should have failed when given wrong field name.');
            System.assertEquals(false, FieldMappingsUtil.isValidField('InisValidObjectName', 'Name'),
                'Should have failed when given wrong object name.');
        Test.stopTest();
    }

    @IsTest static void testMapFields() {
        Account acct = [select Id, Phone, Name,Website, Owner.Name, Description
            from Account limit 1];
        Contact newContact = new Contact();
        FieldMappingsUtil.testMappings = buildTestMappings();
        FieldMappingsUtil util = new FieldMappingsUtil('TestProcess');
        Test.startTest();
            util.mapValues(newContact, acct);
        Test.stopTest();

        System.assertEquals(acct.Owner.Name, newContact.LastName, 'Failed to map over related field.');
        System.assertEquals(acct.Phone, newContact.Phone, 'Failed to map over text field.');
        System.assertEquals('CEO', newContact.Title,
                'Failed to map over static field.');

    }
}