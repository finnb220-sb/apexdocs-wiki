/**
 * @description Class that enables scheduling of VCC_BatchMPICorrelate.
 * @author Marcus Dietz
 * @since 6/14/2021
 * @group API - MPI
 * @see VCC_BatchMPICorrelate
 */
global with sharing class VCC_BatchMPICorrelateScheduler implements Schedulable {
    global void execute(SchedulableContext sch) {
        VCC_BatchMPICorrelate batchJobForClass = new VCC_BatchMPICorrelate();
        database.executeBatch(batchJobForClass, 1);
    }
}
