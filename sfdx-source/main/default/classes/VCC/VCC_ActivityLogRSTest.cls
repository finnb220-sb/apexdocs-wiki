@isTest
private class VCC_ActivityLogRSTest {
    static final String RESPONSE_BODY =
        '{' +
        '"success": true,' +
        '"message": "prescription ACTIVITY log found.",' +
        '"log": [' +
        '{' +
        '"activityLogDate": "2009-05-02T20:50:39",' +
        '"initiatorOfActivity": "POSTMASTER",' +
        '"reason": "ECME",' +
        '"rxReference": "ORIGINAL"' +
        '},' +
        '{' +
        '"activityLogDate": "2009-11-01T12:36:29",' +
        '"comment": "RX Placed on Suspense for CMOP until 11-12-09",' +
        '"otherComments": [ {"otherComments":"test"}, {"otherComments":"is"}, {"otherComments":"working"} ],' +
        '"initiatorOfActivity": "RINGOLD,ESTHER",' +
        '"reason": "IERX",' +
        '"rxReference": "ORIGINAL"' +
        '}' +
        ']' +
        '}';
    static final String RESPONSE_BODY_FAIL =
        '{' +
        '"success": false,' +
        '"message": "prescription ACTIVITY log found.",' +
        '"log": [' +
        '{' +
        '"activityLogDate": "2009-11-01T12:36:29",' +
        '"comment": "RX Placed on Suspense for CMOP until 11-12-09",' +
        '"otherComments": [ {"otherComments":"test"}, {"otherComments":"is"}, {"otherComments":"working"} ],' +
        '"initiatorOfActivity": "RINGOLD,ESTHER",' +
        '"reason": "IERX",' +
        '"rxReference": "ORIGINAL"' +
        '}' +
        ']' +
        '}';

    @isTest
    static void testParse() {
        VCC_ActivityLogRS response = VCC_ActivityLogRS.parse(RESPONSE_BODY);

        // Check that the response object was created correctly.
        System.assertEquals(true, response.success, 'The success flag should be true');
        System.assertEquals('prescription ACTIVITY log found.', response.message, 'The message should be "prescription ACTIVITY log found."');
        System.assertEquals(2, response.log.size(), 'There should be 2 activity logs in the response');

        // Check the values of the first activity log.
        VCC_ActivityLogRS.ActivityLog activityLog1 = response.log[0];
        System.assertEquals('POSTMASTER', activityLog1.initiatorOfActivity, 'The initiator of the first log should be "POSTMASTER"');
        System.assertEquals('ECME', activityLog1.reason, 'The reason of the first log should be "ECME"');

        // Check the values of the second activity log.
        VCC_ActivityLogRS.ActivityLog activityLog2 = response.log[1];
        System.assertEquals('ORIGINAL', activityLog2.rxReference, 'The rx reference of the second log should be "ORIGINAL"');
        System.assertEquals(
            'RX Placed on Suspense for CMOP until 11-12-09',
            activityLog2.comment,
            'The comment of the second log should be "RX Placed on Suspense for CMOP until 11-12-09"'
        );
    }

    @isTest
    static void testConcatSuccess() {
        VCC_ActivityLogRS act = VCC_ActivityLogRS.parse(RESPONSE_BODY).concatOtherComments();
        VCC_ActivityLogRS.ActivityLog act2 = act.log[1];
        System.assert(act2.otherCommentsString != null, 'Expected to not be null');
    }

    @isTest
    static void testConcatFail() {
        VCC_ActivityLogRS act = VCC_ActivityLogRS.parse(RESPONSE_BODY_FAIL).concatOtherComments();
        VCC_ActivityLogRS.ActivityLog act2 = act.log[0];
        System.assert(act2.otherCommentsString == null, 'Expected to be null');
    }
}
