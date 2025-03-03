@IsTest
private with sharing class VCC_HttpHeaderFieldTest {
    // Delimiters - a subset of VCHARS (defined in rfc5234) which are *not* permitted in http header field name
    private static final Set<String> HTTP_DELIMITER_CHARS = new Set<String>{
        '(',
        ')',
        '"',
        ',',
        '/',
        ':',
        ';',
        '<',
        '=',
        '>',
        '?',
        '@',
        '[',
        ']',
        '\\',
        '{',
        '}'
    };

    // all VCHAR's (defined in rfc5234 as %x21-7E)
    private static final Set<String> allVChar {
        get {
            Set<String> setForReturn = new Set<String>();
            for (Integer charCode = 33; /** 33 is x21 in hex */ charCode < 126; /** 126 is x7E in hex */ charCode++) {
                setForReturn.add(String.fromCharArray(new List<Integer>{ charCode }));
            }
            return setForReturn;
        }
    }

    /**
     * @description test header for testing
     */
    @SuppressWarnings('PMD.ClassNamingConventions')
    private class TestHeader extends VCC_HttpHeaderField {
        @TestVisible
        /**
         * @description two-arg constructor for testing
         * @param name
         * @param value
         */
        private TestHeader(String name, String value) {
            super(name, value);
        }
    }

    @IsTest
    static void unitTwoArgConstructorPositive() {
        Test.startTest();
        String headerName = 'test';
        String headerValue = 'test';
        TestHeader testHeader = new TestHeader(headerName, headerValue);
        Assert.areEqual(
            headerName,
            testHeader.name,
            'Expected two-arg constructor to set the \'name\' property with string in \'headerName\' variable'
        );
        Assert.areEqual(
            headerValue,
            testHeader.value,
            'Expected two-arg constructor to set the \'value\' property with string in \'headerValue\' variable'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitTwoArgConstructorBadNameNegative() {
        Test.startTest();
        try {
            String badHeaderNameChar = (new List<String>(HTTP_DELIMITER_CHARS))[0];
            new TestHeader(badHeaderNameChar, '');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_HttpHeaderField.InvalidHeaderNameException.class,
                'Expected InvalidHeaderNameException, instead got: ' + thrownException.getTypeName()
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitTwoArgConstructorNullValueNegative() {
        Test.startTest();
        try {
            new TestHeader('test', null);
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_HttpHeaderField.NullHeaderValueException.class,
                'Expected NullHeaderValueException instead got: ' + thrownException.getTypeName()
            );
            Assert.areEqual(
                VCC_HttpHeaderField.NULL_HEADER_VALUE_EXCEPTION_MESSAGE,
                thrownException.getMessage(),
                'Expected exception message defined in VCC_HttpHeaderField.NULL_HEADER_VALUE_EXCEPTION_MESSAGE'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateHeaderNamePositive() {
        Test.startTest();
        Set<String> permissibleCharacters = allVChar;
        permissibleCharacters.removeAll(HTTP_DELIMITER_CHARS);
        for (String permissibleCharacter : new List<String>(permissibleCharacters)) {
            VCC_HttpHeaderField.validateHeaderName(permissibleCharacter);
            Assert.isTrue(true, 'Expected no exception for permissible character: ' + permissibleCharacter);
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateHeaderNameDelimitersNegative() {
        Test.startTest();
        for (String impermissibleCharacter : new List<String>(HTTP_DELIMITER_CHARS)) {
            try {
                VCC_HttpHeaderField.validateHeaderName(impermissibleCharacter);
                Assert.fail('Anticipated impermissible character to produce an exception but didn\'t get one');
            } catch (Exception thrownException) {
                Assert.isInstanceOfType(
                    thrownException,
                    VCC_HttpHeaderField.InvalidHeaderNameException.class,
                    'Expected InvalidHeaderNameException, instead got: ' + thrownException.getTypeName()
                );
                Assert.areEqual(
                    String.format(
                        VCC_HttpHeaderField.INVALID_HEADER_NAME_EXCEPTION_MESSAGE,
                        new List<String>{ impermissibleCharacter }
                    ),
                    thrownException.getMessage(),
                    'Expected exception message to be formatted with the name of the bad header name'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void unitValidateHeaderNameNullNegative() {
        Test.startTest();
        try {
            VCC_HttpHeaderField.validateHeaderName(null);
            Assert.fail('Anticipated impermissible character to produce an exception but didn\'t get one');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_HttpHeaderField.InvalidHeaderNameException.class,
                'Expected InvalidHeaderNameException, instead got: ' + thrownException.getTypeName()
            );
            Assert.areEqual(
                String.format(VCC_HttpHeaderField.INVALID_HEADER_NAME_EXCEPTION_MESSAGE, new List<String>{ 'null' }),
                thrownException.getMessage(),
                'Expected exception message to be formatted with the name of the bad header name'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitRaiseInvalidHeaderNameExceptionPositive() {
        // or is this negative since an exception is thrown? dunno

        Test.startTest();
        String headerName = 'test';
        try {
            VCC_HttpHeaderField.raiseInvalidHttpHeaderNameException(headerName);
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_HttpHeaderField.InvalidHeaderNameException.class,
                'Expected InvalidHeaderNameException, instead got: ' + thrownException.getTypeName()
            );
            Assert.areEqual(
                String.format(
                    VCC_HttpHeaderField.INVALID_HEADER_NAME_EXCEPTION_MESSAGE,
                    new List<String>{ headerName }
                ),
                thrownException.getMessage(),
                'Expected exception message to be formatted with the name of the bad header name'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitAddToPositive() {
        Test.startTest();
        String headerName = 'test';
        String headerValue = 'test';
        TestHeader testHeader = new TestHeader(headerName, headerValue);
        HttpRequest testRequest = new HttpRequest();
        Assert.isNull(testRequest.getHeader(headerName), 'Expected no test header to be present.');
        testHeader.addTo(testRequest);
        Assert.areEqual(
            headerValue,
            testRequest.getHeader(headerName),
            'Expected test header to be present after calling "addTo".'
        );
        Test.stopTest();
    }

    /**
     * @description Pretty sure any valid Apex String is permissible as a header value...
     * The only thing Salesforce docs say is "Limit 100 KB" but that doesn't seem to be enforced
     * https://developer.salesforce.com/docs/atlas.en-us.apexref.meta/apexref/apex_classes_restful_http_httprequest.htm#apex_System_HttpRequest_setHeader
     */
    @IsTest
    static void unitHeaderValuePermissibleTestPositive() {
        Test.startTest();
        List<Integer> charArray = new List<Integer>();
        for (Integer charCode; charCode < 200000; charCode++) {
            charArray.add(charCode);
        }
        HttpRequest testRequest = new HttpRequest();
        TestHeader testHeader = new TestHeader('test', String.fromCharArray(charArray));
        testHeader.addTo(testRequest);
        Assert.areEqual(
            String.fromCharArray(charArray),
            testRequest.getHeader('test'),
            'Expected the header value to be set correctly'
        );
        Test.stopTest();
    }
    /**
     * @description Test to validate the toString method of the VCC_HttpHeaderField class.
     * This test checks if the toString method returns the correct string format
     * combining the header name and value separated by a colon and a space.
     *
     * @testmethod
     * @see VCC_HttpHeaderField#toString()
     */
    @IsTest
    static void unitToStringPositive() {
        Test.startTest();
        String headerName = 'testName';
        String headerValue = 'testValue';
        TestHeader testHeader = new TestHeader(headerName, headerValue);
        String expectedString = headerName + ': ' + headerValue;
        Assert.areEqual(expectedString, testHeader.toString(), 'Expected toString method to return the correct format');
        Test.stopTest();
    }

    /**
     * @description Test to validate the toString method with invalid characters in the header name.
     * This test checks if the toString method handles unexpected or invalid characters correctly.
     *
     * @testmethod
     * @see VCC_HttpHeaderField#toString()
     */
    @IsTest
    static void unitToStringNegative() {
        Test.startTest();
        String invalidHeaderName = '(invalid)';
        String headerValue = 'testValue';
        try {
            new TestHeader(invalidHeaderName, headerValue);
            Assert.fail('Expected an InvalidHeaderNameException to be thrown');
        } catch (VCC_HttpHeaderField.InvalidHeaderNameException e) {
            Assert.areNotEqual(e, null, 'Expected exception was thrown, so the test passes');
        }
        Test.stopTest();
    }

    /**
     * @description Test to validate the toString method with an empty header name.
     * This test checks if the toString method handles empty string correctly.
     *
     * @testmethod
     * @see VCC_HttpHeaderField#toString()
     */
    @IsTest
    static void unitToStringHeaderNameEmpty() {
        Test.startTest();
        try {
            String emptyHeaderName = '';
            String emptyHeaderValue = 'testValue';
            new TestHeader(emptyHeaderName, emptyHeaderValue);
            Assert.fail('Expected an InvalidHeaderNameException to be thrown');
        } catch (VCC_HttpHeaderField.InvalidHeaderNameException e) {
            Assert.areNotEqual(e, null, 'Expected exception was thrown, so the test passes');
            Test.stopTest();
        }
    }

    /**
     * @description Test to validate the toString method with an empty header value.
     * This test checks if the toString method handles empty string correctly.
     *
     * @testmethod
     * @see VCC_HttpHeaderField#toString()
     */
    @IsTest
    static void unitToStringHeaderValueEmpty() {
        Test.startTest();
        String headerName = 'testName';
        String emptyHeaderValue = '';
        TestHeader testHeader = new TestHeader(headerName, emptyHeaderValue);
        String expectedString = headerName + ': ' + emptyHeaderValue;
        Assert.areEqual(expectedString, testHeader.toString(), 'Expected toString method to return the correct format');
        Test.stopTest();
    }

    /**
     * @description Test to validate the toString method with a null header name.
     * This test checks if the toString method handles null values correctly.
     *
     * @testmethod
     * @see VCC_HttpHeaderField#toString()
     */
    @IsTest
    static void unitToStringNameNull() {
        Test.startTest();
        try {
            String headerName = null;
            String headerValue = 'testValue';
            new TestHeader(headerName, headerValue);
            Assert.fail('Expected a InvalidHeaderNameException to be thrown');
        } catch (VCC_HttpHeaderField.InvalidHeaderNameException e) {
            Assert.areNotEqual(e, null, 'Expected exception was thrown, so the test passes');
        }
        Test.stopTest();
    }
    /**
     * @description Test to validate the toString method with a null header name.
     * This test checks if the toString method handles null values correctly.
     *
     * @testmethod
     * @see VCC_HttpHeaderField#toString()
     */
    @IsTest
    static void unitToStringValueNull() {
        Test.startTest();
        try {
            String headerName = 'testName';
            String headerValue = null;
            new TestHeader(headerName, headerValue);
            Assert.fail('Expected a NullHeaderValueException to be thrown');
        } catch (VCC_HttpHeaderField.NullHeaderValueException e) {
            Assert.areNotEqual(e, null, 'Expected exception was thrown, so the test passes');
        }
        Test.stopTest();
    }
}
