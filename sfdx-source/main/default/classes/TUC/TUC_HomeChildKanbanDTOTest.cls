/**
 * @description Test class for TUC_HomeChildKanbanDTO
 * @author Booz Allen Hamilton
 * @see TUC_HomeChildKanbanDTO
 */
@IsTest
private with sharing class TUC_HomeChildKanbanDTOTest {
    /**
     * @description builds test user using VATEST_UserBuilder
     * @return `User`
     */
    private static User getTestUser() {
        return new VATEST_UserBuilder()
            .withPermissionSet('TED_Medical_Provider')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    @IsTest
    private static void unitInitializeDefaultConstructorPositive() {
        TUC_HomeChildKanbanDTO homeChildKanbanDTO;

        System.runAs(getTestUser()) {
            Test.startTest();
            homeChildKanbanDTO = new TUC_HomeChildKanbanDTO();
            Test.stopTest();
        }

        Assert.areEqual(
            new List<String>(),
            homeChildKanbanDTO.pickVals,
            'Expected pickVals to instantiate as an empty List<String>()'
        );
        Assert.areEqual(
            new Map<String, List<Case>>(),
            homeChildKanbanDTO.records,
            'Expected records to instantiate as Map<String, List<Case>>()'
        );
        Assert.areEqual(false, homeChildKanbanDTO.isSuccess, 'Expected isSuccess to instantiate as false');
        Assert.areEqual(null, homeChildKanbanDTO.errorMessage, 'Expected errorMessage to instantiate as null');
        Assert.areEqual(false, homeChildKanbanDTO.isEditable, 'Expected isEditable to instantiate as false');
        Assert.areEqual(false, homeChildKanbanDTO.isDeletable, 'Expected isDeletable to instantiate as false');
        Assert.areEqual(false, homeChildKanbanDTO.isCreatable, 'Expected isCreatable to instantiate as false');
        Assert.areEqual(
            new Map<String, Map<String, String>>(),
            homeChildKanbanDTO.fieldTypeMap,
            'Expected fieldTypeMap to instantiate as Map<String, Map<String, String>>()'
        );
    }

    @IsTest
    private static void unitInitializeWithValuesInputPositive() {
        TUC_HomeChildKanbanDTO homeChildKanbanDTO;
        TUC_CaseRepo caseRepo = new TUC_CaseRepo();
        Map<String, List<Case>> casesMap = new Map<String, List<Case>>();
        String errorMessage = 'test message to see if it sets something correctly';
        Boolean trueValue = true;

        System.runAs(getTestUser()) {
            Test.startTest();
            homeChildKanbanDTO = new TUC_HomeChildKanbanDTO(
                caseRepo.kanbanConfig.includedCaseStatuses,
                casesMap,
                caseRepo.kanbanConfig.fieldTypeMap
            );
            Test.stopTest();
        }

        Assert.areEqual(
            caseRepo.kanbanConfig.includedCaseStatuses,
            homeChildKanbanDTO.pickVals,
            'Expected  to match provided includedCaseStatuses'
        );
        Assert.areEqual(casesMap, homeChildKanbanDTO.records, 'Expected records to match provided casesMap');
        Assert.areEqual(
            caseRepo.kanbanConfig.fieldTypeMap,
            homeChildKanbanDTO.fieldTypeMap,
            'Expected fieldTypeMap to match provided caseRepo fieldTypeMap'
        );
    }

    @IsTest
    private static void unitPicklistValsFailNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                new TUC_HomeChildKanbanDTO(null, new Map<String, List<Case>>{}, new Map<String, Map<String, String>>{});
                Assert.fail('Should have thrown an exception');
            } catch (VTC_BadRequestException badRequestException) {
                Assert.isTrue(
                    badRequestException.getMessage().contains('You must provide a list of picklist values'),
                    'Expected the returned error message to match the assert message'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitRecordsMapFailNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                new TUC_HomeChildKanbanDTO(new List<String>{}, null, new Map<String, Map<String, String>>{});
                Assert.fail('Should have thrown an exception');
            } catch (VTC_BadRequestException badRequestException) {
                Assert.isTrue(
                    badRequestException.getMessage().contains('You must provide a map of records'),
                    'Expected the returned error message to match the assert message'
                );
            }
            Test.stopTest();
        }
    }

    @IsTest
    private static void unitFieldTypeMapFailNegative() {
        System.runAs(getTestUser()) {
            Test.startTest();
            try {
                new TUC_HomeChildKanbanDTO(new List<String>{}, new Map<String, List<Case>>{}, null);
                Assert.fail('Should have thrown an exception');
            } catch (VTC_BadRequestException badRequestException) {
                Assert.isTrue(
                    badRequestException.getMessage()
                        .contains('You must provide a map of field types that the Aura will expect'),
                    'Expected the returned error message to match the assert message'
                );
            }
            Test.stopTest();
        }
    }
}
