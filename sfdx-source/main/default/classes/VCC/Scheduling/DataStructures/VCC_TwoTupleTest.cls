/**
 * @description Test class for VCC_TwoTuple class.
 * @see VCC_TwoTuple
 */
@IsTest
private class VCC_TwoTupleTest {
    @IsTest
    static void unitConstructorSetsInternalPropertiesPositive() {
        String key = 'key';
        String value = 'value';
        VCC_TwoTuple systemUnderTest = new VCC_TwoTuple(key, value);
        Assert.areEqual(
            key,
            String.valueOf(systemUnderTest.valueOne),
            'Expected constructor to set the internal key property with the argument passed into its constructor.'
        );
        Assert.areEqual(
            value,
            String.valueOf(systemUnderTest.valueTwo),
            'Expected constructor to set the internal value property with the argument passed into its constructor.'
        );
    }
}
