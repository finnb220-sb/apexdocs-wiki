@IsTest
@SuppressWarnings('PMD.ClassNamingConventions')
private with sharing class log_BatchLogServiceTest {
    @IsTest
    private static void databaseErrorLog() {
        List<Database.SaveResult> results = Database.update(new List<Account>{ new Account() }, false);

        Database.SaveResult result = results[0];
        if (!result.isSuccess()) {
            Database.Error error = result.getErrors().get(0);
            log_BatchLogService.DatabaseErrorDetailLog detail = new log_BatchLogService.DatabaseErrorDetailLog(error);
            log_BatchLogService.DatabaseErrorLog log = new log_BatchLogService.DatabaseErrorLog(
                UserInfo.getUserId(),
                new List<log_BatchLogService.DatabaseErrorDetailLog>{ detail }
            );
            System.assertEquals(log.recordId, UserInfo.getUserId());
            System.assertEquals(log.objectName, 'User');
            System.assertEquals(log.logDetails.size(), 1);
            System.assertEquals(detail.status, String.valueOf(error.getStatusCode()));
            System.assertEquals(detail.message, error.getMessage());
        }
    }

    @IsTest
    private static void batchInfoLog() {
        AsyncApexJob asyncApexJob = new AsyncApexJob();

        Test.startTest();
        log_BatchLogService.BatchInfoLog batchInfoLog = new log_BatchLogService.BatchInfoLog(asyncApexJob);
        Test.stopTest();

        System.assert(batchInfoLog != null, 'Expected class to be initialized.');
    }
}
