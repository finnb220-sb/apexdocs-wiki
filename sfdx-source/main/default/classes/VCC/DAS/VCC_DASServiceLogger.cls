/**
 * @author Booz Allen Hamilton
 * @description A DAS service class that wraps Nebula Logger.
 */
public with sharing class VCC_DASServiceLogger {
    public final String VCC_DAS_LOGGER_TAG = System.Label.VCC_DAS_EndpointService_VCC_DAS_LOGGER_TAG;

    /**
     * @description Calls the Nebula Logger method of the same name.
     * @return The `String` transaction Id
     */
    public String getTransactionId() {
        return Logger.getTransactionId();
    }

    /**
     * @description Calls the Nebula Logger method of the same name. Also adds a log tag.
     * @param message The `String` log message.
     * @return a `LogEntryEventBuilder`
     */
    public LogEntryEventBuilder debug(String message) {
        return Logger.debug(message).addTag(VCC_DAS_LOGGER_TAG);
    }

    /**
     * @description Calls the Nebula Logger method of the same name. Also adds a log tag. For some reason there was an error when stubbing this method when it had 'Exception' as it's second parameter type.
     * @param logMessage The `String` message to log.
     * @param apexException The `Exception` to log.
     */
    public LogEntryEventBuilder error(String logMessage, Object apexException) {
        if (!(apexException instanceof Exception)) {
            return VCC_DAS.SERVICES.LOGGER.debug(
                'Attempted to log an exception that was not an exception with log message of: ' + logMessage
            );
        }
        return Logger.error(logMessage, (Exception) apexException).addTag(VCC_DAS_LOGGER_TAG);
    }

    /**
     * @description Calls the Nebula Logger method of the same name.
     */
    public void saveLog() {
        Logger.saveLog();
    }
}
