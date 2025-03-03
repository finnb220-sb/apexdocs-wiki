/**
 * Author:Jaren Yach
 *  Created Date 05/20/2022
 *  Purpose: Selector Class for Test_Run__c
 */
public inherited sharing class TestRunSelector {
    /**
     * Gets records that need to be cleaned up
     *
     * @param days - Number of days
     *
     * @return List<Test_Run__c>
     */
    public List<Test_Run__c> getRecordsToPrune(Integer days) {
        String soql = String.format('SELECT Id FROM Test_Run__c WHERE Processed__c = TRUE AND CreatedDate != LAST_N_DAYS:{0}', new List<Object>{ days });
        return Database.query(soql);
    }

    /**
     * Gets the Test_Run__c record by Id
     * @param recId - Test Run Id
     *
     * @return Test_Run__c
     */
    public Test_Run__c getByRecordId(Id recId) {
        return [SELECT Id, Processed__c, Test_Failures__c FROM Test_Run__c WHERE Id = :recId];
    }
}
