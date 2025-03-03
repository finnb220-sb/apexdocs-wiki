/**
 * @description An abstract definition of an HTTP header field-name:field-value pair. The hope is that
 * classes that extend this will define a static final header name (bonus if its a custom label) to pass into super().
 * Either way, unit tests of extending classes should show that the header name is valid. Header
 * field-value string permits any valid String, at least, that's how I understand it. Hopefully unit
 * tests will adequately show that to be true.
 *
 * @author Patrick Skamarak
 * @since 02/22/2024
 */
public abstract with sharing class VCC_HttpHeaderField {
    @TestVisible
    private static final String INVALID_HEADER_NAME_EXCEPTION_MESSAGE = '"{0}" is not a valid http header name';

    @TestVisible
    private static final String NULL_HEADER_VALUE_EXCEPTION_MESSAGE = 'Http header value must not be null';

    @TestVisible
    private String name;

    @TestVisible
    private String value;

    /**
     * @description protected constructor for use in extended classes that
     * validates and sets header name and value properties.
     *
     * @param name header field-name
     * @param value header field-value
     * @exception `InvalidHeaderNameException` is thrown if header name contains invalid characters
     * @exception `NullHeaderValueException` is thrown if value arg is null
     * @see `VCC_HttpHeaderField.validateHeaderName`
     */
    protected VCC_HttpHeaderField(String name, String value) {
        if (value == null) {
            throw new NullHeaderValueException(NULL_HEADER_VALUE_EXCEPTION_MESSAGE);
        }
        validateHeaderName(name); // handles null for name
        this.name = name;
        this.value = value;
    }

    @TestVisible
    /**
     * @description Validates that the HTTP header name is correct per RFC7230, which is already
     * enforced by Salesforce when adding a header to an `HttpRequest`. A valid header name
     * consists of one or more US-ASCII visual character *except* delimiters.
     * Delimiters are any character between these single quotes '()",/:;<=>?@[\]{}'
     *
     * @param name `String` name of the http header field-name
     * @exception throws `InvalidHeaderNameException` when a `CalloutException` or `NullPointerException` is thrown from `HttpRequest.setHeader()`
     */
    private static void validateHeaderName(String name) {
        try {
            (new HttpRequest()).setHeader(name, '');
        } catch (CalloutException thrownCalloutException) {
            raiseInvalidHttpHeaderNameException(name);
        } catch (NullPointerException thownNullPointerException) {
            raiseInvalidHttpHeaderNameException('null');
        }
    }

    /**
     * @description Adds this header to the given HttpRequest
     * @param httpRequest `HttpRequest` to add this header to
     */
    public void addTo(HttpRequest httpRequest) {
        httpRequest.setHeader(this.name, this.value);
    }

    @TestVisible
    /**
     * @description formats and throws `InvalidHeaderNameException`
     * @param name `String` name of http header field-name to place into the exception message
     * @exception throws `InvalidHeaderNameException`
     */
    private static void raiseInvalidHttpHeaderNameException(String name) {
        throw new InvalidHeaderNameException(
            String.format(INVALID_HEADER_NAME_EXCEPTION_MESSAGE, new List<String>{ name })
        );
    }

    /**
     * @description Exception thrown in raiseInvalidHttpHeaderNameException
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class InvalidHeaderNameException extends Exception {
    }

    /**
     * @description Exception thrown when null is provided as a header field-value
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    public class NullHeaderValueException extends Exception {
    }

    /**
     * @description Returns a string representation of the HTTP header field in the format specified by RFC9112.
     * The format is: field-name ":" OWS field-value OWS.
     * OWS stands for Optional White Space, which can be zero or more spaces or horizontal tabs.
     *
     * @return A string in the format "field-name: field-value", where "field-name" is the name of the HTTP header
     * field and "field-value" is the value of the HTTP header field.
     *
     * @example
     * Assuming an extending class sets the name to "X-Custom-Header" and value to "HeaderValue"
     *
     * VCC_HttpHeaderField header = new CustomHeaderField("HeaderValue");
     * String headerString = header.toString();
     * System.assertEquals("X-Custom-Header: HeaderValue", headerString);
     */
    public override String toString() {
        return this.name + ': ' + this.value;
    }
}
