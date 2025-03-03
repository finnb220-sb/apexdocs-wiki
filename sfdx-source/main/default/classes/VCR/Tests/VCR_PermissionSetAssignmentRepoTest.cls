/**
 * @description Tests the VCR_PermissionSetAssignmentRepoTest class
 * @author Booz Allen
 *
 * @see VCR_PermissionSetAssignmentRepo for class being tested
 */

@IsTest
public with sharing class VCR_PermissionSetAssignmentRepoTest {
    //test reference constants
    private static final User ADMIN_USER;
    //test data
    private static final Set<String> PERMISSIONS = new Set<String>{ 'VAHC_Standard_VCC_User' };
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSets(PERMISSIONS)
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test if the VCR_PermissionSetAssignmentRepo was instantiated
     */
    @IsTest
    static void unitTestConstructorPositive() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCR_PermissionSetAssignmentRepo repo = new VCR_PermissionSetAssignmentRepo();
            Test.stopTest();
            Assert.isNotNull(repo, 'Expected constructor to properly instantiate a VCR_PermissionSetAssignmentRepo');
        }
    }
    /**
     * @description Tests if we can retrieve all the permission sets assigned to a specific used based on Id
     */
    @IsTest
    static void unitfetchAssignmentDetailsByUserIdPositive() {
        System.runAs(ADMIN_USER) {
            Set<Id> testSet = new Set<Id>();
            Set<Id> apexSet = new Set<Id>();
            User person = [SELECT Id, name FROM User LIMIT 1];
            String personId = person.Id;
            List<PermissionSetAssignment> assignmentList = [
                SELECT Id, PermissionSet.Name
                FROM PermissionSetAssignment
                WHERE AssigneeId = :personId
            ];
            for (PermissionSetAssignment psa : assignmentList) {
                testSet.add(psa.Id);
            }
            Test.startTest();
            VCR_PermissionSetAssignmentRepo repo = new VCR_PermissionSetAssignmentRepo();
            List<PermissionSetAssignment> assignmentList2 = repo.fetchPermissionSetDetailsByUserId(personId);
            for (PermissionSetAssignment psa : assignmentList2) {
                apexSet.add(psa.Id);
            }
            Test.stopTest();
            Assert.isTrue(testSet.containsAll(apexSet), 'Expected the two sets to have the same data');
        }
    }

    /**
     * @description Checks if permission sets can be sucessfully inserted
     */
    @IsTest
    static void unitPermissionSetassignmentPositive() {
        System.runAs(ADMIN_USER) {
            List<PermissionSet> setList = new List<PermissionSet>();
            List<PermissionSet> setList2 = new List<PermissionSet>();
            Set<Id> permIds = new Set<Id>();
            List<PermissionSetAssignment> assignment = new List<PermissionSetAssignment>();
            //Generate User Profile
            User person = [SELECT Id, name FROM User LIMIT 1];
            String personId = person.Id;

            //Create 5 new Permissions
            for (integer permissions = 0; permissions < 5; permissions++) {
                PermissionSet perm = new PermissionSet(
                    label = 'VCC_Test_Permissions' + permissions,
                    name = 'perm' + permissions
                );
                setList.add(perm);
            }
            insert setList;

            //Query the permission List
            setList2 = [SELECT Id FROM PermissionSet WHERE label LIKE '%VCC_Test_Permissions%'];

            //Assign PermissionSetAssignment to User
            for (PermissionSet setAssignments : setList2) {
                PermissionSetAssignment permAssignment = new PermissionSetAssignment(
                    PermissionSetId = setAssignments.Id,
                    AssigneeId = personId
                );

                assignment.add(permAssignment);
                permIds.add(setAssignments.Id);
            }

            Test.startTest();
            VCR_PermissionSetAssignmentRepo repo = new VCR_PermissionSetAssignmentRepo();
            repo.assignPermissionSets(assignment);
            Test.stopTest();
            List<PermissionSetAssignment> setList3 = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permIds
            ];
            Assert.areEqual(setList3.size(), 5, 'Expected 5 new permission set assignments to be created');
        }
    }

    /**
     * @description Checks if permission sets can be sucessfully deleted
     */
    @IsTest
    static void unitPermissionSetdeletionPositive() {
        System.runAs(ADMIN_USER) {
            List<PermissionSet> setList = new List<PermissionSet>();
            List<PermissionSet> setList2 = new List<PermissionSet>();
            Set<Id> permIds = new Set<Id>();
            List<PermissionSetAssignment> assignment = new List<PermissionSetAssignment>();
            //Generate User Profile
            User person = [SELECT Id, name FROM User LIMIT 1];
            String personId = person.Id;

            //Create 5 new Permissions
            for (integer permissions = 0; permissions < 5; permissions++) {
                PermissionSet perm = new PermissionSet(
                    label = 'VCC_Permissions' + permissions,
                    name = 'permissions' + permissions
                );
                setList.add(perm);
            }
            insert setList;

            //Query the permission List
            setList2 = [SELECT Id FROM PermissionSet WHERE label LIKE '%VCC_Permissions%'];

            //Assign PermissionSetAssignment to User
            for (PermissionSet setAssignments : setList2) {
                PermissionSetAssignment permAssignment = new PermissionSetAssignment(
                    PermissionSetId = setAssignments.Id,
                    AssigneeId = personId
                );

                assignment.add(permAssignment);
                permIds.add(setAssignments.Id);
            }

            insert assignment;
            Test.startTest();
            VCR_PermissionSetAssignmentRepo repo = new VCR_PermissionSetAssignmentRepo();
            repo.deleteUneededPermissions(assignment);
            Test.stopTest();
            List<PermissionSetAssignment> setList3 = [
                SELECT Id
                FROM PermissionSetAssignment
                WHERE PermissionSetId IN :permIds
            ];
            Assert.areEqual(setList3.size(), 0, 'Expected PermissionSetAssignment records to be deleted');
        }
    }
}
