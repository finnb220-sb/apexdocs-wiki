/**
 * @author Booz Allen Hamilton
 * @description The base exception for DAS.
 */
public abstract class VCC_DASException extends Exception {
    private final String EXCEPTION_TEMPLATE = System.Label.VCC_DAS_Exception_EXCEPTION_TEMPLATE;

    /**
     * @description formats an exception message to add the Nebula Logger Transaction Id
     * @param message The exception message `String`.
     * @return `String` the formatted string.
     */
    private String formatExceptionTemplate(String message) {
        return String.format(
            EXCEPTION_TEMPLATE,
            new List<String>{ VCC_DAS.SERVICES.LOGGER.getTransactionId(), message }
        );
    }

    {
        if (this.getCause() != null && !(this.getCause() instanceof VCC_DASException)) {
            this.setMessage(this.formatExceptionTemplate(this.getCause().getMessage()));
            VCC_DAS.SERVICES.LOGGER.error('DAS Exception', this.getCause());
        } else if (this.getCause() == null) {
            this.setMessage(this.formatExceptionTemplate(this.getMessage()));
            VCC_DAS.SERVICES.LOGGER.error('DAS Exception', this);
        }
        VCC_DAS.SERVICES.LOGGER.saveLog();
    }

}
