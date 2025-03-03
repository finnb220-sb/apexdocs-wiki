@IsTest
private with sharing class VCC_HexadecimalTest {
    @IsTest
    /**
     * @description Sanity checking my understanding before diving into writing VCC_Hexadecimal
     */
    static void unitBitwiseSanityCheckPositive() {
        Test.startTest();

        // 15 in binary is 0000...1111
        Assert.isTrue((15 & 15) == 15, 'Expected bitwise AND of 1111 and 1111 to equal 1111');

        // -15 in binary is 1111...0001 by taking two's complement of 0000...1111 (15)
        Assert.isTrue((-15 & 15) == 1, 'Expected bitwise AND of 0001 and 1111 to equal 0001');

        // '>>' respects sign
        Assert.isTrue((-8 >> 1) == -4, 'Expected -8 signed bitshift right to equal -4');

        // '>>>' does not respect sign (is unsigned)
        // 8 in binary is 0000...1000, two's complement of that (-8) is 1111...1000, then shifted right one is 0111...1100 (2147483644)
        Assert.isTrue((-8 >>> 1) == 2147483644, 'Expected -8 unsigned bitshift right to equal 2147483644');

        Test.stopTest();
    }

    @IsTest
    static void unitConstructorListOfLongNegative() {
        Test.startTest();
        try {
            List<Long> longListConstructorInput;
            new VCC_Hexadecimal(longListConstructorInput);
            Assert.fail('Expected a VCC_Hexadecimal.NullInputException');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_Hexadecimal.NullInputException.class,
                'Expected VCC_Hexadecimal.NullInputException but received: ' + thrownException.getTypeName()
            );
            Assert.areEqual(
                VCC_Hexadecimal.NULL_INPUT_EXCEPTION_MESSAGE,
                thrownException.getMessage(),
                'Expected exception message to match the string defined in VCC_Hexadecimal.NULL_INPUT_EXCEPTION_MESSAGE'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitConstructorLongNegative() {
        Test.startTest();
        try {
            Long longConstructorInput;
            new VCC_Hexadecimal(longConstructorInput);
            Assert.fail('Expected a VCC_Hexadecimal.NullInputException');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_Hexadecimal.NullInputException.class,
                'Expected VCC_Hexadecimal.NullInputException but received: ' + thrownException.getTypeName()
            );
            Assert.areEqual(
                VCC_Hexadecimal.NULL_INPUT_EXCEPTION_MESSAGE,
                thrownException.getMessage(),
                'Expected exception message to match the string defined in VCC_Hexadecimal.NULL_INPUT_EXCEPTION_MESSAGE'
            );
        }
        Test.stopTest();
    }

    @IsTest
    static void unitStringConstructorNegative() {
        Test.startTest();
        try {
            String stringConstructorInput;
            new VCC_Hexadecimal(stringConstructorInput);
            Assert.fail('Expected a VCC_Hexadecimal.NullInputException');
        } catch (Exception thrownException) {
            Assert.isInstanceOfType(
                thrownException,
                VCC_Hexadecimal.NullInputException.class,
                'Expected VCC_Hexadecimal.NullInputException but received: ' + thrownException.getTypeName()
            );
            Assert.areEqual(
                VCC_Hexadecimal.NULL_INPUT_EXCEPTION_MESSAGE,
                thrownException.getMessage(),
                'Expected exception message to match the string defined in VCC_Hexadecimal.NULL_INPUT_EXCEPTION_MESSAGE'
            );
        }
        Test.stopTest();
    }

    @IsTest
    /**
     * @description testing each of the 16 hexadecimal digits
     */
    static void unitLongToHexSingleDigitPositive() {
        Test.startTest();
        VCC_Hexadecimal hex = new VCC_Hexadecimal();
        Assert.areEqual('f'.leftPad(16, '0'), hex.toHex(15L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('e'.leftPad(16, '0'), hex.toHex(14L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('d'.leftPad(16, '0'), hex.toHex(13L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('c'.leftPad(16, '0'), hex.toHex(12L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('b'.leftPad(16, '0'), hex.toHex(11L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('a'.leftPad(16, '0'), hex.toHex(10L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('9'.leftPad(16, '0'), hex.toHex(9L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('8'.leftPad(16, '0'), hex.toHex(8L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('7'.leftPad(16, '0'), hex.toHex(7L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('6'.leftPad(16, '0'), hex.toHex(6L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('5'.leftPad(16, '0'), hex.toHex(5L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('4'.leftPad(16, '0'), hex.toHex(4L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('3'.leftPad(16, '0'), hex.toHex(3L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('2'.leftPad(16, '0'), hex.toHex(2L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('1'.leftPad(16, '0'), hex.toHex(1L), 'Expected correct hexadecimal string for the given Long');
        Assert.areEqual('0'.leftPad(16, '0'), hex.toHex(0L), 'Expected correct hexadecimal string for the given Long');
        Test.stopTest();
    }

    @IsTest
    /**
     * @description Testing a two-digit hexadecimal number to ensure least/most significant digits are preserved
     */
    static void unitLongToHexTwoDigitPositive() {
        Test.startTest();
        VCC_Hexadecimal hex = new VCC_Hexadecimal();
        Long longToConvert = 175; // 175 == 1010_1111 == 'af'
        Assert.areEqual('af'.leftPad(16, '0'), hex.toHex(longToConvert), 'Expected 0\'s followed by \'af\' not \'fa\' or anything else.');
        Test.stopTest();
    }

    @IsTest
    static void unitListOfLongToHexPositive() {
        Test.startTest();
        List<Long> longsToConvert = new List<Long>{
            -2401053088876216593L, // deadbeefdeadbeef
            1311768468603649775L // 1234678deadbeef
        };
        VCC_Hexadecimal hex = new VCC_Hexadecimal();
        Assert.areEqual(
            'deadbeefdeadbeef12345678deadbeef',
            hex.toHex(longsToConvert),
            'Expected hex string to be first the converted long at index 0, followed by the long at index  1'
        );
        Test.stopTest();
    }

    @IsTest
    static void funcStringToHexStringPositive() {
        Test.startTest();
        try {
            VCC_Hexadecimal hex = new VCC_Hexadecimal('hi');
            Assert.areEqual('6869', hex.toString(), 'Expected string to be correctly converted to hexadecimal.');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception was thrown: ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void funcLongToHexStringPositive() {
        Test.startTest();
        try {
            VCC_Hexadecimal hex = new VCC_Hexadecimal(
                2012812985352580852L // 1beef2beef3beef4
            );
            Assert.areEqual('1beef2beef3beef4', hex.toString(), 'Expected string to be correctly converted to hexadecimal.');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception was thrown: ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }

    @IsTest
    static void funcListOfLongsToHexStringPositive() {
        Test.startTest();
        try {
            VCC_Hexadecimal hex = new VCC_Hexadecimal(
                new List<Long>{
                    2012812985352580852L, // 1beef2beef3beef4
                    -85358455477633299L // fed0beefdeadfeed
                }
            );
            Assert.areEqual('1beef2beef3beef4fed0beefdeadfeed', hex.toString(), 'Expected string to be correctly converted to hexadecimal.');
        } catch (Exception thrownException) {
            Assert.fail('Unexpected exception was thrown: ' + thrownException.getTypeName());
        }
        Test.stopTest();
    }
}
