/**
 * @description       :
 * @author            : Ronald Stewart
 * @group             :
 * @last modified on  : 01-11-2024
 * @last modified by  : Ronald Stewart
 **/
@isTest
public with sharing class VCC_BridgRequestTest {
    @TestSetup
    static void makeData() {
        Id profileId = DTCTestUtil.getProfileId('VAVET Base Profile');
        User vahcUser = DTCTestUtil.createUserWithProfile(profileId);
        List<String> permissionSets = new List<String>{ 'VAHC Registered Nurse', 'VCC Integration Test Utility User' };
        DTCTestUtil.addPermSetsToUser(vahcUser, permissionSets);
    }

    @isTest
    static void testValidRequest() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            String nationalId = '123456789';

            // Act
            Test.startTest();
            VCC_BridgRequest request = new VCC_BridgRequest(nationalId);
            Test.stopTest();

            // Assert
            System.assertEquals(true, request.isValid(), 'Bridge Request should be valid | method: testValidRequest');
        }
        // Arrange
    }
    @isTest
    static void testValidienRequest() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            // Arrange
            String assigningFacility = 'Facility1';
            String ienID = '123456';

            // Act
            Test.startTest();
            VCC_BridgRequest request = new VCC_BridgRequest(assigningFacility, ienID);
            Test.stopTest();

            // Assert
            System.assertEquals(true, request.isValid(), 'Bridge Request should be valid | method: testValidienRequest');
        }
    }

    @isTest
    static void testInvalidRequest() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            // Arrange
            String assigningFacility = 'Facility1';
            Boolean errorThrown = false;
            // Act and Assert
            Test.startTest();
            try {
                new VCC_BridgRequest(assigningFacility, null);
            } catch (VCC_BridgRequest.VCC_BridgRequestException e) {
                errorThrown = true;
            }
            System.assert(errorThrown == true, 'Error was thrown when for Invalid Request | method: testInvalidRequest');
            Test.stopTest();
        }

    }

    @isTest
    static void testInvalidNationalIdRequest() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            // Arrange
            Boolean errorThrown = false;
            // Act and Assert
            Test.startTest();
            try {
                new VCC_BridgRequest(null);
            } catch (VCC_BridgRequest.VCC_BridgRequestException e) {
                errorThrown = true;
            }
            System.assert(errorThrown == true, 'Error was thrown when for Invalid Request | method: testInvalidNationalIdRequest');
            Test.stopTest();
        }
    }

    @isTest
    static void testRequestNotNull() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            // Act and Assert
            Test.startTest();
            VCC_BridgRequest request = new VCC_BridgRequest();
            System.assert(request != null, 'Bridge Request instantiatized as null | method: testRequestNotNull');
            Test.stopTest();
        }
    }

    @isTest
    static void testStringify() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            // Arrange
            String assigningFacility = 'Facility1';
            String nationalId = '123456789';
            VCC_BridgRequest request = new VCC_BridgRequest(assigningFacility, nationalId);

            // Act
            String jsonString = request.stringify();

            // Assert
            System.assertNotEquals(null, jsonString, 'Request is null for Bridge Request | method: testStringify');
        }

    }
}
