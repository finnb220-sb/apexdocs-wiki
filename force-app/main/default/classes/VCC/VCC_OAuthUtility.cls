/**
 * @deprecated Replaced by a managed package.
 */
public without sharing class VCC_OAuthUtility {
    // Get Access Token for User's current oAuth Session
    @AuraEnabled
    public static string getAccessToken(string AuthProviderName) {
        try {
            String accessToken = Auth.AuthToken.getAccessToken(getAuthProvider(AuthProviderName).Id, getAuthProvider(AuthProviderName).FriendlyName);
            return accessToken;
        } catch (Exception ex) {
            Log.debug(string.ValueOf(ex));
            return null;
        }
    }

    // Get Access Token for User's current oAuth Session
    @AuraEnabled
    public static Map<String, String> getRefreshToken(string AuthProviderName) {
        try {
            Map<String, String> refreshToken = Auth.AuthToken.refreshAccessToken(
                getAuthProvider(AuthProviderName).Id,
                getAuthProvider(AuthProviderName).FriendlyName,
                getAccessToken(authProviderName)
            );
            return refreshToken;
        } catch (Exception ex) {
            Log.debug(string.ValueOf(ex));
            if (Test.isRunningTest()) {
                return new Map<String, String>();
            }
            return null;
        }
    }

    @InvocableMethod(category='Auth')
    public static List<String> getVARefreshToken() {
        Map<String, String> refreshToken = getRefreshToken('VA SSOi');
        List<String> returnOfTheStrings = new List<String>();

        if (refreshToken.get('RefreshError') != null) {
            returnOfTheStrings.add(refreshToken.get('RefreshError'));
        } else {
            returnOfTheStrings.add(refreshToken.get('AccessToken'));
        }
        return returnOfTheStrings;
    }
    /*
    @AuraEnabled
    public static string getOrgType() {
    // Get Org Type from Custom Metadata
    String orgType = [SELECT Id, vccType__c FROM VCC_Org_Settings__mdt WHERE vccOrgId__c =: UserInfo.getOrganizationId()].vccType__c;
    return orgType;
    }
    */

    @AuraEnabled
    public static AuthProvider getAuthProvider(string AuthProviderName) {
        /* Get Auth Provider
        AuthProvider authProvider = [SELECT Id, DeveloperName, FriendlyName FROM AuthProvider WHERE DeveloperName =: AuthProviderName + '_' + getOrgType()];
        The line above was previously used, but since each org will have the same AuthProvider name we are removing the suffix.
        */
        AuthProvider authProvider;
        List<AuthProvider> authProviders = [SELECT Id, DeveloperName, FriendlyName FROM AuthProvider WHERE DeveloperName = :AuthProviderName WITH SECURITY_ENFORCED];
        if (!authProviders.isEmpty()) {
            authProvider = authProviders[0];
        }
        if (Test.isRunningTest()) {
            authProvider = new AuthProvider();
        }
        return authProvider;
        //AuthProvider authProvider = [SELECT Id, DeveloperName, FriendlyName FROM AuthProvider WHERE DeveloperName =: AuthProviderName];
        //return authProvider;
    }
}
