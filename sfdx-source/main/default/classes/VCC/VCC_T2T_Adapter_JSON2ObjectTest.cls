/**
 * Created by abaddon on 7/13/23.
 */

/**
 * @description         : test class for T2T Adapter JSON2Object  used to parse a json object back to an array of objects
 * @author              : Christian J. Gonzalez
 * @group               : Team 2
 * @last modified on    : 08/01/2023
 * last modified by     : Christian J Gonzalez
 **/

@IsTest
private class VCC_T2T_Adapter_JSON2ObjectTest {
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
    static void testTranslateStringsRN() {
        User testUser = getTestUser(0);
        // Create test data
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"},' +
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;
        Test.startTest();
        List<VCC_T2T_Adapter_JSON2Object.CustomObject> results;
        // Call the method under test
        System.runAs(testUser) {
            try {
                results = VCC_T2T_Adapter_JSON2Object.translateStrings(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the results
        System.assertEquals(2, results.size());
        VCC_T2T_Adapter_JSON2Object.CustomObject obj1 = results[0];
        System.assertEquals(1, obj1.index);
        System.assertEquals('Field1', obj1.fieldName);
        System.assertEquals('Id1', obj1.id);
        System.assertEquals('Label1', obj1.label);
        System.assertEquals('Response1', obj1.response);
        System.assertEquals('Review1', obj1.review);
        VCC_T2T_Adapter_JSON2Object.CustomObject obj2 = results[1];
        System.assertEquals(2, obj2.index);
        System.assertEquals('Field2', obj2.fieldName);
        System.assertEquals('Id2', obj2.id);
        System.assertEquals('Label2', obj2.label);
        System.assertEquals('Response2', obj2.response);
        System.assertEquals('Review2', obj2.review);
        Test.stopTest();
    }
    @IsTest
    static void testTranslateStringsMP() {
        User testUser = getTestUser(1);
        // Create test data
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);
        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);
        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);
        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"},' +
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;
        Test.startTest();
        List<VCC_T2T_Adapter_JSON2Object.CustomObject> results;
        // Call the method under test
        System.runAs(testUser) {
            try {
                results = VCC_T2T_Adapter_JSON2Object.translateStrings(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the results
        System.assertEquals(2, results.size());
        VCC_T2T_Adapter_JSON2Object.CustomObject obj1 = results[0];
        System.assertEquals(1, obj1.index);
        System.assertEquals('Field1', obj1.fieldName);
        System.assertEquals('Id1', obj1.id);
        System.assertEquals('Label1', obj1.label);
        System.assertEquals('Response1', obj1.response);
        System.assertEquals('Review1', obj1.review);
        VCC_T2T_Adapter_JSON2Object.CustomObject obj2 = results[1];
        System.assertEquals(2, obj2.index);
        System.assertEquals('Field2', obj2.fieldName);
        System.assertEquals('Id2', obj2.id);
        System.assertEquals('Label2', obj2.label);
        System.assertEquals('Response2', obj2.response);
        System.assertEquals('Review2', obj2.review);
        Test.stopTest();
    }

    @IsTest
    static void testConvertToObjectsRN() {
        User testUser = getTestUser(0);
        // Create test data
        List<String> jsonStringList = new List<String>{
            '{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"}',
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}'
        };

        Test.startTest();
        List<VCC_T2T_Adapter_JSON2Object.CustomObject> results;
        System.runAs(testUser) {
            try {
                results = VCC_T2T_Adapter_JSON2Object.convertToObjects(jsonStringList);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the results
        System.assertEquals(2, results.size());
        VCC_T2T_Adapter_JSON2Object.CustomObject obj1 = results[0];
        System.assertEquals(1, obj1.index);
        System.assertEquals('Field1', obj1.fieldName);
        System.assertEquals('Id1', obj1.id);
        System.assertEquals('Label1', obj1.label);
        System.assertEquals('Response1', obj1.response);
        System.assertEquals('Review1', obj1.review);
        VCC_T2T_Adapter_JSON2Object.CustomObject obj2 = results[1];
        System.assertEquals(2, obj2.index);
        System.assertEquals('Field2', obj2.fieldName);
        System.assertEquals('Id2', obj2.id);
        System.assertEquals('Label2', obj2.label);
        System.assertEquals('Response2', obj2.response);
        System.assertEquals('Review2', obj2.review);
        Test.stopTest();
    }
    @IsTest
    static void testConvertToObjectsMP() {
        User testUser = getTestUser(1);
        // Create test data
        List<String> jsonStringList = new List<String>{
            '{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"}',
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}'
        };

        Test.startTest();
        List<VCC_T2T_Adapter_JSON2Object.CustomObject> results;
        System.runAs(testUser) {
            try {
                results = VCC_T2T_Adapter_JSON2Object.convertToObjects(jsonStringList);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the results
        System.assertEquals(2, results.size());
        VCC_T2T_Adapter_JSON2Object.CustomObject obj1 = results[0];
        System.assertEquals(1, obj1.index);
        System.assertEquals('Field1', obj1.fieldName);
        System.assertEquals('Id1', obj1.id);
        System.assertEquals('Label1', obj1.label);
        System.assertEquals('Response1', obj1.response);
        System.assertEquals('Review1', obj1.review);
        VCC_T2T_Adapter_JSON2Object.CustomObject obj2 = results[1];
        System.assertEquals(2, obj2.index);
        System.assertEquals('Field2', obj2.fieldName);
        System.assertEquals('Id2', obj2.id);
        System.assertEquals('Label2', obj2.label);
        System.assertEquals('Response2', obj2.response);
        System.assertEquals('Review2', obj2.review);
        Test.stopTest();
    }
    @IsTest
    static void testGetStringListRN() {
        User testUser = getTestUser(0);
        // Create test data
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);

        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);

        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);

        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"},' +
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;

        Test.startTest();
        List<String> stringList;
        System.runAs(testUser) {
            try {
                stringList = VCC_T2T_Adapter_JSON2Object.getStringList(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the results
        System.assertEquals(2, stringList.size());
        // Parse the JSON strings and compare individual properties
        Map<String, Object> expectedObject1 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index":1,"fieldName":"Field1","id":"Id1","label":"Label1","response":"Response1","review":"Review1"}'
        );
        Map<String, Object> actualObject1 = (Map<String, Object>) JSON.deserializeUntyped(stringList[0]);
        System.assertEquals(expectedObject1.get('Index'), actualObject1.get('index'));
        System.assertEquals(expectedObject1.get('fieldName'), actualObject1.get('fieldName'));
        System.assertEquals(expectedObject1.get('id'), actualObject1.get('id'));
        System.assertEquals(expectedObject1.get('label'), actualObject1.get('label'));
        System.assertEquals(expectedObject1.get('response'), actualObject1.get('response'));
        System.assertEquals(expectedObject1.get('review'), actualObject1.get('review'));

        Map<String, Object> expectedObject2 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index":2,"fieldName":"Field2","id":"Id2","label":"Label2","response":"Response2","review":"Review2"}'
        );
        Map<String, Object> actualObject2 = (Map<String, Object>) JSON.deserializeUntyped(stringList[1]);
        System.assertEquals(expectedObject2.get('Index'), actualObject2.get('index'));
        System.assertEquals(expectedObject2.get('fieldName'), actualObject2.get('fieldName'));
        System.assertEquals(expectedObject2.get('id'), actualObject2.get('id'));
        System.assertEquals(expectedObject2.get('label'), actualObject2.get('label'));
        System.assertEquals(expectedObject2.get('response'), actualObject2.get('response'));
        System.assertEquals(expectedObject2.get('review'), actualObject2.get('review'));
        Test.stopTest();
    }
    @IsTest
    static void testGetStringListMP() {
        User testUser = getTestUser(1);
        // Create test data
        Account dataAccount = VCC_TestDataFactory.generateVccPersonAccounts(1).get(0);

        RecordType dataRecordType = [SELECT Id, Name FROM RecordType WHERE Name = 'Virtual Clinic Visit Case' LIMIT 1];
        Case dataCase = VCC_TestDataFactory.createCase('test', dataRecordType.Id, dataAccount.Id);

        VCC_Progress_Note__c dataProgress = VCC_TestDataFactory.createProgressNote(dataCase.Id);

        VCC_Progress_Note_Detail__c note = new VCC_Progress_Note_Detail__c();
        note.VCC_Progress_Note__c = dataProgress.Id;
        note.VCC_T2T_Data__c =
            '[{"Index": 1, "fieldName": "Field1", "id": "Id1", "label": "Label1", "response": "Response1", "review": "Review1"},' +
            '{"Index": 2, "fieldName": "Field2", "id": "Id2", "label": "Label2", "response": "Response2", "review": "Review2"}]';
        String recordId = note.VCC_Progress_Note__c;
        insert note;

        Test.startTest();
        List<String> stringList;
        System.runAs(testUser) {
            try {
                stringList = VCC_T2T_Adapter_JSON2Object.getStringList(recordId);
            } catch (Exception e) {
                Assert.fail('Perm Set Group ' + testUser.Title + ' Unexpected exception: ' + e.getMessage());
            }
        }
        // Assert the results
        System.assertEquals(2, stringList.size());
        // Parse the JSON strings and compare individual properties
        Map<String, Object> expectedObject1 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index":1,"fieldName":"Field1","id":"Id1","label":"Label1","response":"Response1","review":"Review1"}'
        );
        Map<String, Object> actualObject1 = (Map<String, Object>) JSON.deserializeUntyped(stringList[0]);
        System.assertEquals(expectedObject1.get('Index'), actualObject1.get('index'));
        System.assertEquals(expectedObject1.get('fieldName'), actualObject1.get('fieldName'));
        System.assertEquals(expectedObject1.get('id'), actualObject1.get('id'));
        System.assertEquals(expectedObject1.get('label'), actualObject1.get('label'));
        System.assertEquals(expectedObject1.get('response'), actualObject1.get('response'));
        System.assertEquals(expectedObject1.get('review'), actualObject1.get('review'));

        Map<String, Object> expectedObject2 = (Map<String, Object>) JSON.deserializeUntyped(
            '{"Index":2,"fieldName":"Field2","id":"Id2","label":"Label2","response":"Response2","review":"Review2"}'
        );
        Map<String, Object> actualObject2 = (Map<String, Object>) JSON.deserializeUntyped(stringList[1]);
        System.assertEquals(expectedObject2.get('Index'), actualObject2.get('index'));
        System.assertEquals(expectedObject2.get('fieldName'), actualObject2.get('fieldName'));
        System.assertEquals(expectedObject2.get('id'), actualObject2.get('id'));
        System.assertEquals(expectedObject2.get('label'), actualObject2.get('label'));
        System.assertEquals(expectedObject2.get('response'), actualObject2.get('response'));
        System.assertEquals(expectedObject2.get('review'), actualObject2.get('review'));
        Test.stopTest();
    }
}
