/**
 * @description Bucher + Suter is the telephony solution used by the VA Health Connect application. There may be a situation where the users need to be
 * shifted to a new productions server if their current server is experiences issues or needs maintenance. This Apex Class takes Inputs from the VCC_BS_Server_Move Flow
 * for moving b+s Assigned Users to a different b+s Production Server.
 *
 * @author      Booz Allen Hamilton
 */
public with sharing class VCC_bsContingency {
    public static String prodServerId;
    public static String newProdServerId;
    public static String division;
    /**
     * @description Input values received from Flow
     */
    public class Inputs {
        @InvocableVariable(required=true)
        public String prodServerId;
        @InvocableVariable(required=true)
        public String newProdServerId;
        @InvocableVariable
        public String division;
    }

    /**
     * @description Method utilizes Inputs from Flow and Transfers b+s Users to Specified b+s Server(newBucherConfigServer)
     * @param inputs inputs represents a list of properties set by the user in the flow
     */
    @InvocableMethod(label='VCC Bucher+Suter Production Server Move')
    public static void bucherSuterServerMove(List<Inputs> inputs) {
        extractInputs(inputs);

        // Get the B+S Assigned Users based on the Production Server Id Inputted
        List<cnx__Connects_Configuration_Assignment__c> oldServerAssignments = [
            SELECT cnx__Assigned_User__c
            FROM cnx__Connects_Configuration_Assignment__c
            WHERE cnx__Assigned_Connects_Configuration__c = :prodServerId
            WITH USER_MODE
        ];

        // Get the  B+S Production Server Where B+S Assigned Users NEED to be ASSIGNED To
        Id newBucherConfigServer = [SELECT Id FROM cnx__Connects_Configuration__c WHERE Id = :newProdServerId WITH USER_MODE]?.Id;
        if (String.isBlank(division)) {
            moveServersBasedOnOldProdServer(newBucherConfigServer, oldServerAssignments);
        } else {
            moveServersBasedOnDivision(newBucherConfigServer, oldServerAssignments, division);
        }
    }

    /**
     * @description        Moves the users assigned B+S server to the new production server based on the users that have the old production server assigned
     * @param newProdServer    The new production server to move to
     * @param oldServerAssignments The list of users that have the old production server assigned
     */
    private static void moveServersBasedOnOldProdServer(Id newProdServer, List<cnx__Connects_Configuration_Assignment__c> oldServerAssignments) {
        List<cnx__Connects_Configuration_Assignment__c> newServerAssignments = new List<cnx__Connects_Configuration_Assignment__c>();

        for (cnx__Connects_Configuration_Assignment__c oldServerAssignment : oldServerAssignments) {
            cnx__Connects_Configuration_Assignment__c newServerAssignment = new cnx__Connects_Configuration_Assignment__c();
            newServerAssignment.cnx__Assigned_User__c = oldServerAssignment.cnx__Assigned_User__c;
            newServerAssignment.cnx__Assigned_Connects_Configuration__c = newProdServer;
            newServerAssignments.add(newServerAssignment);
        }

        doUpsert(newServerAssignments);
    }

    /**
     * @description Moves the users assigned B+S server to the new production server based on the Division of the users that have the old production server assigned
     * @param newProdServer    The new production server to move to
     * @param oldServerAssignments The list of users that have the old production server assigned
     * @param division The divison field on the user object. Represents the user's VISN
     */
    private static void moveServersBasedOnDivision(Id newProdServer, List<cnx__Connects_Configuration_Assignment__c> oldServerAssignments, String division) {
        // Map to Get User Id From User Object Filtered by User Division
        Map<Id, String> userDivMap = new Map<Id, String>();
        List<User> userDivisionLst = [SELECT Id, Division FROM User WHERE Division = :division WITH USER_MODE];

        if (!userDivisionLst.isEmpty()) {
            for (User divisionUser : userDivisionLst) {
                userDivMap.put(divisionUser.Id, divisionUser.Division);
            }
        }
        // Map to Get User Id From the B+S Assigned User Object to Compare Ids with userDivMap
        Map<Id, cnx__Connects_Configuration_Assignment__c> oldServerAssignmentsMap = new Map<Id, cnx__Connects_Configuration_Assignment__c>();

        if (!oldServerAssignments.isEmpty()) {
            for (cnx__Connects_Configuration_Assignment__c oldServerAssignment : oldServerAssignments) {
                oldServerAssignmentsMap.put(oldServerAssignment.cnx__Assigned_User__c, oldServerAssignment);
            }
        }
        // List For b+s Assigned Users to be Created
        List<cnx__Connects_Configuration_Assignment__c> newServerAssignments = new List<cnx__Connects_Configuration_Assignment__c>();

        for (Id userId : userDivMap.keySet()) {
            if (oldServerAssignmentsMap.containsKey(userId)) {
                cnx__Connects_Configuration_Assignment__c newServerAssignment = new cnx__Connects_Configuration_Assignment__c();
                newServerAssignment.cnx__Assigned_User__c = userId;
                newServerAssignment.cnx__Assigned_Connects_Configuration__c = newProdServer;
                newServerAssignments.add(newServerAssignment);
            }
        }
        doUpsert(newServerAssignments);
    }
    /**
     * @description Method that calls the dml for the new server assignments
     * @param newServerAssignments Represents the list of new server assignments for the selected Users
     */
    private static void doUpsert(List<cnx__Connects_Configuration_Assignment__c> newServerAssignments) {
        try {
            Database.upsert(newServerAssignments, true, AccessLevel.USER_MODE);
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    /**
     * @description  Method for extracting the inputs from the flow. If required parameters are null, it throws an exception
     * @param inputs The inputs entered by the user in the VCC_BS_Server_Move Flow
     */
    private static void extractInputs(List<Inputs> inputs) {
        if (!inputs.isEmpty() && !String.isBlank(inputs[0]?.prodServerId) && !String.isBlank(inputs[0]?.newProdServerId)) {
            prodServerId = inputs[0]?.prodServerId.trim();
            newProdServerId = inputs[0]?.newProdServerId.trim();
            division = inputs[0]?.division;
        } else {
            throw new IllegalArgumentException('Required inputs for server Id\'s are missing.');
        }
    }
}
