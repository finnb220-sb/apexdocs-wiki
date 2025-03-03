/**
 * @description Helper class for PC_ProviderConnectController that holds all code that needs to be run in system mode, without sharing
 * @author      Booz Allen Hamilton
 * @since       2024
 * @see         PC_ProviderConnectController
 * @see         PC_PrcCaseShareRepo
 * @justification This class allows for necessary methods to be run in System Mode, without sharing considerations. For example, the getAssignedAgent method in the PC_ProviderConnectController retrieves the recently routed PrC Case created by the running FLP user. Since the PrC Case is now routed to an assigned agent User, that assigned agent User is now the owner of the PrC Case. Therefore, the running FLP user no longer has sharing access to that case. For our use-case purposes, we need to create a manual share for the FLP user so they can access the PrC Case again, which requires running the Share creation code in system context, without sharing.
 */
public without sharing class PC_ProviderConnectControllerSystemHelper {
    private final static String PC_CASE_SHARE_ACCESS_LEVEL = 'Edit';

    /**
     * @description repository for PC Case Share object
     */
    @TestVisible
    private static PC_PrcCaseShareRepo prcCaseShareRepo {
        get {
            return prcCaseShareRepo = prcCaseShareRepo ?? new PC_PrcCaseShareRepo();
        }
        set;
    }

    /**
     * @description  system mode, without sharing method that creates a manual Share giving Edit access to the provided PrC Case for the provided User
     * @param caseId PrC Case Id to which we need to provide Edit sharing access
     * @param userId Salesforce User to which we will provide Edit sharing access to the provided PrC Case
     * @return       `PC_Case__Share` newly inserted PrC Case share record
     * @justification see class description
     */
    public static PC_Case__Share createPcCaseShareForUser(Id caseId, Id userId) {
        PC_Case__Share caseShare = new PC_Case__Share();
        caseShare.ParentId = caseId;
        caseShare.UserOrGroupId = userId;
        caseShare.AccessLevel = PC_CASE_SHARE_ACCESS_LEVEL;

        prcCaseShareRepo.performCreateUnsafe(caseShare);
        return caseShare;
    }
}
