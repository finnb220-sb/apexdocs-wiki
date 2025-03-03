/**
 * @description       : Unit test to validate the NTSP_CasePR.cls to prevent
 * @author            : Joshua Slaugh
 * @group             : Thunder Yard
 * @last modified on  : 04-11-2022
 * @last modified by  :
 * Modifications Log
 * Ver   Date         Author        Modification
 *
 **/
@isTest
public class NTSP_CasePRValidator_Test {
    /**
     * @description Test data setup
     * @author Joshua Slaugh | 04-11-2022
     * @return  void
     **/
    @testSetup
    static void init() {
        NTSP_TestDataFactory.createTestUsers();
        NTSP_TestDataFactory.createLocations();
        NTSP_TestDataFactory.createCases();
        NTSP_TestDataFactory.createPeerReviews();
    }

    /**
     * @description verify records were inserted
     * @author Joshua Slaugh | 04-11-2022
     * @return  void
     **/
    static testMethod void checkInsert() {
        list<NTSP_Peer_Review__c> reviewList = [SELECT id, recordTypeId FROM NTSP_Peer_Review__c];
        test.starttest();
        for (NTSP_Peer_Review__c pr : reviewList) {
            system.debug('Peer Review was inserted for test with ID:\n');
        }
        test.stoptest();
        system.assertNotEquals(reviewList, null, 'no test records were inserted. Failed');
    }
    /**
     * @description Try to reinsert the same reviews again and make sure it has failed
     * @author Joshua Slaugh | 04-11-2022
     * @return  void
     **/
    static testMethod void happyReviewInsert() {
        list<NTSP_Case__c> cases = [SELECT id FROM NTSP_Case__c WHERE id IN (SELECT NTSP_Case__c FROM NTSP_Peer_Review__c)];
        list<NTSP_Peer_Review__c> reviewList = [SELECT id, recordTypeId FROM NTSP_Peer_Review__c];
        integer reviewListSize = reviewList.size();
        test.starttest();
        try {
            NTSP_TestDataFactory.createPeerReviews();
        } catch (dmlexception dmx) {
            system.debug('There should be an error inserting the same peer review list');
        }

        test.stoptest();

        list<NTSP_Peer_Review__c> reviewListTriedDuplication = [SELECT id, recordTypeId FROM NTSP_Peer_Review__c];
        integer reviewListSizeAfterAttemptDuplication = reviewListTriedDuplication.size();
        system.assertEquals(reviewListSizeAfterAttemptDuplication, reviewListSize, 'More than a review per type was inserted');
    }
}
