/**
 * @description Test class for PC_AddPatientController
 * @author      Booz Allen
 * @since       2024
 * @see         PC_AddPatientController
 */
@IsTest
private class PC_AddPatientControllerTest {
    @IsTest
    static void unitTestAssociateAccountPositive() {
        //create a Front Line Provider
        User pcFLP;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            pcFLP = generateUserWithAccess();
        }

        Id expectedCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        Id expectedPatientId = VATEST_IdFactory.get(Type.forName('Account'));

        //Create the fake PC Case in memory for fetchById
        PC_Case__c expectedFetchCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(new PC_Case__c());
        expectedFetchCase.Id = expectedCaseId;

        //Create fake PC Case sObject in memory for doUpdate
        SObjectType pcCaseSobjType = Id.valueOf(expectedCaseId).getSObjectType();
        SObject expectedUpdatedCaseSObj = pcCaseSobjType.newSObject();
        expectedUpdatedCaseSObj.Id = expectedCaseId;
        expectedUpdatedCaseSObj.put('Patient_Account__c', expectedPatientId);

        //Stub PC Case repo class and mock required methods
        PC_PrcCaseRepo stubbedRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expectedCaseId, new Set<String>{ 'Patient_Account__c' })
            //Tell the stub builder what to return
            .returning(expectedFetchCase)
            .mockingMethodCall('doUpdate', SObject.class)
            .withParameterValues(expectedUpdatedCaseSObj)
            .returning()
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_AddPatientController.prcCaseRepo = stubbedRepo;

        PC_Case__c result;
        System.runAs(pcFLP) {
            Test.startTest();

            result = PC_AddPatientController.associateAccount(expectedCaseId, expectedPatientId);

            Test.stopTest();
        }

        Assert.isTrue(
            result == (PC_Case__c) expectedUpdatedCaseSObj,
            'Expected the returned result to be a PC Case record with a populated Patient Account field.'
        );
    }

    @IsTest
    static void unitTestAssociateAccountDMLErrorNegative() {
        //create a Front Line Provider
        User pcFLP;
        //workaround for mixed DML error
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            pcFLP = generateUserWithAccess();
        }

        Id expectedCaseId = VATEST_IdFactory.get(Type.forName('PC_Case__c'));
        Id expectedPatientId = VATEST_IdFactory.get(Type.forName('Account'));

        //Create the fake PC Case in memory for fetchById
        PC_Case__c expectedFetchCase = (PC_Case__c) VATEST_SObjectFactory.createSObject(new PC_Case__c());
        expectedFetchCase.Id = expectedCaseId;

        //Create fake PC Case sObject in memory for doUpdate
        SObjectType pcCaseSobjType = Id.valueOf(expectedCaseId).getSObjectType();
        SObject expectedUpdatedCaseSObj = pcCaseSobjType.newSObject();
        expectedUpdatedCaseSObj.Id = expectedCaseId;
        expectedUpdatedCaseSObj.put('Patient_Account__c', expectedPatientId);

        //Stub PC Case repo class and mock required methods
        PC_PrcCaseRepo stubbedRepo = (PC_PrcCaseRepo) new VATEST_StubBuilder(PC_PrcCaseRepo.class)
            //Mock the method our class calls and pass in the Type of parameters it should expect
            .mockingMethodCall('fetchById', Id.class, Set<String>.class)
            .withParameterValues(expectedCaseId, new Set<String>{ 'Patient_Account__c' })
            //Tell the stub builder what to return
            .returning(expectedFetchCase)
            .mockingMethodCall('doUpdate', SObject.class)
            .withParameterValues(expectedUpdatedCaseSObj)
            //Tell the stub builder to throw an exception
            .throwingException(new DmlException('associateAccount doUpdate failure'))
            .defineStub();

        //Inject the stubbed repo into the Controller
        PC_AddPatientController.prcCaseRepo = stubbedRepo;

        Boolean hasFailure = false;
        System.runAs(pcFLP) {
            Test.startTest();

            try {
                PC_AddPatientController.associateAccount(expectedCaseId, expectedPatientId);
            } catch (AuraHandledException exc) {
                hasFailure = true;
            }

            Test.stopTest();
        }

        Assert.isTrue(
            hasFailure,
            'Expected the associateAccount method to fail during doUpdate and throw an AuraHandledException.'
        );
    }

    /**
     * @description helper method to generate an FLP test user for use in test methods
     * @return      `User` FLP salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess() {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .withPermissionSet('PrC_FLP_Users')
            .build(true);
    }
}
