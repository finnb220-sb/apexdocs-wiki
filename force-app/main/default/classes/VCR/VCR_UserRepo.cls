/**
 * @description This repository class is for the "User" standard object database operations.
 * @author Booz Allen
 */

public inherited sharing class VCR_UserRepo extends VTC_BaseRepo {
    /**
     * @description Constructor
     */
    public VCR_UserRepo() {
        super(User.SObjectType);
    }

    /**
     * @description Gets Id based on user selected
     * @param name The name of the user whose Id you want to fetch
     * @return The string of the UserId
     */
    public List<User> getIdByName(String name) {
        return fetch('SELECT Id, Name FROM USER WHERE Name = :name', new Map<String, Object>{ 'name' => name });
    }

    /**
     * @description Gets User based on provided Last Name
     * @param lastName String last name to search for
     * @return returns a List of users with the given last name
     */
    public List<User> getIdByLastName(String lastName) {
        return fetch(
            'SELECT Id, LastName FROM USER WHERE LastName = :lastName',
            new Map<String, Object>{ 'lastName' => lastName }
        );
    }

    /**
     * @description   retrieves a list of User records with a Salesforce Id in the provided set of Ids
     * @param userIds Set of User Salesforce Ids
     * @return        `List<User>` List of User records with the provided Ids
     */
    public List<User> fetchUsersByIds(Set<String> userIds) {
        String selectClause = 'SELECT Id, Name, Title, Email, City, State, Department, MediumPhotoUrl';
        String fromClause = this.calculateFromClause();
        String whereClause = 'WHERE Id IN :userIds';
        String query = selectClause + ' ' + fromClause + ' ' + whereClause;
        return (List<User>) this.fetch(query, new Map<String, Object>{ 'userIds' => userIds });
    }
}
