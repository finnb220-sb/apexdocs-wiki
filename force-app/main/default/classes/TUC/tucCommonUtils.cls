/**
 * @description Utilities class used for various Tele-EC components
 * @author Booz Allen
 */
public with sharing class tucCommonUtils {
    /**
     * @description Instantiate the user repository singleton instance
     */
    @TestVisible
    private static VCR_UserRepo userRepoInstance {
        get {
            if (userRepoInstance == null) {
                userRepoInstance = new VCR_UserRepo();
            }
            return userRepoInstance;
        }
        set;
    }

    @AuraEnabled(Cacheable=true)
    /**
     * @description Gets the current division (VISN) of the current user
     * @return  the current user division (VISN)
     */
    public static String getUserDivisionVISN() {
        User currentUser = (User) userRepoInstance.fetchById(UserInfo.getUserId(), new Set<String>{ 'Division' });
        String userVisn;
        try {
            String truncatedDivision = currentUser.Division.replaceAll('VISN ', '');
            if (truncatedDivision.isNumericSpace()) {
                userVisn = truncatedDivision;
            } else {
                throw new TUCCommonUtilsException();
            }
        } catch (Exception utilsException) {
            String errorMessage =
                'Cannot find a valid VISN under the User.Division field for the current user. ' +
                'Class tucCommonUtils, method getUserDivisionVISN() ' +
                'Please contact support. Technical error Message: ' +
                utilsException.getMessage();
            Logger.error(errorMessage, utilsException);
            Logger.saveLog();
            throw new TUCCommonUtilsException(errorMessage);
        }
        return userVisn;
    }

    /**
     * @description Checks whether the custom permission is enabled for the user
     * @param permName Name of the custom permission
     * @return Shows whether the permission is enabled (true) or disabled (false)
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean checkCustomPermission(String permName) {
        return FeatureManagement.checkPermission(permName);
    }

    /**
     * @description custom exception inheriting from Exception
     */
    @TestVisible
    private class TUCCommonUtilsException extends Exception {
    }
}
