/**
 * Author:Jaren Yach
 *  Created Date 05/13/2022
 *  Purpose: This class is a controller class for the SandboxRefreshAdmin page
 */
public inherited sharing class SandboxRefreshAdminController {
    /**
     * Determines if Sandbox
     * @return true/false
     */
    @RemoteAction
    public static Boolean isSandbox() {
        return DTCUtils.getOrgInfo().IsSandbox;
    }

    /**
     * Runs ResetNamedCredentialBatch
     * @return Job Id
     */
    @RemoteAction
    public static String runNamedCredentials() {
        return ResetNamedCredentialBatch.run();
    }

    /**
     * Runs ProfileIpRangeWhitelistBatch
     * @return Job Id
     */
    @RemoteAction
    public static String runProfileIpRange() {
        return ProfileIpRangeWhitelistBatch.run();
    }

    /**
     * Runs DeleteCustomSettingsBatch
     * @return Job Id
     */
    @RemoteAction
    public static String runDeleteCustomSettingRecords() {
        return DeleteCustomSettingsBatch.run();
    }

    /**
     * Runs RevertInvalidEmailsBatch
     * @return Job Id
     */
    @RemoteAction
    public static String runInvalidEmail() {
        return RevertInvalidEmailsBatch.run();
    }
}
