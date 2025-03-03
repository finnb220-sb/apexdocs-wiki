@IsTest
/**
 * @description
 * @author
 * @since
 * @group Test Classes
 * @see VCC_HttpRequestAction
 */
public class VCC_HttpRequestActionTest {
    static String recordId;

    @TestSetup
    static void initData() {
        String RecTypeId = [SELECT Id FROM RecordType WHERE Name = 'Person Account' AND SobjectType = 'Account'].Id;

        Account testPersonAccount = new Account(
            RecordTypeID = RecTypeId,
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
    }

    @IsTest
    public static void testProcessRequest() {
        Test.startTest();

        VCC_HttpRequestAction.ActionRequest request = new VCC_HttpRequestAction.ActionRequest();
        List<VCC_HttpRequestAction.ActionRequest> requests = new List<VCC_HttpRequestAction.ActionRequest>();

        request.path = 'test';
        request.requestJSON = 'test';
        request.endpoint = 'test';

        requests.add(request);

        Test.setMock(HttpCalloutMock.class, new VCC_MockHttpRequest());

        Assert.isNotNull(VCC_HttpRequestAction.processRequest(request), 'Expected value to not equal null');
        //System.assertEquals('success', resp);
        Test.stopTest();
    }

    @IsTest
    public static void testProcessRequests() {
        Test.startTest();

        VCC_HttpRequestAction.ActionRequest request = new VCC_HttpRequestAction.ActionRequest();
        request.origin = 'mock';
        List<VCC_HttpRequestAction.ActionRequest> requests = new List<VCC_HttpRequestAction.ActionRequest>();

        request.path = 'test';
        request.requestJSON = 'test';
        request.endpoint = 'test';

        requests.add(request);

        Test.setMock(HttpCalloutMock.class, new VCC_MockHttpRequest());

        Assert.isNotNull(VCC_HttpRequestAction.processRequests(requests), 'Expected value to not equal null');
        Test.stopTest();
    }
}
