/**
 * @description VCC_HttpHeaderCallingAppName class is used to represent the HTTP header field for calling application name.
 *              It inherits from the VCC_HttpHeaderField class.
 * @author      Booz Allen
 * @since       10 May 2024
 */
public with sharing class VCC_HttpHeaderCallingAppName extends VCC_HttpHeaderField {
    public static final String VCC_HTTP_HEADER_CALLING_APP_NAME = System.label.VCC_HttpHeaderName_CallingAppName;

    /**
     * @description Initializes a new HTTP header for identifying the calling application in network requests.
     *              This constructor uses a predefined system label to set the header's name and takes an application
     *              name to set as the header's value, facilitating identification and management of network requests.
     * @param appName The name of the calling application, used as the header value.
     */
    public VCC_HttpHeaderCallingAppName(String appName) {
        super(VCC_HTTP_HEADER_CALLING_APP_NAME, validateAppName(appName));
    }

    /**
     * @description Validates the application name to ensure it is not blank.
     *              This method is called before setting the header value.
     * @param appName The name of the calling application to be validated.
     * @return The validated application name.
     * @throws IllegalArgumentException if the appName is blank.
     */
    private static String validateAppName(String appName) {
        if (String.isBlank(appName)) {
            throw new IllegalArgumentException('Application name must not be blank');
        }
        return appName;
    }
}
