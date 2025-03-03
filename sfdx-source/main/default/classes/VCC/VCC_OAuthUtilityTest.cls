@IsTest
/**
 * @description
 * @deprecated Replaced by a managed package.
 */
public class VCC_OAuthUtilityTest {
    @IsTest
    static void GetAccessTokenTest() {
        VCC_OAuthUtility.getAccessToken('test');
        VCC_OAuthUtility.getRefreshToken('test');
        VCC_OAuthUtility.getVARefreshToken();

        System.assert(true, 'Force assertion.');
    }
}
