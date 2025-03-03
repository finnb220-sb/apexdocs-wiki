/**
 * @description Tests for VCC_HttpHeaderCallingAppName
 *              Verifies header name and value handling, including validation.
 * @author Booz Allen
 * @since 10 May 2024
 */
@IsTest
private class VCC_HttpHeaderCallingAppNameTest {
    @IsTest
    static void unitTestHeaderWithValidAppNamePositive() {
        // Arrange
        Test.startTest();
        String appName = 'ValidAppName';
        String expectedHeaderValue = 'ValidAppName';

        // Act
        VCC_HttpHeaderCallingAppName header = new VCC_HttpHeaderCallingAppName(appName);

        // Assert
        Test.stopTest();
        Assert.areEqual(expectedHeaderValue, header.value, 'Header value should be set to the app name.');
        Assert.areEqual(
            System.label.VCC_HttpHeaderName_CallingAppName,
            header.name,
            'Header name should match the system label.'
        );
    }

    @IsTest
    static void unitTestHeaderWithBlankAppNameNegative() {
        // Arrange
        String blankAppName = '';

        // Assert
        Test.startTest();
        Boolean didThrow = false;
        try {
            VCC_HttpHeaderCallingAppName header = new VCC_HttpHeaderCallingAppName(blankAppName);
            Assert.fail('Header should not be instantiated' + header);
        } catch (IllegalArgumentException e) {
            didThrow = true;
        }
        Assert.areEqual(didThrow, true, 'Expected IllegalArgumentException to be thrown for blank app name.');
        Test.stopTest();
    }

    @IsTest
    static void unitTestHeaderAddedToHttpRequestPositive() {
        // Arrange
        HttpRequest mockRequest = new HttpRequest();
        String appName = 'ValidAppName';
        String expectedHeaderValue = 'ValidAppName';
        VCC_HttpHeaderCallingAppName header = new VCC_HttpHeaderCallingAppName(appName);

        // Act
        header.addTo(mockRequest);

        // Assert
        Assert.areEqual(
            expectedHeaderValue,
            mockRequest.getHeader(System.label.VCC_HttpHeaderName_CallingAppName),
            'The header value should be added to the HttpRequest.'
        );
    }
}
