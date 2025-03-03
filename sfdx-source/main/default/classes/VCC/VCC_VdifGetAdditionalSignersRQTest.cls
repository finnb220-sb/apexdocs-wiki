@isTest
public with sharing class VCC_VdifGetAdditionalSignersRQTest {
    @isTest
    public static void instantiationTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            VCC_VdifGetAdditionalSignersRQ additionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ();
            VCC_VdifParameters vdifParameters = new VCC_VdifParameters();
            (new VCC_VdifParametersDomain()).fillParametersWithDummyData(vdifParameters);
            VCC_VdifGetAdditionalSignersRQ additionalSignersRQ2 = new VCC_VdifGetAdditionalSignersRQ(vdifParameters);

            System.assert(additionalSignersRQ.supplementalParameters != null, 'Request not constructed properly.');
            System.assert(additionalSignersRQ2.supplementalParameters != null, 'Request not constructed properly.');
        }
    }

    @isTest
    public static void isValidTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            VCC_VdifGetAdditionalSignersRQ additionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ('test', 'test', 'test', 'test', new List<String>());

            System.assert(additionalSignersRQ.isValid() == false, 'Request is unexpectedly valid.');

            additionalSignersRQ = new VCC_VdifGetAdditionalSignersRQ('test', 'test', 'test', 'test', new List<String>{ 'someString' });

            System.assert(additionalSignersRQ.isValid() == true, 'Request is unexpectedly invalid.');
        }
    }
}
