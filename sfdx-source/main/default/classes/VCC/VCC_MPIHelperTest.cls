/**
 * @description Test class for VCC_MPIHelper for various MPI-related needs.
 * @group API - MPI
 * @author Booz Allen
 * @since 6/30/2021
 *
 * @author Patrick Skamarak
 * @since 02/08/2024 CCCM-29964
 **/
@IsTest
public with sharing class VCC_MPIHelperTest {
    @TestSetup
    static void makeData() {
        User testRn = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        testRn.Username = 'mpiHelperTestUser@test.test';
        update testRn;
        VCC_TestDataFactory.addPermSetGroupToUser('VCC_Registered_Nurse', testRn);
    }

    private static User getTestUser() {
        return [
            SELECT Id
            FROM User
            WHERE Username = 'mpiHelperTestUser@test.test'
            LIMIT 1
        ];
    }

    private static Id testSetupUpdateAccount(User testUser) {
        Account testAccount = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount']
            .Id,
            LastName = 'Smith'
        );
        insert testAccount;
        Id accountId = testAccount.Id;
        insert new AccountShare(
            AccountAccessLevel = 'Edit',
            AccountId = accountId,
            OpportunityAccessLevel = 'Edit',
            UserOrGroupId = testUser.Id
        );
        return testAccount.Id;
    }

    private static void testSetupGetFacilityNames() {
        Id facilityRecTypeId = Schema.SObjectType.Location.getRecordTypeInfosByDeveloperName()
            .get('VAF_VA_Facility')
            .getRecordTypeId();
        Database.insert(
            new List<Schema.Location>{
                new Schema.Location(
                    Name = 'Test Facility 983',
                    VAF_Facility_ID__c = 'vha_983',
                    RecordTypeId = facilityRecTypeId,
                    LocationType = 'Site'
                ),
                new Schema.Location(
                    Name = 'Test Facility 984',
                    VAF_Facility_ID__c = 'vha_984',
                    RecordTypeId = facilityRecTypeId,
                    LocationType = 'Site'
                ),
                new Schema.Location(
                    Name = 'Test Facility 999',
                    VAF_Facility_ID__c = 'vha_999',
                    RecordTypeId = facilityRecTypeId,
                    LocationType = 'Site'
                )
            },
            false
        );
    }

    private static Id testSetupUpdateVaProfileAndEsr() {
        Account testAccount = new Account(
            RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount']
            .Id,
            LastName = 'Smith'
        );
        insert testAccount;
        insert new AccountShare(
            AccountId = testAccount.Id,
            UserOrGroupId = getTestUser().Id,
            AccountAccessLevel = 'Edit',
            OpportunityAccessLevel = 'Edit'
        );
        return testAccount.Id;
    }

    @IsTest
    static void unitSetEnrolledPositive() {
        Account accountInMemory = new Account();
        VCC_MPIParser.EE enrollmentEligibility = new VCC_MPIParser.EE();
        enrollmentEligibility.eeExtendedResponse.enrollmentDetermination = new VCC_MPIParser.EEEnrollmentDetermination();
        enrollmentEligibility.eeExtendedResponse.enrollmentDetermination.enrollmentStatus = 'Enrolled';
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MPIHelper.setEnrolled(accountInMemory, enrollmentEligibility);
            Test.stopTest();
        }
        Assert.isTrue(
            accountInMemory.VCC_Enrolled__pc,
            'Expected the field VCC_Enrolled__pc to be boolean "true" because MPI enrollment status is "Enrolled"'
        );
    }

    @IsTest
    static void updateAccountNameAllArgsNullNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_MPIHelper.updateAccountNameFromMpi(null, null);
                Assert.fail('Expected a VCC_MPIHelper.UpdatePatientNameException to be thrown');
            } catch (Exception thrownException) {
                Assert.isInstanceOfType(
                    thrownException,
                    VCC_MPIHelper.UpdatePatientNameException.class,
                    'Expected exception to be an instance of VCC_MPIHelper.UpdatePatientNameException.'
                );
                Assert.areEqual(
                    VCC_MPIHelper.NULL_ARG_MESSAGE,
                    thrownException.getMessage(),
                    'Expected to find exception message defined in VCC_MPIHelper.NULL_ARG_MESSAGE'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void updateAccountNameFirstArgNulllNegative() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.MVI mviData = new VCC_MPIParser.MVI();
            Test.startTest();
            try {
                VCC_MPIHelper.updateAccountNameFromMpi(null, mviData);
                Assert.fail('Expected a VCC_MPIHelper.UpdatePatientNameException to be thrown');
            } catch (Exception thrownException) {
                Assert.isInstanceOfType(
                    thrownException,
                    VCC_MPIHelper.UpdatePatientNameException.class,
                    'Expected exception to be an instance of VCC_MPIHelper.UpdatePatientNameException.'
                );
                Assert.areEqual(
                    VCC_MPIHelper.NULL_ARG_MESSAGE,
                    thrownException.getMessage(),
                    'Expected to find exception message defined in VCC_MPIHelper.NULL_ARG_MESSAGE'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void updateAccountNameSecondArgNullNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                VCC_MPIHelper.updateAccountNameFromMpi('000000000000000000', null);
                Assert.fail('Expected a VCC_MPIHelper.UpdatePatientNameException to be thrown');
            } catch (Exception thrownException) {
                Assert.isInstanceOfType(
                    thrownException,
                    VCC_MPIHelper.UpdatePatientNameException.class,
                    'Expected exception to be an instance of VCC_MPIHelper.UpdatePatientNameException.'
                );
                Assert.areEqual(
                    VCC_MPIHelper.NULL_ARG_MESSAGE,
                    thrownException.getMessage(),
                    'Expected to find exception message defined in VCC_MPIHelper.NULL_ARG_MESSAGE'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void updateAccountNameNoQueryResultNegative() {
        System.runAs(getTestUser()) {
            VCC_MPIParser.MVI mviData = new VCC_MPIParser.MVI();
            Test.startTest();
            try {
                VCC_MPIHelper.updateAccountNameFromMpi('000000000000000000', mviData);
                Assert.areEqual(1, System.Limits.getQueries(), 'Expected just one query.');
            } catch (Exception thrownException) {
                Assert.isInstanceOfType(thrownException, System.QueryException.class, 'Expected query exception.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void updateAccountNameNoChangePositive() {
        User testRn = getTestUser();
        Id accountId = testSetupUpdateAccount(testRn);
        VCC_MPIParser.MVI mviData = new VCC_MPIParser.MVI();
        mviData.lastName = 'sMiTH';
        Test.startTest();
        System.runAs(testRn) {
            try {
                VCC_MPIHelper.updateAccountNameFromMpi(accountId, mviData);
            } catch (Exception thrownException) {
                Assert.fail(
                    thrownException.getTypeName() +
                        ' was unexpectedly thrown. Stack trace: ' +
                        thrownException.getStackTraceString()
                );
            }
        }
        Test.stopTest();
        Assert.areEqual(
            'Smith',
            [SELECT LastName FROM Account WHERE Id = :accountId LIMIT 1].LastName,
            'Expected Account.LastName to remain "Smith"'
        );
    }

    @IsTest
    static void updateAccountNameWithLastNameChangePositive() {
        User testRn = getTestUser();
        Id accountId = testSetupUpdateAccount(testRn);
        VCC_MPIParser.MVI mviData = new VCC_MPIParser.MVI();
        mviData.lastName = 'SOMETHING';

        Test.startTest();
        System.runAs(testRn) {
            try {
                VCC_MPIHelper.updateAccountNameFromMpi(accountId, mviData);
            } catch (Exception thrownException) {
                Assert.fail(
                    thrownException.getTypeName() +
                        ' was unexpectedly thrown. Stack trace: ' +
                        thrownException.getStackTraceString()
                );
            }
        }
        Test.stopTest();

        Assert.areEqual(
            mviData.lastName,
            [SELECT LastName FROM Account WHERE Id = :accountId WITH SYSTEM_MODE LIMIT 1].LastName,
            'Expected to find changed LastName value'
        );
    }

    @IsTest
    static void updateAccountNameWithFirstNameChangePositive() {
        User testRn = getTestUser();
        Id accountId = testSetupUpdateAccount(testRn);
        VCC_MPIParser.MVI mviData = new VCC_MPIParser.MVI();
        mviData.firstName = 'FIRST';
        Test.startTest();
        System.runAs(testRn) {
            try {
                VCC_MPIHelper.updateAccountNameFromMpi(accountId, mviData);
            } catch (Exception thrownException) {
                Assert.fail(
                    thrownException.getTypeName() +
                        ' was unexpectedly thrown. Stack trace: ' +
                        thrownException.getStackTraceString()
                );
            }
        }
        Test.stopTest();

        Assert.areEqual(
            mviData.firstName,
            [SELECT FirstName FROM Account WHERE Id = :accountId WITH SYSTEM_MODE LIMIT 1].FirstName,
            'Expected to find changed FirstName value'
        );
    }

    @IsTest
    static void updateAccountNameWithMiddleNameChangePositive() {
        User testRn = getTestUser();
        Id accountId = testSetupUpdateAccount(testRn);
        VCC_MPIParser.MVI mviData = new VCC_MPIParser.MVI();
        mviData.middleName = 'AMIDDLENAME';

        Test.startTest();
        System.runAs(testRn) {
            try {
                VCC_MPIHelper.updateAccountNameFromMpi(accountId, mviData);
            } catch (Exception thrownException) {
                Assert.fail(
                    thrownException.getTypeName() +
                        ' was unexpectedly thrown. Stack trace: ' +
                        thrownException.getStackTraceString()
                );
            }
        }
        Test.stopTest();

        Assert.areEqual(
            mviData.middleName,
            [SELECT MiddleName FROM Account WHERE Id = :accountId WITH SYSTEM_MODE LIMIT 1].MiddleName,
            'Expected to find changed MiddleName value'
        );
    }

    /**
     * @description updateESRTestRunAs
     * @return Nothing
     **/
    @IsTest
    public static void updateESRTestRunAs() {
        String uniqueUserName = 'esrTest' + Datetime.now().getTime() + '@testorg.com';
        Profile p = [SELECT Id FROM Profile WHERE Name = 'Standard User'];
        User standardUser = new User(
            Alias = 'standt',
            Email = 'standarduser@testorg.com',
            EmailEncodingKey = 'UTF-8',
            LastName = 'Testing',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US',
            ProfileId = p.Id,
            TimeZoneSidKey = 'America/Los_Angeles',
            Username = uniqueUserName
        );
        insert standardUser;
        Id permSetId = [SELECT Id FROM PermissionSet WHERE Name = 'VAHC_Standard_VCC_User' LIMIT 1].Id;
        insert new PermissionSetAssignment(PermissionSetId = permSetId, AssigneeId = standardUser.Id);

        VCC_MPIParser.EE mockEE = new VCC_MPIParser.EE();
        mockEE.eeExtendedResponse = new VCC_MPIParser.EEExtendedResponse();
        mockEE.eeExtendedResponse.demographics = new VCC_MPIParser.EEDemographics();
        mockEE.eeExtendedResponse.associations = new List<VCC_MPIParser.EEAssociation>();
        mockEE.eeExtendedResponse.demographics.preferredFacility = 'PRFD';

        VCC_MPIParser.EEAssociation pnok = new VCC_MPIParser.EEAssociation();
        VCC_MPIParser.EEAssociation ec = new VCC_MPIParser.EEAssociation();
        VCC_MPIParser.EEAssociation pc = new VCC_MPIParser.EEAssociation();
        VCC_MPIParser.EEAssociation oec = new VCC_MPIParser.EEAssociation();
        VCC_MPIParser.EEAssociation opnok = new VCC_MPIParser.EEAssociation();

        pnok.contactType = 'Primary Next of Kin';
        opnok.contactType = 'Other Next of Kin';
        ec.contactType = 'Emergency Contact';
        oec.contactType = 'Other emergency contact';
        pc.contactType = 'Primary Caregiver';

        pnok.primaryPhone = 'pnok_primaryPhone';
        ec.primaryPhone = 'ec_primaryPhone';
        pc.primaryPhone = 'pc_primaryPhone';

        pnok.givenName = 'pnok_givenName';
        ec.givenName = 'ec_givenName';
        pc.givenName = 'pc_givenName';

        pnok.familyName = 'pnok_familyName';
        ec.familyName = 'ec_familyName';
        pc.familyName = 'pc_familyName';

        opnok.primaryPhone = 'pnok_primaryPhone';
        oec.primaryPhone = 'ec_primaryPhone';

        opnok.givenName = 'pnok_givenName';
        oec.givenName = 'ec_givenName';

        opnok.familyName = 'pnok_familyName';
        oec.familyName = 'ec_familyName';

        mockEE.eeExtendedResponse.associations.add(pnok);
        mockEE.eeExtendedResponse.associations.add(ec);
        mockEE.eeExtendedResponse.associations.add(pc);
        mockEE.eeExtendedResponse.associations.add(pc);

        mockEE.eeExtendedResponse.associations.add(opnok);
        mockEE.eeExtendedResponse.associations.add(oec);

        System.runAs(standardUser) {
            Account fakeAcc = new Account(
                RecordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'PersonAccount']
                .Id,
                LastName = 'ESRSmith'
            );
            insert fakeAcc;
            VCC_MPIHelper.updateESR(fakeAcc.Id, mockEE);
        }

        Account acc = [
            SELECT
                VCC_Primary_Facility__c,
                VCC_Enrolled__pc,
                VCC_Next_of_Kin__pc,
                VCC_Next_of_Kin_Phone__pc,
                VCC_Emergency_Contact__pc,
                VCC_Emergency_Contact_Phone__pc,
                VCC_Primary_Caregiver__pc,
                VCC_Primary_Caregiver_Phone__pc
            FROM Account
            WHERE LastName = 'ESRSmith'
            LIMIT 1
        ];

        System.assert(acc.VCC_Primary_Facility__c == 'PRFD', 'Record did not update all fields');
        System.assert(acc.VCC_Enrolled__pc == false, 'Record did not update all fields');
        System.assert(acc.VCC_Next_of_Kin__pc == 'pnok_givenName pnok_familyName', 'Record did not update all fields');
        System.assert(acc.VCC_Next_of_Kin_Phone__pc == 'pnok_primaryPhone', 'Record did not update all fields');
        System.assert(
            acc.VCC_Emergency_Contact__pc == 'ec_givenName ec_familyName',
            'Record did not update all fields'
        );
        System.assert(acc.VCC_Emergency_Contact_Phone__pc == 'ec_primaryPhone', 'Record did not update all fields');
        System.assert(
            acc.VCC_Primary_Caregiver__pc == 'pc_givenName pc_familyName',
            'Record did not update all fields'
        );
        System.assert(acc.VCC_Primary_Caregiver_Phone__pc == 'pc_primaryPhone', 'Record did not update all fields');
    }

    /**
     * @description updateESRTest
     * @return Nothing
     **/
    @IsTest
    public static void updateESRTest() {
        String acctId = testSetupUpdateVaProfileAndEsr();

        VCC_MPIParser.EE mockEE = new VCC_MPIParser.EE();
        mockEE.eeExtendedResponse = new VCC_MPIParser.EEExtendedResponse();
        mockEE.eeExtendedResponse.associations = new List<VCC_MPIParser.EEAssociation>();
        mockEE.eeExtendedResponse.demographics = new VCC_MPIParser.EEDemographics();
        mockEE.eeExtendedResponse.demographics.preferredFacility = '823 TEST1';
        VCC_MPIParser.EEAssociation assoc = new VCC_MPIParser.EEAssociation();

        assoc.givenName = 'John';
        assoc.familyName = 'Smith';
        assoc.primaryPhone = '222-222-1234';
        assoc.contactType = 'Primary Next of Kin';

        mockEE.eeExtendedResponse.associations.add(assoc);
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MPIHelper.updateESR(acctId, mockEE);

            assoc.contactType = 'Emergency Contact';
            assoc.primaryPhone = '111-111-1234';

            VCC_MPIHelper.updateESR(acctId, mockEE);
            Test.stopTest();
        }

        Account acctWithFields = [
            SELECT
                Id,
                VCC_Next_of_Kin_Phone__pc,
                VCC_Emergency_Contact_Phone__pc,
                VCC_Primary_Facility__c,
                VCC_Next_of_Kin__pc,
                VCC_Enrolled__pc,
                VCC_Emergency_Contact__pc
            FROM Account
            WHERE Id = :acctId
            LIMIT 1
        ];

        System.assert(
            acctWithFields.VCC_Primary_Facility__c == '823 TEST1',
            'VCC_MPIHelper updateESR did not set fields correctly. Expected: 823 TEST1, Actual: ' +
            acctWithFields.VCC_Primary_Facility__c
        );
        // System.assert(acctWithFields.VCC_Enrolled__pc,
        //     'VCC_MPIHelper updateESR did not set fields correctly. Expected: true, Actual: '+acctWithFields.VCC_Enrolled__pc);
        System.assert(
            acctWithFields.VCC_Next_of_Kin_Phone__pc == '222-222-1234',
            'VCC_MPIHelper updateESR did not set fields correctly. Expected: 222-222-1234, Actual: ' +
            acctWithFields.VCC_Next_of_Kin_Phone__pc
        );
        System.assert(
            acctWithFields.VCC_Emergency_Contact_Phone__pc == '111-111-1234',
            'VCC_MPIHelper updateESR did not set fields correctly. Expected: 111-111-1234, Actual: ' +
            acctWithFields.VCC_Emergency_Contact_Phone__pc
        );
        System.assert(
            acctWithFields.VCC_Next_of_Kin__pc.contains('John') && acctWithFields.VCC_Next_of_Kin__pc.contains('John'),
            'VCC_MPIHelper updateESR did not set fields correctly. Expected: VCC_Next_of_Kin__pc contains John Smith, Actual: ' +
            acctWithFields.VCC_Next_of_Kin__pc
        );
        System.assert(
            acctWithFields.VCC_Emergency_Contact__pc.contains('John') &&
            acctWithFields.VCC_Emergency_Contact__pc.contains('John'),
            'VCC_MPIHelper updateESR did not set fields correctly. Expected: VCC_Emergency_Contact__pc contains John Smith, Actual: ' +
            acctWithFields.VCC_Emergency_Contact__pc
        );
    }

    /**
     * @description updateVAProfileTest
     * @return Nothing
     **/
    @IsTest
    public static void updateVAProfileTest() {
        String acctId = testSetupUpdateVaProfileAndEsr();

        VCC_MPIParser.VAProfileAddress addy1 = new VCC_MPIParser.VAProfileAddress();
        VCC_MPIParser.VAProfileAddress addy2 = new VCC_MPIParser.VAProfileAddress();
        VCC_MPIParser.VAProfileEmail email = new VCC_MPIParser.VAProfileEmail();
        VCC_MPIParser.VAProfileTelephone telephone1 = new VCC_MPIParser.VAProfileTelephone();
        VCC_MPIParser.VAProfileTelephone telephone2 = new VCC_MPIParser.VAProfileTelephone();
        VCC_MPIParser.VAProfileTelephone telephone3 = new VCC_MPIParser.VAProfileTelephone();
        VCC_MPIParser.VAProfileTelephone telephone4 = new VCC_MPIParser.VAProfileTelephone();

        addy1.addressLine1 = 'Test Address Line 1';
        addy1.zipCode5 = '12456';
        addy1.cityName = 'Test City';
        addy1.stateCode = 'Test State';
        addy1.countryName = 'Test Country';
        addy1.addressPurposeOfUse = 'RESIDENCE';

        addy2.addressLine1 = 'Test Address Line 1 v2';
        addy2.zipCode5 = '12456';
        addy2.cityName = 'Test City';
        addy2.stateCode = 'Test State';
        addy2.countryName = 'Test Country';
        addy2.addressPurposeOfUse = 'CORRESPONDENCE';

        email.emailAddressText = 'test@test.com';

        telephone1.phoneType = 'WORK';
        telephone1.areaCode = '111';
        telephone1.phoneNumber = '1111111';
        telephone2.phoneType = 'HOME';
        telephone2.areaCode = '222';
        telephone2.phoneNumber = '2222222';
        telephone3.phoneType = 'TEMPORARY';
        telephone3.areaCode = '333';
        telephone3.phoneNumber = '3333333';
        telephone4.phoneType = 'MOBILE';
        telephone4.areaCode = '444';
        telephone4.phoneNumber = '4444444';

        String mockData = JSON.serialize(
            new Map<String, Object>{
                'vaProfileV2' => new Map<String, Object>{
                    'vaProfileContactInfo' => new Map<String, Object>{
                        'addresses' => new List<VCC_MPIParser.VAProfileAddress>{ addy1, addy2 },
                        'emails' => new List<VCC_MPIParser.VAProfileEmail>{ email },
                        'telephones' => new List<VCC_MPIParser.VAProfileTelephone>{
                            telephone1,
                            telephone2,
                            telephone3,
                            telephone4
                        }
                    }
                }
            }
        );

        VCC_MPIParser.VetDetails mockVaProfileV2 = (VCC_MPIParser.VetDetails) JSON.deserialize(
            mockData,
            VCC_MPIParser.VetDetails.class
        );

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MPIHelper.updateVAProfile(acctId, mockVaProfileV2.vaProfileV2);
            Test.stopTest();
        }

        Account acctWithFields = [
            SELECT Id, BillingStreet, PersonMailingStreet
            FROM Account
            LIMIT 1
        ];

        VCC_MPIHelper.generateMPIBody('123', new Set<String>{ '123' });

        System.assert(
            acctWithFields.BillingStreet == 'Test Address Line 1',
            'VCC_MPIHelper updateVAProfile did not set fields correctly.'
        );
        System.assert(
            acctWithFields.PersonMailingStreet == 'Test Address Line 1 v2',
            'VCC_MPIHelper updateVAProfile did not set fields correctly.'
        );
    }

    /**
     * @description updateVAProfileTest
     * @return Nothing
     **/
    @IsTest
    public static void updateVAProfileTestV1() {
        String acctId = testSetupUpdateVaProfileAndEsr();

        VCC_MPIParser.VAProfileAddress addy1 = new VCC_MPIParser.VAProfileAddress();
        VCC_MPIParser.VAProfileAddress addy2 = new VCC_MPIParser.VAProfileAddress();
        VCC_MPIParser.VAProfileEmail email = new VCC_MPIParser.VAProfileEmail();
        VCC_MPIParser.VAProfileTelephone telephone1 = new VCC_MPIParser.VAProfileTelephone();
        VCC_MPIParser.VAProfileTelephone telephone2 = new VCC_MPIParser.VAProfileTelephone();
        VCC_MPIParser.VAProfileTelephone telephone3 = new VCC_MPIParser.VAProfileTelephone();
        VCC_MPIParser.VAProfileTelephone telephone4 = new VCC_MPIParser.VAProfileTelephone();

        addy1.addressLine1 = 'Test Address Line 1';
        addy1.zipCode5 = '12456';
        addy1.cityName = 'Test City';
        addy1.stateCode = 'Test State';
        addy1.countryName = 'Test Country';
        addy1.addressPurposeOfUse = 'RESIDENCE';

        addy2.addressLine1 = 'Test Address Line 1 v2';
        addy2.zipCode5 = '12456';
        addy2.cityName = 'Test City';
        addy2.stateCode = 'Test State';
        addy2.countryName = 'Test Country';
        addy2.addressPurposeOfUse = 'CORRESPONDENCE';

        email.emailAddressText = 'test@test.com';

        telephone1.phoneType = 'WORK';
        telephone1.areaCode = '111';
        telephone1.phoneNumber = '1111111';
        telephone2.phoneType = 'HOME';
        telephone2.areaCode = '222';
        telephone2.phoneNumber = '2222222';
        telephone3.phoneType = 'TEMPORARY';
        telephone3.areaCode = '333';
        telephone3.phoneNumber = '3333333';
        telephone4.phoneType = 'MOBILE';
        telephone4.areaCode = '444';
        telephone4.phoneNumber = '4444444';

        String mockData = JSON.serialize(
            new Map<String, Object>{
                'vaProfileV1' => new Map<String, Object>{
                    'vaProfileContactInfo' => new Map<String, Object>{
                        'addresses' => new List<VCC_MPIParser.VAProfileAddress>{ addy1, addy2 },
                        'emails' => new List<VCC_MPIParser.VAProfileEmail>{ email },
                        'telephones' => new List<VCC_MPIParser.VAProfileTelephone>{
                            telephone1,
                            telephone2,
                            telephone3,
                            telephone4
                        }
                    }
                }
            }
        );

        VCC_MPIParser.VetDetails mockVaProfileV1 = (VCC_MPIParser.VetDetails) JSON.deserialize(
            mockData,
            VCC_MPIParser.VetDetails.class
        );

        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_MPIHelper.updateVAProfile(acctId, mockVaProfileV1.vaProfileV1);
            Test.stopTest();
        }

        Account acctWithFields = [
            SELECT Id, BillingStreet, PersonMailingStreet
            FROM Account
            LIMIT 1
        ];

        VCC_MPIHelper.generateMPIBody('123', new Set<String>{ '123' });

        System.assert(
            acctWithFields.BillingStreet == 'Test Address Line 1',
            'VCC_MPIHelper updateVAProfile did not set fields correctly.'
        );
        System.assert(
            acctWithFields.PersonMailingStreet == 'Test Address Line 1 v2',
            'VCC_MPIHelper updateVAProfile did not set fields correctly.'
        );
    }
}
