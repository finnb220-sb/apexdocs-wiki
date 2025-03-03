/**
 * Author:Jaren Yach
 *  Created Date 06/01/2022
 *  Purpose: Initiates creation of the test run records in a separate
 *  execution context.
 */
public with sharing class TestRunQueueable implements Queueable, Database.AllowsCallouts {
    public void execute(QueueableContext context) {
        TestRunService.createTestRun();
    }
}
