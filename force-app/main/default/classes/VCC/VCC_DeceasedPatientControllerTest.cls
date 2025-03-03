/**
 * @description test class for VCC_DeceasedPatientController
 * @author
 * @since  October 17, 2024
 */
@isTest
public with sharing class VCC_DeceasedPatientControllerTest {
    private static String username = 'decCont';

    /**
     * @description builds a test user using VATEST_UserBuilder
     * @param  permSetGroupName The permission set group name as a string
     * @return `User` the User thats being built
     */
    public static User buildTestUser(String permSetGroupName) {
        return new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('HealthCloudFoundation')
            .withPermissionSet(permSetGroupName)
            .withStandardData()
            .build(true);
    }

    /**
     * @description sets up the data for the test class
     */
    @TestSetup
    static void setupData() {
        List<Account> accountsToInsert = new List<Account>();

        Account testAccount = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Person Account')
                .getRecordTypeId(),
            HealthCloudGA__DeceasedDate__pc = null,
            LastName = 'Test',
            Date_of_Birth__pc = null
        );
        accountsToInsert.add(testAccount);

        Account testAccount2 = new Account(
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                .get('Person Account')
                .getRecordTypeId(),
            HealthCloudGA__DeceasedDate__pc = Date.newInstance(2012, 12, 12),
            LastName = 'Testerson',
            FirstName = 'Test',
            Date_of_Birth__pc = '12/1/2000'
        );
        accountsToInsert.add(testAccount2);

        insert accountsToInsert;

        Case testCase = new Case();
        insert testCase;
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as RN Persona
     */
    @IsTest
    static void testRNPersona() {
        List<Account> testAccount = [
            SELECT Id, Name, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('VCC_Registered_Nurse');
        //User testUser = buildAdminUser();
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception: ' + excep);
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as MP Persona
     */
    @IsTest
    static void testMPPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('VCC_Medical_Provider');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as AMSA Persona
     */
    @IsTest
    static void testAMSAPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('VCC_Advanced_Medical_Support_Assistant');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as PharmI Persona
     */
    @IsTest
    static void testPharmIPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('VCC_Pharmacy_I');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as PharmII Persona
     */
    @IsTest
    static void testPharmIIPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('VCC_Pharmacy_II');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as PharmIII Persona
     */
    @IsTest
    static void testPharmIIIPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('VCC_Pharmacy_III');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as MPG Persona
     */
    @IsTest
    static void testMpgPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('TED_Medical_Provider_Group');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name as RNG Persona
     */
    @IsTest
    static void testRngPersona() {
        List<Account> testAccount = [
            SELECT Id, RecordTypeId, HealthCloudGA__DeceasedDate__pc, LastName, Date_of_Birth__pc
            FROM Account
            WHERE LastName = 'Test'
        ];

        VCC_DeceasedPatientController.DeceasedInfo deceasedInfo = new VCC_DeceasedPatientController.DeceasedInfo(null);
        Test.startTest();
        User testUser = buildTestUser('TED_Registered_Nurse_Group');
        System.runAs(testUser) {
            try {
                deceasedInfo = VCC_DeceasedPatientController.getDeceasedInfo(testAccount[0].Id);
            } catch (Exception excep) {
                Logger.error('Failed to get deceased patient record: ', excep);
                Logger.saveLog();
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
        Assert.areEqual(
            null,
            deceasedInfo.birthDate,
            'Expected deceasedInfo.birthDate = null, but observed deceasedInfo.birthDate = ' + deceasedInfo.birthDate
        );
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name but no date of birth or death
     */
    @IsTest
    static void getDeceasedInfoTestNulls() {
        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = null
            );
            insert testAccount;

            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testAccount.Id
            );
            Test.stopTest();
            Assert.areEqual(
                'Test',
                deathInfo.patientName,
                'Expected patient name "Test" however observed name: ' + deathInfo.patientName
            );
            Assert.areEqual(
                null,
                deathInfo.deceasedDate,
                'Expected null deceased date, however observed date' + deathInfo.deceasedDate
            );
            Assert.areEqual(
                null,
                deathInfo.birthDate,
                'Expected null birth date, however observed date ' + deathInfo.birthDate
            );
        }

    }

    /**
     * @description tests the getDeceasedInfo method for a person account with a name but no date of birth or death
     */
    @IsTest
    static void getDeceasedInfoPatientNameTestNulls() {
        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = null
            );
            insert testAccount;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testAccount.Id
            );
            Test.stopTest();
            Assert.areEqual(
                'Test',
                deathInfo.patientName,
                'Expected correct patient name but observed: ' + deathInfo.patientName
            );
        }
    }

    /**
     * @description tests the getDeceasedInfo method for a person account without a deceased date
     */
    @IsTest
    static void getDeceasedInfoDeathDateTestNulls() {
        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = null
            );
            insert testAccount;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testAccount.Id
            );
            Test.stopTest();
            Assert.areEqual(
                null,
                deathInfo.deceasedDate,
                'Expected null deceased date but observed ' + deathInfo.deceasedDate
            );
        }
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with the correct birth date
     */
    @IsTest
    static void getDeceasedInfoBirthDateTest() {
        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = '12/1/2000'
            );
            insert testAccount;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testAccount.Id
            );
            Test.stopTest();
            Assert.areEqual(
                '12/1/2000',
                deathInfo.birthDate,
                'Expected birth date of 12/1/2000 but observed' + deathInfo.birthDate
            );
        }
    }

    /**
     * @description tests the getDeceasedInfo method for a case without a patient name
     */
    @IsTest
    static void getDeceasedInfoTestPatientNameNegative() {
        List<Case> testCase = [
            SELECT Id
            FROM Case
        ];

        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = null
            );
            insert testAccount;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testCase[0].Id
            );
            Test.stopTest();
            Assert.areEqual(
                null,
                deathInfo.patientName,
                'Expected null patient name but observed ' + deathInfo.patientName
            );
        }
    }

    /**
     * @description tests the getDeceasedInfo method for a case without a deceased date
     */
    @IsTest
    static void getDeceasedInfoTestDeceasedDateNegative() {
        List<Case> testCase = [
            SELECT Id
            FROM Case
        ];

        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = null
            );
            insert testAccount;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testCase[0].Id
            );
            Test.stopTest();
            Assert.areEqual(
                null,
                deathInfo.deceasedDate,
                'Expected null deceased date but observed date' + deathInfo.deceasedDate
            );
        }
    }

    /**
     * @description tests the getDeceasedInfo method for a case without a birthdate
     */
    @IsTest
    static void getDeceasedInfoTestBirthDateNegative() {
        List<Case> testCase = [
            SELECT Id
            FROM Case
        ];

        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = null,
                LastName = 'Test',
                Date_of_Birth__pc = null
            );
            insert testAccount;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = VCC_DeceasedPatientController.getDeceasedInfo(
                testCase[0].Id
            );
            Test.stopTest();
            Assert.areEqual(
                null,
                deathInfo.birthDate,
                'Expected birthDate = null, Observed birthdate = ' + deathInfo.birthDate
            );
        }
    }

    /**
     * @description tests the getDeceasedInfo method for a person account with the correct birth date
     */
    @IsTest
    static void unitDeceasedInfoConstructorTest() {
        System.runAs(buildTestUser('VCC_Registered_Nurse')) {
            Account testAccount2 = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName()
                    .get('Person Account')
                    .getRecordTypeId(),
                HealthCloudGA__DeceasedDate__pc = Date.newInstance(2012, 12, 12),
                LastName = 'Testerson',
                FirstName = 'Test',
                Date_of_Birth__pc = '12/1/2000'
            );
            insert testAccount2;
            Test.startTest();
            VCC_DeceasedPatientController.DeceasedInfo deathInfo = new VCC_DeceasedPatientController.DeceasedInfo(
                testAccount2
            );
            Test.stopTest();
            Assert.areEqual(
                '12/1/2000 - 12/12/2012',
                deathInfo.birthWithDeceasedDateFormatted,
                'Expected birthWithDeceasedDateFormatted = \'12/1/2000 - 10/18/2024\', but observed: ' +
                deathInfo.birthWithDeceasedDateFormatted
            );
        }
    }
}
