@isTest
/**
 * @description
 * @author
 * @since
 * @group Test Classes
 * @see VCC_Case_PreventOwnerChange
 */
public with sharing class VCC_Case_PreventOwnerChangeTestClass {
    @testSetup
    private static void testSetup() {
        Case c = new Case(OwnerId = UserInfo.getUserId());
        insert c;
    }
    @isTest
    private static void triggerCase() {
        Case c = [SELECT Id FROM Case LIMIT 1];
        User usr = [SELECT Id FROM User LIMIT 1];

        c.OwnerId = usr.Id;
        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            update c;
        }
        System.assertEquals(c.OwnerId, usr.Id, 'user id was not changed on new case');
        Test.stopTest();
    }

    @isTest
    private static void ownerChangerTest() {
        List<Case> oldCases = new List<Case>();
        List<Case> newCases = new List<Case>();

        Id pharmRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId();
        Id admRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Administrative').getRecordTypeId();
        Id ctRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId();
        Id vcvRecType = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Vitrual_Clinic_Visit').getRecordTypeId();

        Id caseRecordId1 = TestUtility.getFakeId(Case.SObjectType, 1);
        Id caseRecordId2 = TestUtility.getFakeId(Case.SObjectType, 2);
        Id caseRecordId3 = TestUtility.getFakeId(Case.SObjectType, 3);
        Id caseRecordId4 = TestUtility.getFakeId(Case.SObjectType, 4);
        Id caseRecordId5 = TestUtility.getFakeId(Case.SObjectType, 5);
        Id caseRecordId6 = TestUtility.getFakeId(Case.SObjectType, 6);
        Id caseRecordId7 = TestUtility.getFakeId(Case.SObjectType, 7);
        Id caseRecordId8 = TestUtility.getFakeId(Case.SObjectType, 8);
        Id caseRecordId9 = TestUtility.getFakeId(Case.SObjectType, 9);

        Id oldOwnerId = TestUtility.getFakeId(User.SObjectType, 1);

        Group gMSA = [SELECT Id FROM GROUP WHERE Name LIKE '%MSA' LIMIT 1];
        Group gRN = [SELECT Id FROM GROUP WHERE Name LIKE '%RN' LIMIT 1];
        Group gPHARM = [SELECT Id FROM GROUP WHERE Name LIKE '%PHARM-TIER-III' LIMIT 1];
        Group gVCV = [SELECT Id FROM GROUP WHERE Name LIKE '%MP' LIMIT 1];

        //Id gRNId	 = TestUtility.getFakeId(Group.SObjectType, 46);
        //Id gMSAId    = TestUtility.getFakeId(Group.SObjectType, 47);
        //Id gPHARMId  = TestUtility.getFakeId(Group.SObjectType, 48);
        //Id gVCVId	 = TestUtility.getFakeId(Group.SObjectType, 49);

        //Group rn    = new Group(Id = gRNId, Name = 'CCC-V8-RN');
        //Group msa   = new Group(Id = gMSAId, Name = 'CCC-V8-MSA');
        //Group pharm = new Group(Id = gPHARMId, Name = 'CCC-V8-PHARM');
        //Group vcv   = new Group(Id = gVCVId, Name = 'CCC-V8-MP');

        Id u = TestUtility.getFakeId(User.SObjectType, 233);

        oldCases.add(new Case(Id = caseRecordId1, ownerId = oldOwnerId, recordTypeId = ctRecType));
        oldCases.add(new Case(Id = caseRecordId2, ownerId = oldOwnerId, recordTypeId = pharmRecType));
        oldCases.add(new Case(Id = caseRecordId3, ownerId = oldOwnerId, recordTypeId = admRecType));
        oldCases.add(new Case(Id = caseRecordId4, ownerId = oldOwnerId, recordTypeId = vcvRecType));
        oldCases.add(new Case(Id = caseRecordId5, ownerId = oldOwnerId, recordTypeId = ctRecType));
        oldCases.add(new Case(Id = caseRecordId6, ownerId = oldOwnerId, recordTypeId = pharmRecType));
        oldCases.add(new Case(Id = caseRecordId7, ownerId = oldOwnerId, recordTypeId = admRecType));
        oldCases.add(new Case(Id = caseRecordId8, ownerId = oldOwnerId, recordTypeId = vcvRecType));
        oldCases.add(new Case(Id = caseRecordId9, ownerId = gPHARM.Id, recordTypeId = pharmRecType));

        newCases.add(new Case(Id = caseRecordId1, ownerId = u, recordTypeId = ctRecType));
        newCases.add(new Case(Id = caseRecordId2, ownerId = u, recordTypeId = pharmRecType));
        newCases.add(new Case(Id = caseRecordId3, ownerId = u, recordTypeId = admRecType));
        newCases.add(new Case(Id = caseRecordId4, ownerId = u, recordTypeId = vcvRecType));
        newCases.add(new Case(Id = caseRecordId5, ownerId = gmsa.Id, recordTypeId = ctRecType));
        newCases.add(new Case(Id = caseRecordId6, ownerId = grn.Id, recordTypeId = pharmRecType));
        newCases.add(new Case(Id = caseRecordId7, ownerId = gvcv.Id, recordTypeId = admRecType));
        newCases.add(new Case(Id = caseRecordId8, ownerId = gpharm.Id, recordTypeId = vcvRecType));
        newCases.add(new Case(Id = caseRecordId9, ownerId = u, recordTypeId = pharmRecType));

        Test.startTest();
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        System.runAs(testuser) {
            new VCC_Case_PreventOwnerChange().beforeUpdate(newCases, oldCases);
        }
        Test.stopTest();

        System.assertEquals(true, newCases[0].hasErrors(), 'newCases has Errors');
    }
}
