/**
 * Created by abaddon on 7/6/23.
 */

/**
 * @description         : test class for VCC_T2T_Adapter_Record2JSON, tests parsing of t2t data and format output
 * @author              : Christian J. Gonzalez
 * @group               : Team 2
 * @last modified on    : 08/01/2023
 * last modified by     : Christian J Gonzalez
 **/

@IsTest
private class VCC_T2T_Adapter_Record2JSONTest {
    private static final String username = 'antv';
    @TestSetup
    private static void preTest() {
        List<User> userList = new List<User>();
        List<String> psgNames = new List<String>{ 'VCC_Registered_Nurse', 'VCC_Medical_Provider' };
        List<Id> psgIds = new List<Id>();
        for (PermissionSetGroup psg : [SELECT Id FROM PermissionSetGroup WHERE DeveloperName IN :psgNames]) {
            psgIds.add(psg.Id);
        }
        Test.calculatePermissionSetGroup(psgIds);
        for (Integer i = 0; i < psgNames.size(); i++) {
            User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
            userList.add(testUser);
            VCC_TestDataFactory.addPermSetGroupToUser(psgNames[i], testUser);
            VCC_TestDataFactory.assignPermissionSetByName(testUser, 'HealthCloudFoundation');
            testUser.username = username + testUser.username + i;
            testUser.Title = psgNames[i];
        }
        update userList;
    }
    private static User getTestUser(Integer offset) {
        return [SELECT Id, MVIICN__c, Title FROM User WHERE Username LIKE :username + '%' LIMIT 1 OFFSET :offset];
    }
    @IsTest
    static void testT2TDataRN() {
        User testUser = getTestUser(0);
        // Test data setup
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c = '[{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        insert note;
        Test.startTest();
        String recordId;
        String convertedJson;
        System.runAs(testUser) {
            try {
                recordId = note.VCC_Progress_Note__c;
                convertedJson = VCC_T2T_Adapter_Record2JSON.T2TData(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        System.assertEquals(
            '[{"sectionName":"Test to Treat","fields":[{"value":"Response1","label":"Label1","fieldName":"Field1","displayValue":true,"displayField":true}],"emphasizeSection":false,"displaySectionName":true}]',
            convertedJson
        );
        Test.stopTest();
    }
    @IsTest
    static void testT2TDataMP() {
        User testUser = getTestUser(1);
        // Test data setup
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c = '[{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        insert note;
        Test.startTest();
        String recordId;
        String convertedJson;
        System.runAs(testUser) {
            try {
                recordId = note.VCC_Progress_Note__c;
                convertedJson = VCC_T2T_Adapter_Record2JSON.T2TData(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        System.assertEquals(
            '[{"sectionName":"Test to Treat","fields":[{"value":"Response1","label":"Label1","fieldName":"Field1","displayValue":true,"displayField":true}],"emphasizeSection":false,"displaySectionName":true}]',
            convertedJson
        );
        Test.stopTest();
    }

    @IsTest
    static void testParseRN() {
        User testUser = getTestUser(0);
        // Test data setup
        String jsonString = '[{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        Test.startTest();
        List<VCC_T2T_Adapter_Record2JSON> records;
        System.runAs(testUser) {
            try {
                records = VCC_T2T_Adapter_Record2JSON.parse(jsonString);
                System.debug(records);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        System.assertEquals(1, records.size());
        VCC_T2T_Adapter_Record2JSON record = records[0];
        System.assertEquals('Response1', record.value);
        System.assertEquals('Label1', record.label);
        System.assertEquals('Field1', record.fieldName);
        System.assertEquals(true, record.displayValue);
        System.assertEquals(true, record.displayField);
        Test.stopTest();
    }
    @IsTest
    static void testParseMP() {
        User testUser = getTestUser(1);
        // Test data setup
        String jsonString = '[{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        Test.startTest();
        List<VCC_T2T_Adapter_Record2JSON> records;
        System.runAs(testUser) {
            try {
                records = VCC_T2T_Adapter_Record2JSON.parse(jsonString);
                System.debug(records);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        System.assertEquals(1, records.size());
        VCC_T2T_Adapter_Record2JSON record = records[0];
        System.assertEquals('Response1', record.value);
        System.assertEquals('Label1', record.label);
        System.assertEquals('Field1', record.fieldName);
        System.assertEquals(true, record.displayValue);
        System.assertEquals(true, record.displayField);
        Test.stopTest();
    }

    @IsTest
    static void testConvertToJsonRN() {
        User testUser = getTestUser(0);
        // Test data setup
        VCC_T2T_Adapter_Record2JSON record = new VCC_T2T_Adapter_Record2JSON('Response1', 'Label1', 'Field1', true, true);
        List<VCC_T2T_Adapter_Record2JSON> records = new List<VCC_T2T_Adapter_Record2JSON>{ record };

        Test.startTest();
        String convertedJson;
        System.runAs(testUser) {
            try {
                convertedJson = VCC_T2T_Adapter_Record2JSON.convertToJson(records);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        System.assertEquals(
            '[{"sectionName":"Test to Treat","fields":[{"value":"Response1","label":"Label1","fieldName":"Field1","displayValue":true,"displayField":true}],"emphasizeSection":false,"displaySectionName":true}]',
            convertedJson
        );
        Test.stopTest();
    }
    @IsTest
    static void testConvertToJsonMP() {
        User testUser = getTestUser(1);
        // Test data setup
        VCC_T2T_Adapter_Record2JSON record = new VCC_T2T_Adapter_Record2JSON('Response1', 'Label1', 'Field1', true, true);
        List<VCC_T2T_Adapter_Record2JSON> records = new List<VCC_T2T_Adapter_Record2JSON>{ record };

        Test.startTest();
        String convertedJson;
        System.runAs(testUser) {
            try {
                convertedJson = VCC_T2T_Adapter_Record2JSON.convertToJson(records);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        System.assertEquals(
            '[{"sectionName":"Test to Treat","fields":[{"value":"Response1","label":"Label1","fieldName":"Field1","displayValue":true,"displayField":true}],"emphasizeSection":false,"displaySectionName":true}]',
            convertedJson
        );
        Test.stopTest();
    }
    @IsTest
    static void testToJSONRN() {
        User testUser = getTestUser(0);
        // Create a test record
        VCC_T2T_Adapter_Record2JSON record = new VCC_T2T_Adapter_Record2JSON('Response1', 'Label1', 'Field1', true, true);
        Test.startTest();
        Object json;
        System.runAs(testUser) {
            try {
                json = record.toJSON();
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        Map<String, Object> expectedJson = new Map<String, Object>{
            'value' => 'Response1',
            'label' => 'Label1',
            'fieldName' => 'Field1',
            'displayValue' => true,
            'displayField' => true
        };
        System.assertEquals(expectedJson, json);
        Test.stopTest();
    }
    @IsTest
    static void testToJSONMP() {
        User testUser = getTestUser(1);
        // Create a test record
        VCC_T2T_Adapter_Record2JSON record = new VCC_T2T_Adapter_Record2JSON('Response1', 'Label1', 'Field1', true, true);
        Test.startTest();
        Object json;
        System.runAs(testUser) {
            try {
                json = record.toJSON();
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the result
        Map<String, Object> expectedJson = new Map<String, Object>{
            'value' => 'Response1',
            'label' => 'Label1',
            'fieldName' => 'Field1',
            'displayValue' => true,
            'displayField' => true
        };
        System.assertEquals(expectedJson, json);
        Test.stopTest();
    }

    @IsTest
    static void testFromJSONRN() {
        User testUser = getTestUser(0);
        // Create a sample JSON object
        Map<String, Object> json = new Map<String, Object>{ 'value' => 'Response1', 'label' => 'Label1', 'fieldName' => 'Field1', 'displayValue' => true, 'displayField' => true };
        Test.startTest();
        VCC_T2T_Adapter_Record2JSON record;
        System.runAs(testUser) {
            try {
                record = new VCC_T2T_Adapter_Record2JSON('', '', '', false, false);
                record.fromJSON(json);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }

        // Assert the fields of the record
        System.assertEquals('Response1', record.value);
        System.assertEquals('Label1', record.label);
        System.assertEquals('Field1', record.fieldName);
        System.assertEquals(true, record.displayValue);
        System.assertEquals(true, record.displayField);
        Test.stopTest();
    }
    @IsTest
    static void testFromJSONMP() {
        User testUser = getTestUser(1);
        // Create a sample JSON object
        Map<String, Object> json = new Map<String, Object>{ 'value' => 'Response1', 'label' => 'Label1', 'fieldName' => 'Field1', 'displayValue' => true, 'displayField' => true };
        Test.startTest();
        VCC_T2T_Adapter_Record2JSON record;
        System.runAs(testUser) {
            try {
                record = new VCC_T2T_Adapter_Record2JSON('', '', '', false, false);
                record.fromJSON(json);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }

        // Assert the fields of the record
        System.assertEquals('Response1', record.value);
        System.assertEquals('Label1', record.label);
        System.assertEquals('Field1', record.fieldName);
        System.assertEquals(true, record.displayValue);
        System.assertEquals(true, record.displayField);
        Test.stopTest();
    }

    @IsTest
    static void testPreviewT2TDataRN() {
        User testUser = getTestUser(0);
        //Create test records
        //Create test account/case and progress note to work with
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        dataProgress.VCC_Signed__c = true;
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 0, "fieldName": "Field0", "id": "123", "label": "Label0", "response": "Response0", "review": "Disposition0"},' +
            '{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;
        Test.startTest();
        List<String> result;
        System.runAs(testUser) {
            try {
                result = VCC_T2T_Adapter_Record2JSON.previewT2TData(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Verify the results
        System.assertEquals(2, result.size());
        Map<String, Object> actualJSON0 = (Map<String, Object>) JSON.deserializeUntyped(result[0]);
        Map<String, Object> actualJSON1 = (Map<String, Object>) JSON.deserializeUntyped(result[1]);
        Map<String, Object> expectedJSON0 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index": 0, "fieldName": "Field0", "id": "123", "label": "Label0", "response": "Response0", "review": "Disposition0"}'
        );
        Map<String, Object> expectedJSON1 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}'
        );
        System.assertEquals(expectedJSON0, actualJSON0);
        System.assertEquals(expectedJSON1, actualJSON1);
        Test.stopTest();
    }
    @IsTest
    static void testPreviewT2TDataMP() {
        User testUser = getTestUser(1);
        //Create test records
        //Create test account/case and progress note to work with
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        dataProgress.VCC_Signed__c = true;
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 0, "fieldName": "Field0", "id": "123", "label": "Label0", "response": "Response0", "review": "Disposition0"},' +
            '{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;
        Test.startTest();
        List<String> result;
        System.runAs(testUser) {
            try {
                result = VCC_T2T_Adapter_Record2JSON.previewT2TData(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Verify the results
        System.assertEquals(2, result.size());
        Map<String, Object> actualJSON0 = (Map<String, Object>) JSON.deserializeUntyped(result[0]);
        Map<String, Object> actualJSON1 = (Map<String, Object>) JSON.deserializeUntyped(result[1]);
        Map<String, Object> expectedJSON0 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index": 0, "fieldName": "Field0", "id": "123", "label": "Label0", "response": "Response0", "review": "Disposition0"}'
        );
        Map<String, Object> expectedJSON1 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}'
        );
        System.assertEquals(expectedJSON0, actualJSON0);
        System.assertEquals(expectedJSON1, actualJSON1);
        Test.stopTest();
    }

    @IsTest
    static void testprepVDIFT2TDataRN() {
        User testUser = getTestUser(0);
        //Setup test data
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 0, "fieldName": "Field0", "id": "123", "label": "Label0", "response": "Response0", "review": "Disposition0"},' +
            '{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;
        Test.startTest();
        String responseResult;
        System.runAs(testUser) {
            try {
                responseResult = VCC_T2T_Adapter_Record2JSON.prepVDIFT2TData(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        System.assertEquals('|||COVID T2T Assessment||Label0: Response0||Label1: Response1|', responseResult);
        Test.stopTest();
    }
    @IsTest
    static void testprepVDIFT2TDataMP() {
        User testUser = getTestUser(1);
        //Setup test data
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 0, "fieldName": "Field0", "id": "123", "label": "Label0", "response": "Response0", "review": "Disposition0"},' +
            '{"Index": 1, "fieldName": "Field1", "id": "123", "label": "Label1", "response": "Response1", "review": "Disposition1"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;
        Test.startTest();
        String responseResult;
        System.runAs(testUser) {
            try {
                responseResult = VCC_T2T_Adapter_Record2JSON.prepVDIFT2TData(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        System.assertEquals('|||COVID T2T Assessment||Label0: Response0||Label1: Response1|', responseResult);
        Test.stopTest();
    }
}
