@isTest
public with sharing class VCC_VdifRSCommonTest {
    @isTest
    public static void instantiationTest() {
        System.assert(new VCC_VdifRSCommon() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_VdifRSCommon.TextTO() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_VdifRSCommon.TaggedText() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_VdifRSCommon.TaggedTextArray() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_VdifRSCommon.ArrayOfTaggedText() != null, 'Did not instantiate as expected.');
        System.assert(new VCC_VdifRSCommon.FaultTO() != null, 'Did not instantiate as expected.');
    }
}
