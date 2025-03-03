/**
 * @description       :
 * @author            : Ronald Stewart
 * @group             :
 * @last modified on  : 01-16-2024
 * @last modified by  : Ronald Stewart
 **/
@isTest
class VCC_CaseModalTest {
    @TestSetup
    static void makeData() {
        Id profileId = DTCTestUtil.getProfileId('VAVET Base Profile');
        User vahcUser = DTCTestUtil.createUserWithProfile(profileId);
        List<String> permissionSets = new List<String>{ 'VAHC Registered Nurse', 'VCC Integration Test Utility User' };
        DTCTestUtil.addPermSetsToUser(vahcUser, permissionSets);
    }

    @isTest
    static void testVCCCaseModalTest() {
        User vahcUser = [SELECT ID FROM User LIMIT 1];
        System.runAs(vahcUser) {
            Test.startTest();
            VCC_CaseModal caseModal = new VCC_CaseModal();
            caseModal.caseId = '';
            caseModal.caseNumber = '';
            caseModal.caseURL = '';
            caseModal.contactId = '';
            caseModal.contactName = '';
            caseModal.contactURL = '';
            caseModal.recordType = '';
            caseModal.caseType = '';
            caseModal.caseSubType = '';
            caseModal.subject = '';
            caseModal.subjectURL = '';
            caseModal.status = '';
            caseModal.dateTimeOpened = DateTime.newInstance(2006, 3, 16, 12, 6, 13);
            caseModal.dateTimeOpenedStr = ''; //datetime
            caseModal.caseOwnerAlias = '';
            caseModal.followUpAppt = '';
            caseModal.followUpApptHours = 5.49;
            Test.stopTest();
            System.assert(caseModal != null, 'Expected the class to be initialized.');
        }
    }
}
