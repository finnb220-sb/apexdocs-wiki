@isTest
public with sharing class VCC_VaProfileControllerTest {
    private static String username = 'vaprocont';

    @TestSetup
    /**
     * @description configuring test setup by creating proper test users
     */
    public static void makeData() {
        List<User> userList = new List<User>();
        List<String> psgNames = new List<String>{
            'VCC_Registered_Nurse',
            'VCC_Medical_Provider',
            'VCC_Advanced_Medical_Support_Assistant',
            'VCC_Pharmacy_I',
            'VCC_Pharmacy_II',
            'VCC_Pharmacy_III',
            'TED_Medical_Provider_Group',
            'TED_Registered_Nurse_Group'
        };
        for (Integer i = 0; i < psgNames.size(); i++) {
            User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
            userList.add(testUser);
            VCC_TestDataFactory.addPermSetGroupToUser(psgNames[i], testUser);
            testUser.username = username + testUser.username + i;
        }
        update userList;
    }

    /**
     * @description returns a list of test users
     * @return  `List<User>`
     */
    public static List<User> getTestUsers() {
        return [SELECT Id FROM User WHERE Username LIKE :username + '%'];
    }

    @IsTest
    static void updateAssociatedPersonTestSadId() {
        Test.startTest();
        for (User testUser : getTestUsers()) {
            System.runAs(testUser) {
                VCC_Stub idModuleStub = VCC_ModuleService.stubModule(VCC_IdModule.class);
                VCC_Stub accountModuleStub = VCC_ModuleService.stubModule(VCC_AccountModule.class);

                idModuleStub.setReturnValue('isId', true);
                idModuleStub.setReturnValue('isIdOfType', false);
                accountModuleStub.setReturnValue('getIcn', '12345');

                VCC_InternalException expectedException;

                try {
                    VCC_VaProfileController.upsertAssociatedPersons(null, null);
                } catch (VCC_InternalException e) {
                    expectedException = e;
                }

                System.assert(expectedException != null, 'Expected an exception.');
                System.assert(expectedException.getMessage() == VCC_VaProfileController.BAD_ID, 'Expected correct exception message.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void updateAssociatedPersonTestSadIcn() {
        Test.startTest();
        for (User testUser : getTestUsers()) {
            System.runAs(testUser) {
                VCC_Stub idModuleStub = VCC_ModuleService.stubModule(VCC_IdModule.class);
                VCC_Stub accountModuleStub = VCC_ModuleService.stubModule(VCC_AccountModule.class);

                idModuleStub.setReturnValue('isId', true);
                idModuleStub.setReturnValue('isIdOfType', true);
                accountModuleStub.setReturnValue('getIcn', null);

                VCC_InternalException expectedException;

                try {
                    VCC_VaProfileController.upsertAssociatedPersons(null, null);
                } catch (VCC_InternalException e) {
                    expectedException = e;
                }

                System.assert(expectedException != null, 'Expected an exception.');
                System.assert(expectedException.getMessage() == VCC_VaProfileController.BAD_ICN, 'Expected correct exception message.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void updateAssociatedPersonTestHappy() {
        VCC_Stub idModuleStub = VCC_ModuleService.stubModule(VCC_IdModule.class);
        VCC_Stub accountModuleStub = VCC_ModuleService.stubModule(VCC_AccountModule.class);
        VCC_Stub vaProfileServiceStub = VCC_ModuleService.stubModule(VCC_VaProfileService.class);

        idModuleStub.setReturnValue('isId', true);
        idModuleStub.setReturnValue('isIdOfType', true);
        accountModuleStub.setReturnValue('getIcn', '12345');
        vaProfileServiceStub.setReturnValue('upsertAssociatedPersons', new VCC_VaProfileAssociatedPersonsRS());

        Test.startTest();
        for (User testUser : getTestUsers()) {
            System.runAs(testUser) {
                Exception unexpectedException;
                VCC_VaProfileAssociatedPersonsRS result;

                List<VCC_VaProfileAssociatedPersonsRQ.VCC_AssociatedPerson> ap = new List<VCC_VaProfileAssociatedPersonsRQ.VCC_AssociatedPerson>();
                ap.add(new VCC_VaProfileAssociatedPersonsRQ.VCC_AssociatedPerson());
                ap[0].addressLine1 = 'test';

                try {
                    result = VCC_VaProfileController.upsertAssociatedPersons((Id) '000000000000000000', JSON.serialize(ap));
                } catch (Exception e) {
                    unexpectedException = e;
                    // System.debug(e.getStackTraceString());
                }

                System.assert(unexpectedException == null, 'Unexpected exception.');
                System.assert(result != null, 'Expected a result.');
            }
        }
        Test.stopTest();
    }
}
