/**
 * @description       : Class used to test the NTSP_CaseController Apex class
 * @author            : George Elias
 * @group             : Liberty IT Solutions
 * @last modified on  : 02-16-2022
 * @last modified by  : George Elias
 * Modifications Log
 * Ver   Date         Author                               Modification
 * 1.0   02-16-2022   George Elias                          Initial Version
 **/
@isTest
public class NTSP_CaseController_Test {
    /**
     * Message to display on failed assert
     */
    static String errorMessage = 'valueCheck was determined to be false, excpected return values are incorrect';

    /**
     * Creator map key
     */
    static String creatorId = 'creatorId';

    /**
     * Consultant map key
     */
    static String consultantId = 'consultantId';

    /**
     * Facility map key
     */
    static String facilityId = 'facilityId';

    /**
     * Date map key
     */
    static String dateString = 'dateString';

    /**
     * @description Method to create test data for unit tests
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @TestSetup
    static void makeData() {
        NTSP_TestDataFactory.createTestUsers();
        NTSP_TestDataFactory.createLocations();
        NTSP_TestDataFactory.createCases();
        NTSP_TestDataFactory.createPeerReviews();
    }

    /**
     * @description Unit test for the fetchComboboxOptions method in the NTSP_CaseController class
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    static void fetchComboboxOptionsTest() {
        final Map<String, List<Object>> resultMap = NTSP_CaseController.fetchComboboxOptions();

        final boolean valueCheck = resultMap.get('consultants').size() >= 2 && resultMap.get('creators').size() >= 4 && resultMap.get('facilities').size() == 3;

        System.assertEquals(valueCheck, true, errorMessage);
    }

    /**
     * @description Unit test for the searchCases method in the NTSP_CaseController class run as the nurse persona
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    static void searchCasesNurseTest() {
        final User nurse = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Nurse' LIMIT 1];
        final User consultant = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant' LIMIT 1];
        final NTSP_Facility__c location = [SELECT Id, Name FROM NTSP_Facility__c WHERE Name = 'Test 1' LIMIT 1];
        final String dateString = formatDate(Date.Today());

        final Map<String, String> searchMap = new Map<String, String>{ creatorId => nurse.Id, consultantId => consultant.Id, facilityId => location.Id, dateString => dateString };

        System.runAs(nurse) {
            List<NTSP_CaseController.CaseRowWrapper> resultList = NTSP_CaseController.searchCases(searchMap, 'test');

            final boolean valueCheck =
                resultList.size() == 4 &&
                resultList[0].caseCreator == nurse.Name &&
                resultList[0].consultant == consultant.Name &&
                resultList[0].facility == location.Name &&
                resultList[0].peerReview == null;

            System.assertEquals(valueCheck, true, errorMessage);
        }
    }

    /**
     * @description Unit test for the searchCases method in the NTSP_CaseController class run as the nurse peer reviewer persona
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    static void searchCasesNursePRTest() {
        final User nurse = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Nurse' LIMIT 1];
        final User consultant = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant' LIMIT 1];
        final NTSP_Facility__c location = [SELECT Id, Name FROM NTSP_Facility__c WHERE Name = 'Test 1' LIMIT 1];
        final String dateString = formatDate(Date.Today());
        final User nursePR = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Nurse PR' LIMIT 1];

        final List<NTSP_Case__c> caseList = [SELECT Id, CreatedById FROM NTSP_Case__c WHERE CreatedDate = TODAY];

        NTSP_TestDataFactory.mockCaseCriteriaSharing(caseList, nursePR.Id); //Criteria sharing is not evaluated in test classes, added method to mock functionality

        System.runAs(nursePR) {
            Map<String, String> searchMap = new Map<String, String>{ creatorId => nurse.Id, consultantId => consultant.Id, facilityId => location.Id, dateString => dateString };

            List<NTSP_CaseController.CaseRowWrapper> resultList = NTSP_CaseController.searchCases(searchMap, 'test');

            boolean valueCheck =
                resultList.size() == 4 &&
                resultList[0].caseCreator == nurse.Name &&
                resultList[0].consultant == consultant.Name &&
                resultList[0].facility == location.Name &&
                resultList[0].peerReview == 'In Progress' &&
                resultList[1].peerReview == 'Peer Review';

            searchMap = new Map<String, String>{ creatorId => nursePR.Id, consultantId => null, facilityId => location.Id, dateString => dateString };

            resultList = NTSP_CaseController.searchCases(searchMap, 'test');

            valueCheck = valueCheck && resultList[0].peerReview == 'Own Case';

            System.assertEquals(valueCheck, true, errorMessage);
        }
    }

    /**
     * @description Unit test for the searchCases method in the NTSP_CaseController class run as the consultant persona
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    static void searchCasesConsultantTest() {
        final User nurse = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Nurse' LIMIT 1];
        final User consultant = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant' LIMIT 1];
        final NTSP_Facility__c location = [SELECT Id, Name FROM NTSP_Facility__c WHERE Name = 'Test 1' LIMIT 1];
        final String dateString = formatDate(Date.Today());

        final List<NTSP_Case__c> caseList = [SELECT Id, CreatedById FROM NTSP_Case__c WHERE CreatedDate = TODAY];

        NTSP_TestDataFactory.mockCaseCriteriaSharing(caseList, consultant.Id); //Criteria sharing is not evaluated in test classes, added method to mock functionality

        System.runAs(consultant) {
            final Map<String, String> searchMap = new Map<String, String>{
                creatorId => nurse.Id,
                consultantId => consultant.Id,
                facilityId => location.Id,
                dateString => dateString
            };

            final List<NTSP_CaseController.CaseRowWrapper> resultList = NTSP_CaseController.searchCases(searchMap, 'test');

            final boolean valueCheck =
                resultList.size() == 4 &&
                resultList[0].caseCreator == nurse.Name &&
                resultList[0].consultant == consultant.Name &&
                resultList[0].facility == location.Name &&
                resultList[0].peerReview == null;

            System.assertEquals(valueCheck, true, errorMessage);
        }
    }

    /**
     * @description Unit test for the searchCases method in the NTSP_CaseController class run as the consultant peer reviewer persona
     * @author George Elias | 02-16-2022
     * @return  void
     **/
    @isTest
    static void searchCasesConsultantPRTest() {
        final User nurse = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Nurse' LIMIT 1];
        final User consultant = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant' LIMIT 1];
        final NTSP_Facility__c location = [SELECT Id, Name FROM NTSP_Facility__c WHERE Name = 'Test 1' LIMIT 1];
        final String dateString = formatDate(Date.Today());
        final User consultantPR = [SELECT Id, Name FROM User WHERE LastName = 'NTSP Consultant PR' LIMIT 1];

        final List<NTSP_Case__c> caseList = [SELECT Id, CreatedById FROM NTSP_Case__c WHERE CreatedDate = TODAY];

        NTSP_TestDataFactory.mockCaseCriteriaSharing(caseList, consultantPR.Id); //Criteria sharing is not evaluated in test classes, added method to mock functionality

        System.runAs(consultantPR) {
            Map<String, String> searchMap = new Map<String, String>{ creatorId => nurse.Id, consultantId => consultant.Id, facilityId => location.Id, dateString => dateString };

            List<NTSP_CaseController.CaseRowWrapper> resultList = NTSP_CaseController.searchCases(searchMap, 'test');

            boolean valueCheck =
                resultList.size() == 4 &&
                resultList[0].caseCreator == nurse.Name &&
                resultList[0].consultant == consultant.Name &&
                resultList[0].facility == location.Name &&
                resultList[0].peerReview == 'In Progress' &&
                resultList[1].peerReview == 'Peer Review';
            System.debug(resultList[0].peerReview);
            searchMap = new Map<String, String>{ creatorId => null, consultantId => consultantPR.Id, facilityId => location.Id, dateString => dateString };

            resultList = NTSP_CaseController.searchCases(searchMap, 'test');

            valueCheck = valueCheck && resultList[0].peerReview == 'Own Case';

            System.assertEquals(valueCheck, true, errorMessage);
        }
    }

    private static String formatDate(Date dateField) {
        final String year = dateField.year() + '';
        final String month = dateField.month() < 10 ? '0' + dateField.month() : dateField.month() + '';
        final String day = dateField.day() < 10 ? '0' + dateField.day() : dateField.day() + '';
        return year + '-' + month + '-' + day;
    }
}
