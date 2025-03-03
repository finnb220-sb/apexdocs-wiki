/**
 * VCC_TrainingModeUserSelector
 * @description VCC_TrainingModeUserSelector class for selecting users in training mode.
 * @author Liberty
 * @date 1/16/2024
 */
public with sharing class VCC_TrainingModeUserSelector extends VCC_UserSelector {
    /**
     * @description constructor
     */
    public VCC_TrainingModeUserSelector() {
        this.addSObjectFields(
            new List<Schema.SObjectField>{
                User.IsActive,
                User.Division,
                //User.EmployeeNumber_Int__c,
                User.Email,
                User.Title
            }
        );
    }

    /**
     * @description method to select an Employee by number
     * @param startingNumber
     * @param endingNumber
     * returns a list of users
     */
    public List<User> selectByEmployeeNumber(Integer startingNumber, Integer endingNumber) {
        fflib_QueryFactory query = newQueryFactory();
        //query.setCondition('EmployeeNumber_Int__c >= :startingNumber AND EmployeeNumber_Int__c <= :endingNumber');
        //query.setOrdering(User.EmployeeNumber_Int__c, fflib_QueryFactory.SortOrder.ASCENDING);
        query.setLimit(10000);
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description method to select an Employee by division
     * @param division takes in a string of a division
     * returns a list of users
     */
    public List<User> selectByDivision(String division) {
        String divisionExpression = String.format('{0}%', new List<String>{ division });
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Division LIKE :divisionExpression');
        //query.setOrdering(User.EmployeeNumber_Int__c, fflib_QueryFactory.SortOrder.ASCENDING);
        query.setLimit(10000);
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description method to select an Employee by Title
     * @param division takes in a string of a Title
     * returns a list of users
     */
    public List<User> selectByTitle(String title) {
        String titleExpression = String.format('{0}%', new List<String>{ title });
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('Title LIKE :titleExpression');
        //query.setOrdering(User.EmployeeNumber_Int__c, fflib_QueryFactory.SortOrder.ASCENDING);
        query.setLimit(10000);
        return (List<User>) Database.query(query.toSOQL());
    }

    /**
     * @description method to find an Employee by search string
     * @param searchString takes in a string to search by
     * returns null
     */
    public List<User> findBySearchString(String searchString) {
        /*List<List<SObject>> results = [FIND :searchString IN ALL FIELDS RETURNING User (Id, IsActive, FirstName, LastName, Username, Division, Title, Email, EmployeeNumber_Int__c)];
        if (results != null && !results.isEmpty()) {
            return (List<User>) results[0];
        }*/
        return null;
    }
}
