/**
 * @description Holds utility methods for handling exceptions for Provider Connect
 * @author      Booz Allen Hamilton
 */
public with sharing class PC_ExceptionUtils {
    /**
     * @description Entry point to logAndThrowError for usage outside of catch blocks (i.e. no exception to log) where log saving will be done in bulk
     * @param errorMsg error message to log and re-throw
     */
    public static void logAndThrowError(String errorMsg) {
        logAndThrowError(errorMsg, null, false);
    }

    /**
     * @description Entry point to logAndThrowError for usage inside of catch blocks (i.e. there's an exception to log) where log saving will be done in bulk
     * @param errorMsg          error message to log and re-throw
     * @param caughtException   caught exception to log
     */
    public static void logAndThrowError(String errorMsg, Exception caughtException) {
        logAndThrowError(errorMsg, caughtException, false);
    }

    /**
     * @description Entry point to logAndThrowError for usage outside of catch blocks (i.e. no exception to log) that automatically saves log if only one is expected
     * @param errorMsg error message to log and re-throw
     * @param saveLog  if true, calls Logger.saveLog() to automatically commit log to database
     */
    public static void logAndThrowError(String errorMsg, Boolean saveLog) {
        logAndThrowError(errorMsg, null, saveLog);
    }

    /**
     * @description Logs an error and throws a custom exception with the given error message
     * @param errorMsg          error message to log and re-throw
     * @param caughtException   caught exception to log
     * @param saveLog           if true, calls Logger.saveLog() to automatically commit log to database
     * @exception               PC_CustomException custom exception with the given error message
     */
    public static void logAndThrowError(String errorMsg, Exception caughtException, Boolean saveLog) {
        logError(errorMsg, caughtException, saveLog);

        throw new PC_CustomException(errorMsg);
    }

    /**
     * @description Logs an error and throws a illegal argument exception with the given error message (used for guard statements)
     * @param errorMsg          error message to log and re-throw
     * @exception               IllegalArgumentException illegal aurgment exception with the given error message
     */
    public static void logAndThrowIllegalArgumentError(String errorMsg) {
        logError(errorMsg, null, false);

        throw new IllegalArgumentException(errorMsg);
    }

    /**
     * @description Logs an exception using Nebula logger
     * @param errorMsg          error message to log and re-throw
     * @param caughtException   caught exception to log
     * @param saveLog           if true, calls Logger.saveLog() to automatically commit log to database
     */
    public static void logError(String errorMsg, Exception caughtException, Boolean saveLog) {
        if (caughtException == null) {
            Logger.error(errorMsg);
        } else {
            Logger.error(errorMsg, caughtException);
        }

        if (saveLog) {
            Logger.saveLog();
        }
    }

    /**
     * @description    Logs an error and throws a Aura argument exception with the given error message
     * @param errorMsg          error message to log and re-throw
     * @param caughtException   caught exception to log
     * @return    AuraHandledException being returned to class to be thrown
     */
    public static AuraHandledException logAndCreateAuraHandledException(String errorMsg, Exception caughtException) {
        logError(errorMsg, caughtException, false);
        return createAuraHandledException(errorMsg);
    }

    /**
     * @description            creates an AuraHandledException to throw while also using setMessage so that a detailed error message is shown in debug logsrather than "Script-thrown exception"
     * @param exceptionMessage The exception message to display to the use on the LWC (and in debug error logs)
     * @return                 `AuraHandledException` the generated AuraHandledException to throw
     */
    private static AuraHandledException createAuraHandledException(String exceptionMessage) {
        AuraHandledException ahException = new AuraHandledException(exceptionMessage);
        ahException.setMessage(exceptionMessage);
        return ahException;
    }
}
