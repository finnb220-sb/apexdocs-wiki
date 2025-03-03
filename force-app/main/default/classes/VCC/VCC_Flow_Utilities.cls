/**
 * @description Various utility functions for calling from flows.
 * @author Patrick Skamarak
 * @since 9/20/2021
 * @group Helpers/Utilities
 */
public with sharing class VCC_Flow_Utilities {
    /**
     * General category Invocable method which takes list of ActionParams as input and returns List of strings.
     * @description It populates the list based on the specified actionName in each ActionParams object in the input list.
     * Currently it supports actionName 'GetSObjectTypeForId' which adds the name of the SObjectType of the passed record to the returned list.
     * <p> <b>[To-do]</b> Need to check if bulkification is needed since this method gets called from a screen flow.
     *
     * @param params List of ActionParams objects
     * @return List<String> List of strings as per the actionName provided in each ActionParams object.
     * @InvocableMethod (Category = 'General')
     */
    @InvocableMethod(Category='General')
    public static List<String> flowUtility(List<ActionParams> params) {
        List<String> stringListToReturn = new List<String>();

        for (ActionParams param : params) {
            switch on param.actionName {
                when 'GetSObjectTypeForId' {
                    stringListToReturn.add(((Id) param.recordId).getSobjectType().getDescribe().getName());
                }
            }
        }
        //to-do bulkify?? not sure if its needed since this is called from a screen flow
        return stringListToReturn;
    }
    /**
     * @description Class representing parameters for Actions.
     * An object of this class can be used to pack the parameters for an Action, which can be processed by flowUtility method.
     *
     */
    public class ActionParams {
        /**
         * The name of the action to be performed. The flowUtility method behaviour depends upon this value.
         * @InvocableVariable
         */
        @InvocableVariable
        public String actionName;
        /**
         * The Id of the record on which the action will be performed.
         * Currently, it is used by flowUtility method when actionName is 'GetSObjectTypeForId'.
         * @InvocableVariable
         */
        @InvocableVariable
        public String recordId;
    }
}
