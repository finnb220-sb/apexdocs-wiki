/**
 * @description Tests forVCC_ProgressNoteCaseMetricBatch class
 * @author BAH
 * @see VCC_ProgressNoteCaseMetricBatch
 */

@isTest
private class VCC_ProgressNoteCaseMetricBatchTest {
    private static final Set<String> PERMISSION_SETS = new Set<String>{
        'VAHC_Write_Clinical_Triage_Progress_Note',
        'VAHC_Standard_VCC_User'
    };
    private static final User ADMIN_USER;
    static {
        ADMIN_USER = new VATEST_UserBuilder()
            .withUserProfile('System Administrator')
            .withPermissionSets(PERMISSION_SETS)
            .withStandardData()
            .build(true);
    }

    /**
     * @description Test to get the VCR_ProgressNoteRepo instance
     * Positive test case
     * @see VCC_ProgressNoteCaseMetricBatch.pnRepo
     */
    @IsTest
    static void unitTestVCRPNRepoInstancePositive() {
        System.runAs(ADMIN_USER) {
            VCR_ProgressNoteRepo vcrPNrepo;
            Test.startTest();
            vcrPNrepo = VCC_ProgressNoteCaseMetricBatch.pnRepo;
            Test.stopTest();
            Assert.isTrue(vcrPNrepo != null, 'VCR_ProgressNoteRepo instance is null');
        }
    }

    /**
     * @description Test to get the bind variables
     * Positive test case
     * @see VCC_ProgressNoteCaseMetricBatch.getBindVariables
     */

    @IsTest
    static void unitTestGetBindVariablesPositive() {
        System.runAs(ADMIN_USER) {
            Test.startTest();
            VCC_ProgressNoteCaseMetricBatch vccProgressNotesMetric = new VCC_ProgressNoteCaseMetricBatch();
            Map<String, Object> result = vccProgressNotesMetric.getBindVariables();
            Test.stopTest();
            Assert.isTrue(
                result.isEmpty(),
                'Expected bind variables not returned from the VCC_ProgressNoteCaseMetricBatch.getBindVariables() method'
            );
        }
    }

    /**
     * @description Test to get the query locator
     * Positive test case
     * @see VCC_ProgressNoteCaseMetricBatch.getQueryLocator
     */
    @IsTest
    static void funcTestGetQueryLocatorPositive() {
        System.runAs(ADMIN_USER) {
            Database.QueryLocator result;
            Test.startTest();
            VCC_ProgressNoteCaseMetricBatch vccPNMetrics = new VCC_ProgressNoteCaseMetricBatch();
            result = vccPNMetrics.getQueryLocator(vccPNMetrics.getQueryLocatorString());
            Test.stopTest();
            Assert.isTrue(result != null, 'VCC_ProgressNoteCaseMetricBatch.getQueryLocator() returned null');
        }
    }

    /**
     * @description Test to execute the VCC_ProgressNoteCaseMetricBatch class
     * Positive test case
     * Scenario that finds Progress Note records that have do not have
     * VCC_Case_Metric__c field populated and updates them with the correct values base on the related case
     * @see VCC_ProgressNoteCaseMetricBatch.execute
     */
    @IsTest
    static void funcTestExecutePositivePNUpdate() {
        System.runAs(ADMIN_USER) {
            List<VCC_Progress_Note__c> pnList = new List<VCC_Progress_Note__c>();
            List<VCC_Case_Metrics__c> cmList = new List<VCC_Case_Metrics__c>();
            User provider = (User) VATEST_UserFactory.createTestUser('VAVET Base Profile', true);
            String recordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName()
                .get('VCC_Vitrual_Clinic_Visit')
                .getRecordTypeId();
            List<Case> pnCases = (List<Case>) VATEST_SObjectFactory.createSObjects(
                new Case(OwnerId = provider.Id, RecordTypeId = recordTypeId),
                5,
                true
            );

            for (Integer count = 0; count < pnCases.size(); count++) {
                VCC_Progress_Note__c progressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Progress_Note__c(
                        VCC_Case__c = pnCases[count].Id,
                        VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
                    ),
                    true
                );
                pnList.add(progressNote);
            }

            for (Integer count = 0; count < pnCases.size(); count++) {
                VCC_Case_Metrics__c caseMetric = (VCC_Case_Metrics__c) VATEST_SObjectFactory.createSObject(
                    new VCC_Case_Metrics__c(VCC_Case__c = pnCases[count].Id),
                    true
                );
                cmList.add(caseMetric);
            }

            Test.startTest();
            VCC_ProgressNoteCaseMetricBatch pnMetrics = new VCC_ProgressNoteCaseMetricBatch();
            pnMetrics.execute(pnList);

            Test.stopTest();

            List<VCC_Progress_Note__c> progressNotesList = [
                SELECT Id, VCC_Case_Metrics__c, VCC_Case__c
                FROM VCC_Progress_Note__c
                WHERE VCC_Progress_Note_Title_IEN__c = 'CM PNotes'
            ];

            for (VCC_Progress_Note__c progressNote : progressNotesList) {
                Assert.isTrue(progressNote.VCC_Case_Metrics__c != null, 'Expected Case Metric to be populated');
            }
        }

    }
}
