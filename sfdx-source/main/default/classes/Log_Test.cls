@IsTest
private class Log_Test {
    @IsTest
    private static void debug() {
        // Setup
        enableLogEvents(System.today());

        Id contextId = 'a2R1T0000034dUTUAY';
        String message = '{0}=={1}:{2}';
        List<Object> values = new List<Object>{ 1, '2', false };
        // Execute

        Log.debugFlow(new List<Log.debugInvocable>());
        Log.error(contextId);
        Log.error(message, values);
        Log.error(message, contextId);

        Log.debug(message, values);
        Log.debug(message, values, contextId);
        Log.debug(message, contextId);
        Log.debug(contextId);
        Log.debug(message, values, contextId);

        // Verify
        Log__e logObject = Log.currentEvent;

        System.assertEquals('1==2:false', logObject.txl_Message__c);
        System.assertEquals(LoggingLevel.DEBUG.name(), logObject.txt_Level__c);
        System.assertEquals(contextId, logObject.txt_Context__c);
        System.assertEquals(thisClassName(), logObject.txt_Class__c);
        System.assertEquals('debug', logObject.txt_Method__c);
        System.assertEquals(26, logObject.num_Line__c);
    }
    @isTest
    private static void debugInvocable() {
        // Setup
        enableLogEvents(System.today());

        Id contextId = 'a2R1T0000034dUTUAY';
        String message = 'Sample Debug Message';
        List<Object> values = new List<Object>{ 'Sample Debug Message', contextId };
        List<Log.debugInvocable> values1 = new List<Log.debugInvocable>();
        Log.debugInvocable varInvocable;
        varInvocable = new Log.debugInvocable();
        varInvocable.message = message;
        varInvocable.contextId = contextId;

        values1.add(varInvocable);

        Log.debugFlow(values1);

        // Verify
        Log__e logObject = Log.currentEvent;

        System.assertEquals('Sample Debug Message', logObject.txl_Message__c);
        System.assertEquals(LoggingLevel.DEBUG.name(), logObject.txt_Level__c);
        System.assertEquals(contextId, logObject.txt_Context__c);
        System.assertEquals(thisClassName(), logObject.txt_Class__c);
        System.assertEquals('debugInvocable', logObject.txt_Method__c);
        System.assertEquals(64, logObject.num_Line__c);

        system.debug(logObject);
    }

    @IsTest
    private static void error() {
        // Setup
        enableLogEvents(System.today());

        // Execute
        Log.error('');

        // Verify
        System.assertEquals(LoggingLevel.ERROR.name(), Log.currentEvent.txt_Level__c);
    }

    @IsTest
    private static void timestampWhenNoContextId() {
        // Setup
        enableLogEvents(System.today());

        // Execute
        Log.debug('');

        // Verify
        System.assertNotEquals(null, Log.currentEvent.txt_Context__c);
    }

    @IsTest
    private static void noEventsSendWhenDisabled() {
        // Execute
        Log.debug('');

        // Verify
        System.assertEquals(null, Log.currentEvent);
    }

    @IsTest
    private static void noEventsWhenExpired() {
        // Setup
        enableLogEvents(yesterDay());

        // Execute
        Log.debug('');

        // Verify
        System.assertEquals(null, Log.currentEvent);
    }

    // HELPER

    private static void enableLogEvents(Date day) {
        insert new Log_Settings__c(SetupOwnerId = UserInfo.getUserId(), dat_LogViaEvents__c = day);
    }

    private static Date yesterDay() {
        return System.today().addDays(-1);
    }

    private static String thisClassName() {
        String ns = [SELECT NamespacePrefix FROM Organization].NamespacePrefix + '.';
        return Log_Test.class.getName().removeStart(ns);
    }
}
