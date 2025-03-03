/**
 * @description Wraps nebula logger mostly for mocking/stubbing puposes
 * @author Booz Allen Hamilton
 * @see Logger
 */
public virtual with sharing class VCC_NebulaWrapper {
    /**
     * @description Calls the Nebula Logger method of the same name.
     * @return The `String` transaction Id
     */
    public virtual String getTransactionId() {
        return Logger.getTransactionId();
    }

    /**
     * @description Calls the Nebula Logger method of the same name.
     * @param message The `String` log message.
     * @return a `LogEntry`
     */
    public virtual LogEntryEventBuilder debug(String message) {
        return Logger.debug(message);
    }

    /**
     * @description Calls the Nebula Logger method of the same name.
     * For some reason there was an error when stubbing this method with 'Exception' as it's second parameter type.
     * @param logMessage The `String` message to log.
     * @param apexException The `Exception` to log.
     * @return a `LogEntry`
     */
    public virtual LogEntryEventBuilder error(String logMessage, Object apexException) {
        if (!(apexException instanceof Exception)) {
            return this.debug(
                'Attempted to log an exception that was not an exception with log message of: ' + logMessage
            );
        }
        return Logger.error(logMessage, (Exception) apexException);
    }

    /**
     * @description Calls the Nebula Logger method of the same name.
     */
    public virtual void saveLog() {
        Logger.saveLog();
    }
}
