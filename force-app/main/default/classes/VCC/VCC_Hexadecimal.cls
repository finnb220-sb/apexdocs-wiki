/**
 * @description Convert a value to hexadecimal string. Only `String`, `Long`, `List<Long>` (`Integer`, and `List<Integer>` by casting) are supported.
 * Originally this class was created for CCCM-29080 which called for generating a unique 128-bit hexadecimal string. Two
 * Long's (64-bit numbers) made the most sense when generated via Crypto.getRandomLong() - That's why there are two constructors
 * for `Long`'s. Added the String constructor because it was low hanging fruit.
 *
 * @author Patrick Skamarak
 * @since 02/20/2024
 */
public with sharing class VCC_Hexadecimal {
    @TestVisible
    private static final String NULL_INPUT_EXCEPTION_MESSAGE = 'A null input was provided for VCC_Hexadecimal';

    @TestVisible
    private static final List<String> HEX_CHARS = new List<String>{ '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', 'a', 'b', 'c', 'd', 'e', 'f' };

    @TestVisible
    private string hexString;

    @TestVisible
    /**
     * @description Empty constructor for testing
     */
    private VCC_Hexadecimal() {
        return;
    }

    /**
     * @description Construct a VCC_Hexadecimal for a String
     * @param stringForHexConversion
     */
    public VCC_Hexadecimal(String stringForHexConversion) {
        if (stringForHexConversion == null) {
            this.raiseNullInputException();
        }
        this.hexString = EncodingUtil.convertToHex(Blob.valueOf(stringForHexConversion));
    }

    /**
     * @description Construct a VCC_Hexadecimal for a Long
     * @param longForHexConversion
     */
    public VCC_Hexadecimal(Long longForHexConversion) {
        if (longForHexConversion == null) {
            this.raiseNullInputException();
        }
        this.hexString = this.toHex(longForHexConversion);
    }

    /**
     * @description Construct a VCC_Hexadecimal for a List<Long>
     * @param longsForHexConversion
     */
    public VCC_Hexadecimal(List<Long> longsForHexConversion) {
        if (longsForHexConversion == null) {
            this.raiseNullInputException();
        }
        this.hexString = this.toHex(longsForHexConversion);
    }

    @TestVisible
    /**
     * @description Converts a List<Long> to a hexadecimal string
     * @param longsForHexConversion
     * @return `String` hexadecimal value for given List<Long>
     */
    private String toHex(List<Long> longsForHexConversion) {
        List<String> hexStrings = new List<String>();
        for (Long longForHexConversion : longsForHexConversion) {
            hexStrings.add(this.toHex(longForHexConversion));
        }
        return String.join(hexStrings, '');
    }

    @TestVisible
    /**
     * @description Converts a Long to a hexadecimal string
     * @param longForHexConversion
     * @return `String` hexadecimal value for given Long
     */
    private String toHex(Long longForHexConversion) {
        List<String> convertedHexChars = new List<String>();
        for (Integer nibbles = 0; nibbles < 16; nibbles++) {
            convertedHexChars.add(HEX_CHARS[(Integer) longForHexConversion & 15]);
            longForHexConversion = longForHexConversion >>> 4;
        }
        return String.join(convertedHexChars, '').reverse();
    }

    /**
     * @description overridden toString
     * @return Returns the hex-converted value
     */
    public override String toString() {
        return (this.hexString == null) ? '' : this.hexString;
    }

    /**
     * @description throws `NullInputException`
     */
    private void raiseNullInputException() {
        throw new NullInputException(NULL_INPUT_EXCEPTION_MESSAGE);
    }

    /**
     * @description Exception thrown when a null is provided to this classes constructors
     */
    @SuppressWarnings('PMD')
    public class NullInputException extends Exception {
    }
}
