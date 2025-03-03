/**
 * @description Test class for VCC_DASFlowSignNoteTest
 * @author Booz Allen Hamilton
 * @see `VCC_DASFlowSignNote`
 */
@isTest
private class VCC_DASFlowSignNoteTest {
    @IsTest
    static void unitResultConstructorPositive() {
        Test.startTest();
        VCC_DASSignNoteRS signNoteRs = new VCC_DASSignNoteRS();
        Assert.isInstanceOfType(
            new VCC_DASFlowSignNote.Result(signNoteRs),
            VCC_DASFlowSignNote.Result.class,
            'Expected VCC_DASFlowSignNote.Result constructor to instantiate itself'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitRequestConstructorPositive() {
        Test.startTest();
        Assert.isInstanceOfType(
            new VCC_DASFlowSignNote.Request(),
            VCC_DASFlowSignNote.Request.class,
            'Expected VCC_DASFlowSignNote.Request constructor to instantiate itself'
        );
        Test.stopTest();
    }

    @IsTest
    static void unitSignNotePositive() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setReturnValue('signNote', new VCC_DASSignNoteRS());

        Test.startTest();
        VCC_DASFlowSignNote.Request flowSignNoteRequest = new VCC_DASFlowSignNote.Request();
        flowSignNoteRequest.providerLoginSiteCode = '123';
        VCC_DASFlowSignNote.Result flowSignNoteResult = VCC_DASFlowSignNote.signNote(
            new List<VCC_DASFlowSignNote.Request>{ flowSignNoteRequest }
        )[0];
        Assert.isNotNull(flowSignNoteResult, 'Expected non-null value.');
        Test.stopTest();

        apiStub.assertInvoked('signNote');
    }

    @IsTest
    static void unitSignNoteDasExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('signNote', new VCC_DASServiceApi.ApiServiceException('test'));

        Test.startTest();
        try {
            VCC_DASFlowSignNote.Request flowSignNoteRequest = new VCC_DASFlowSignNote.Request();
            flowSignNoteRequest.providerLoginSiteCode = '123';
            VCC_DASFlowSignNote.signNote(new List<VCC_DASFlowSignNote.Request>{ flowSignNoteRequest });
            Assert.fail('Test failed. Did not throw an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Expected exception thrown. Test passes.');
        }
        Test.stopTest();
    }

    @IsTest
    static void unitSignNoteOtherExceptionNegative() {
        VCC_DASStub apiStub = new VCC_DASStub(VCC_DASServiceApi.class);
        VCC_DAS.SERVICES.apiService = (VCC_DASServiceApi) apiStub.instance;

        apiStub.setException('signNote', new NullPointerException());

        Test.startTest();
        try {
            VCC_DASFlowSignNote.Request flowSignNoteRequest = new VCC_DASFlowSignNote.Request();
            flowSignNoteRequest.providerLoginSiteCode = '123';
            VCC_DASFlowSignNote.signNote(new List<VCC_DASFlowSignNote.Request>{ flowSignNoteRequest });
            Assert.fail('Test failed. Did not throw an exception.');
        } catch (VCC_DASException dasException) {
            Assert.isTrue(true, 'Expected exception thrown. Test passes.');
        }
        Test.stopTest();
    }
}
