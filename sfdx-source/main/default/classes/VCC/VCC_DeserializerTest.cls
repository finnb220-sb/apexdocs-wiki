@isTest
public with sharing class VCC_DeserializerTest {
    private class DeserializerTestInnerClass implements VCC_DeserializationTarget {
        public String esigResults;

        public void completeDeserialization(VCC_DeserializationOutcome outcome) {
            System.debug(outcome);
            Object deserializedObject = outcome?.deserializedObject;
            if (deserializedObject != null) {
                if (deserializedObject instanceof VCC_VdifIsValidEsigRS) {
                    this.esigResults = ((VCC_VdifIsValidEsigRS) deserializedObject).isValidEsigTextTO.text;
                }
            }
        }
    }

    private class DeserializerTestInnerClassTwo {
        public String test;
    }

    @isTest
    public static void missingInterfaceTest() {
        DeserializerTestInnerClassTwo dstict = new DeserializerTestInnerClassTwo();
        String jsonString = '';
        System.Type type = DeserializerTestInnerClassTwo.class;
        VCC_Deserializer ds = new VCC_Deserializer(jsonString, type);

        VCC_Deserializer.MissingInterfaceException mie;

        try {
            ds.deserializeInto(dstict);
        } catch (VCC_Deserializer.MissingInterfaceException e) {
            mie = e;
        }

        System.assert(mie != null, 'Expected exception was not caught.');
    }

    @isTest
    public static void missingParameterTest() {
        VCC_Deserializer ds = new VCC_Deserializer(null, null);

        VCC_Deserializer.MissingParameterException mpe;

        try {
            Object someObject = ds.deserialize(true);
        } catch (VCC_Deserializer.MissingParameterException e) {
            mpe = e;
        }

        System.assert(mpe != null, 'Expected exception was not caught.');
    }

    @isTest
    public static void deserializeIntoTest() {
        DeserializerTestInnerClass dstic = new DeserializerTestInnerClass();
        String jsonResponse = ([SELECT Body FROM StaticResource WHERE Name = 'VCC_vdifIsValidEsigMockResponse' LIMIT 1].Body).toString();
        jsonResponse = jsonResponse.replace('"textTO"', '"isValidEsigTextTO"');
        System.assert(dstic.esigResults == null);

        VCC_Deserializer ds = new VCC_Deserializer(jsonResponse, VCC_VdifIsValidEsigRS.class);

        VCC_DeserializationOutcome outcome = ds.deserializeInto(dstic);
        System.assert(dstic.esigResults == 'True', 'JSON deserialized incorrectly.');
        System.assert(outcome.result == VCC_DeserializationResult.UNSTRICT, 'Expected "UNSTRICT".');
        System.assert(ds.deserializeStrictInto(dstic).result == VCC_DeserializationResult.STRICT, 'Expected "STRICT".');

        jsonResponse = ([SELECT Body FROM StaticResource WHERE Name = 'VCC_badResponse' LIMIT 1].Body).toString();
        ds = new VCC_Deserializer(jsonResponse, VCC_VdifIsValidEsigRS.class);

        System.assert(ds.deserializeInto(dstic).result == VCC_DeserializationResult.ERROR, 'Expected "ERROR".');
    }

    @isTest
    public static void deserializeStrictIntoTest() {
        DeserializerTestInnerClass dstic = new DeserializerTestInnerClass();
        String jsonResponse = ([SELECT Body FROM StaticResource WHERE Name = 'VCC_vdifIsValidEsigMockResponse' LIMIT 1].Body).toString();
        jsonResponse = jsonResponse.replace('"textTO"', '"isValidEsigTextTO"');
        System.assert(dstic.esigResults == null);

        VCC_Deserializer ds = new VCC_Deserializer(jsonResponse, VCC_VdifIsValidEsigRS.class);

        VCC_DeserializationOutcome outcome = ds.deserializeStrictInto(dstic);
        System.assert(dstic.esigResults == 'True', 'JSON deserialized incorrectly.');
        System.assert(outcome.result == VCC_DeserializationResult.STRICT, 'Expected "STRICT".');

        jsonResponse = ([SELECT Body FROM StaticResource WHERE Name = 'VCC_badResponse' LIMIT 1].Body).toString();
        ds = new VCC_Deserializer(jsonResponse, VCC_VdifIsValidEsigRS.class);

        System.assert(ds.deserializeStrictInto(dstic).result == VCC_DeserializationResult.ERROR, 'Expected "ERROR".');
    }
}
