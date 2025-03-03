@isTest
public with sharing class VCC_DASRSCommonTest {
    @isTest
    public static void instantiationTest() {
        System.assert(new VCC_DASRSCommon() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_DASRSCommon.TextTO() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_DASRSCommon.TaggedText() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_DASRSCommon.TaggedTextArray() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_DASRSCommon.ArrayOfTaggedText() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_DASRSCommon.FaultTO() != null, 'Did not instantiate as expected.');
    }
}
