/**
 * @description       : Stateless sorting and assertion to enforce business process of one record per type. No transformation, only sorting and preventing violation
 * @author            : Joshua Slaugh
 * @group             : Thunder Yard
 * @last modified on  : 04-05-2022
 * @last modified by  :
 * Modifications Log
 * Ver   Date         Author        Modification
 *
 **/

public without sharing class NTSP_CasePRValidator {
    /**
     * @description Main entry to validate only with not transformations or new data
     * @author Joshua Slaugh | 04-07-2022
     * @return  void
     **/
    public static void validateInsert(List<NTSP_Peer_Review__c> newReviews) {
        List<NTSP_Peer_Review__c> reviewsToInsert = new List<NTSP_Peer_Review__c>();
        List<NTSP_Peer_Review__c> rejectedReviews = new List<NTSP_Peer_Review__c>();
        Map<id, List<NTSP_Peer_Review__c>> reviewMap = new Map<id, List<NTSP_Peer_Review__c>>();

        List<NTSP_Peer_Review__c> reviewList = [SELECT NTSP_Case__c, recordtypeid FROM NTSP_Peer_Review__c WHERE NTSP_Case__c IN (SELECT id FROM NTSP_Case__c)];

        reviewMap = getCaseToReviewMap(reviewList);

        for (NTSP_Peer_Review__c currentCaseReview : newReviews) {
            if (reviewMap.containsKey(currentCaseReview.NTSP_Case__c)) {
                //if reviews exist, does the case have placement for this type
                for (NTSP_Peer_Review__c pr : reviewMap.get(currentCaseReview.NTSP_Case__c)) {
                    //if the case already has 1 of this type, it is rejected
                    if (currentCaseReview.RecordTypeId == pr.RecordTypeId) {
                        rejectedReviews.add(currentCaseReview);
                        currentCaseReview.addError('A peer review for this Case has already been submitted');
                    }
                }
            }
        }
    }

    /**
     * @description Create map with case id as the key to all child reviews
     * @author Joshua Slaugh | 04-07-2022
     * @return  Map<id, List<NTSP_Peer_Review__c>>()
     **/
    private static map<id, List<NTSP_Peer_Review__c>> getCaseToReviewMap(List<NTSP_Peer_Review__c> reviewList) {
        map<Id, List<NTSP_Peer_Review__c>> reviewMap = new Map<Id, List<NTSP_Peer_Review__c>>();
        // List<NTSP_Peer_Review__c> reviewList = getAllReviewsWithCases();

        //map case key to list of peer reviews
        for (NTSP_Peer_Review__c r : reviewList) {
            if (reviewMap.containsKey(r.NTSP_Case__c)) {
                reviewMap.get(r.NTSP_Case__c).add(r);
            } else {
                reviewMap.put(r.NTSP_Case__c, new List<NTSP_Peer_Review__c>{ r });
            }
        }
        return reviewMap;
    }
}
