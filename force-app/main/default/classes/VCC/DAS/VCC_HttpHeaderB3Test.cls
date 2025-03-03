/**
 * @description Test class for VCC_HttpHeaderB3 Apex Class
 * @author      Booz Allen
 * @see         VCC_HttpHeaderB3
 * @see         VCC_HttpHeaderField
 */
@IsTest
private class VCC_HttpHeaderB3Test {
    private static Id createProgressNoteId() {
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            )
        );
        return testProgressNote.Id;
    }

    @IsTest
    private static void unitConstructorVDIFPositive() {
        Id progressNoteId = createProgressNoteId();
        Test.startTest();
        VCC_HttpHeaderB3 b3Header = new VCC_HttpHeaderB3(new VCC_TransactionId('vccVdifSelectPatient', progressNoteId));
        Test.stopTest();
        Assert.areEqual(
            VCC_HttpHeaderB3.VCC_HEADER_NAME_B3,
            b3Header.name,
            'Expected name to be equal to VCC_HEADER_NAME_B3 label.'
        );
        Assert.isTrue(
            (b3Header.value.contains('SelectPatient;') && b3Header.value.contains((String) progressNoteId)),
            'Expected value to contain endpoint name and record id.'
        );
    }

    @IsTest
    private static void unitConstructorDASPositive() {
        Id progressNoteId = createProgressNoteId();
        Test.startTest();
        VCC_HttpHeaderB3 b3Header = new VCC_HttpHeaderB3(
            new VCC_TransactionId(VCC_DAS.Endpoint.CREATE_ADDENDUM, progressNoteId)
        );
        Test.stopTest();
        Assert.areEqual(
            VCC_HttpHeaderB3.VCC_HEADER_NAME_B3,
            b3Header.name,
            'Expected name to be equal to VCC_HEADER_NAME_B3 label.'
        );
        Assert.isTrue(
            (b3Header.value.contains('CreateAddendum;') && b3Header.value.contains((String) progressNoteId)),
            'Expected value to contain endpoint name and record id.'
        );
    }

    @IsTest
    private static void unitConstructorNegative() {
        Test.startTest();
        try {
            new VCC_HttpHeaderB3(null);
            Assert.fail('Expected NullHeaderValueException was not thrown.');
        } catch (VCC_HttpHeaderField.NullHeaderValueException thrownException) {
            Assert.areEqual(
                'Http header value must not be null',
                thrownException.getMessage(),
                'Exception message does not match.'
            );
        }
        Test.stopTest();
    }
}
