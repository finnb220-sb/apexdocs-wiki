/**
 * @description This class holds memoized SObject Repositories for performing Database Operations from a LWC
 * @author      Booz Allen Hamilton
 * @since 2/12/2024
 */
public with sharing class VCC_LWCSObjectRepos {
    @TestVisible
    private static VCR_AccountRepo memoizedAccountRepo;
    @TestVisible
    private static VCR_ContactRepo memoizedContactRepo;
    @TestVisible
    private static VCR_TaskRepo memoizedTaskRepo;
    @TestVisible
    private static VCR_ProgressNoteRepo memoizedProgressNoteRepo;
    @TestVisible
    private static VCR_CaseRepo memoizedCaseRepo;

    /**
     * @description This getter prevents more than one accountRepo from being instantiated
     */
    public static VCR_AccountRepo accountRepo {
        get {
            if (memoizedAccountRepo == null) {
                memoizedAccountRepo = new VCR_AccountRepo();
            }
            return memoizedAccountRepo;
        }
    }

    /**
     * @description This getter prevents more than one contactRepo from being instantiated
     */
    public static VCR_ContactRepo contactRepo {
        get {
            if (memoizedContactRepo == null) {
                memoizedContactRepo = new VCR_ContactRepo();
            }
            return memoizedContactRepo;
        }
    }

    /**
     * @description This getter prevents more than one taskRepo from being instantiated
     */
    public static VCR_TaskRepo taskRepo {
        get {
            if (memoizedTaskRepo == null) {
                memoizedTaskRepo = new VCR_TaskRepo();
            }
            return memoizedTaskRepo;
        }
    }

    /**
     * @description This getter prevents more than one progressNoteRepo from being instantiated
     */
    public static VCR_ProgressNoteRepo progressNoteRepo {
        get {
            if (memoizedProgressNoteRepo == null) {
                memoizedProgressNoteRepo = new VCR_ProgressNoteRepo();
            }
            return memoizedProgressNoteRepo;
        }
    }

    /**
     * @description This getter prevents more than one caseRepo from being instantiated
     */
    public static VCR_CaseRepo caseRepo {
        get {
            if (memoizedCaseRepo == null) {
                memoizedCaseRepo = new VCR_CaseRepo();
            }
            return memoizedCaseRepo;
        }
    }
}
