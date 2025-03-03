@isTest
/**
 * @description
 * @author
 * @since
 * @group Test Classes
 * @see VCC_PACTSerializeRequestToJSON
 */
public class VCC_PACTSerializeRequestToJSONTest {
    @testSetup
    static void makeData() {
        VCC_TestDataFactory.insertUser('System Administrator');
    }
    /**
     * @description create a test user for running tests
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    @isTest
    public static void serializeSObjectToJSON() {
        // set up variables for Serialization
        new VCC_PACTSerializeRequestToJSON();
        VCC_PACTSerializeRequestToJSON.Requests req = new VCC_PACTSerializeRequestToJSON.Requests();

        // create some data
        Account testPersonAccount = new Account(
            RecordTypeID = [
                SELECT Id
                FROM RecordType
                WHERE Name = 'Person Account' AND SobjectType = 'Account'
            ]
            .Id,
            FirstName = 'Test FName',
            LastName = 'Test LName',
            PersonMailingStreet = 'test@yahoo.com',
            PersonMailingPostalCode = '12345',
            PersonMailingCity = 'SFC',
            PersonEmail = 'test@yahoo.com',
            PersonHomePhone = '1234567',
            PersonMobilePhone = '12345678',
            VCC_MVI_External_Id__pc = '1013060957V646684'
        );
        insert testPersonAccount;

        req.inputSObject = testPersonAccount;

        // run some tests
        System.runAs(getTestUser()) {
            Test.startTest();
            List<VCC_PACTSerializeRequestToJSON.Results> resultsJSON = VCC_PACTSerializeRequestToJSON.serialize(new List<VCC_PACTSerializeRequestToJSON.Requests>{ req });
            Test.stopTest();
            System.assert(resultsJSON != null, 'Expected a JSON value');
        }
    }
}
