/**
 *
 * Class Description
 *
 * @author barne
 * @version 1.0.0
 */

public with sharing class CICD_Utils {
    /**
     * @param jsonString
     * @param environment
     * @description method that generates users from a static resource
     * @return  List<ImportUser>
     */
    //TODO: Bulkify this logic to handle larger data sets. Currently depends on data formatted as a JSON string.
    // Investigate how to create batch APEX operations that use CSV files for more robust data sets
    public List<ImportUser> createUsers(String jsonString, String environment) {
        JSONParser parser = JSON.createParser(jsonString);
        List<ImportUser> newDevUsers = new List<CICD_Utils.ImportUser>();
        while (parser.nextToken() != null) {
            // Start at the array of invoices.
            if (parser.getCurrentToken() == JSONToken.START_ARRAY) {
                while (parser.nextToken() != null) {
                    // Advance to the start object marker to
                    //  find next invoice statement object.
                    if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                        // Read entire invoice object, including its array of line items.
                        ImportUser iUser = (ImportUser) parser.readValueAs(ImportUser.class);

                        //system.debug('UserName: ' + iUser.firstName);
                        // For debugging purposes, serialize again to verify what was parsed.
                        String s = JSON.serialize(iUser);
                        //system.debug('Serialized value: ' + iUser);
                        newDevUsers.add(iUser);
                        // Skip the child start array and start object markers.
                        //parser.skipChildren();
                    }
                }
            }
        }
        processEnvironment(newDevUsers, environment);
        return newDevUsers;
    }
    /**
     * @param userList
     * @param environment
     * @description Method to Process environment/team to remove unnecessary users from import into a sandbox
     */

    public static void processEnvironment(List<ImportUser> userList, String environment) {
        Map<Integer, ImportUser> importUserMap = new Map<Integer, CICD_Utils.ImportUser>();
        Set<Integer> keySet = importUserMap.keySet();
        Set<String> userNames = new Set<String>();
        for (ImportUser u : userList) {
            importUserMap.put(userList.indexOf(u), u);
        }
        for (Integer i : keySet) {
            ImportUser u = importUserMap.get(i);
            if (environment.startsWith('VAHCTeam')) {
                if (u.Team.startsWith('Team')) {
                    if (!environment.endsWith(u.Team)) {
                        importUserMap.remove(i);
                    }
                } else if (u.Team.equals('UAT')) {
                    importUserMap.remove(i);
                } else if (u.Team.startsWith('TED')) {
                    importUserMap.remove(i);
                }
            } else if (environment.startsWith('VAHCTED')) {
                if (u.Team.startsWith('Team') || u.Team.equals('UAT')) {
                    importUserMap.remove(i);
                }
            }
            u.username = u.username + '.' + environment.toLowerCase();
            userNames.add(u.username);
        }
        Map<String, ImportUser> usernameMap = new Map<String, CICD_Utils.ImportUser>();
        for (ImportUser user : userList) {
            usernameMap.put(user.username, user);
        }
        System.debug('SET OF UNIQUE USERNAMES FOR IMPORT===> ' + usernameMap.size());
        System.debug(usernameMap.keySet());
        userList.clear();
        userList.addAll(usernameMap.values());
    }

    /**
     * Inner Classes
     */

    /**
     * @description Inner class that servers as a constructor for Users for the CI/CD Process. Pass in a JSON string
     * with these paramaters and a JSONParses will create the below Object in memory
     */

    public class ImportUser {
        public String firstName;
        public String lastName;
        public String alias;
        public String emailEncodingKey;
        public String FederationIdentifier;
        public String LanguageLocaleKey;
        public String LocaleSidKey;
        public String Profile;
        public String TimeZoneSidKey;
        public String username;
        public Boolean IsDeveloper;
        public Boolean IsTestUser;
        public String GroupName;
        public String Permissions;
        public String Team;
        public String Email;

        public ImportUser(
            String fname,
            String lname,
            String ali,
            String emailKey,
            String fedId,
            String languageKey,
            String LocaleKey,
            String p,
            String timezoneKey,
            String uName,
            Boolean IsDev,
            Boolean IsTUser,
            String gName,
            String perm,
            String teamName,
            String iEmail
        ) {
            firstName = fname;
            lastName = lname;
            alias = ali;
            emailEncodingKey = emailKey;
            FederationIdentifier = fedId;
            LanguageLocaleKey = languageKey;
            LocaleSidKey = LocaleKey;
            Profile = p;
            TimeZoneSidKey = timezoneKey;
            username = uName;
            IsDeveloper = IsDev;
            IsTestUser = IsTUser;
            GroupName = gName;
            Permissions = perm;
            Team = teamName;
            Email = iEmail;
        }
    }
}
