/**
 * Author:Jaren Yach
 *  Created Date 05/27/2022
 *  Purpose: Wrapper class for Tooling Api Responses for ApexCodeCoverageAggregate object
 */
public with sharing class CodeCoverageWrapper {
    public List<Record> records { get; set; }
    public class Record {
        public String ApexClassorTriggerId { get; set; }
        public Integer NumLinesCovered { get; set; }
        public Integer NumLinesUncovered { get; set; }
        public ApexClassOrTrigger ApexClassOrTrigger { get; set; }

        /**
         * Overload method to convert class properties to CodeCoverage__c object
         *
         * @return CodeCoverage__c
         */
        public CodeCoverage__c toCodeCoverageSobject() {
            return toCodeCoverageSobject(null);
        }

        /**
         * Convert class properties to CodeCoverage__c object
         *
         * @param testRunId - Test run Id
         *
         * @return CodeCoverage__c
         */
        public CodeCoverage__c toCodeCoverageSobject(Id testRunId) {
            CodeCoverage__c cc = new CodeCoverage__c();
            cc.TestRun__c = testRunId;
            cc.ApexClassOrTriggerId__c = this.ApexClassorTriggerId;
            cc.ApexClassOrTriggerName__c = this.ApexClassOrTrigger.Name;
            cc.LinesCovered__c = this.NumLinesCovered;
            cc.LinesNotCovered__c = this.NumLinesUncovered;
            return cc;
        }
    }

    public class ApexClassOrTrigger {
        public String Name { get; set; }
    }

    /**
     * Easy way to deserialize json into object
     *
     * @param json - api response
     *
     * @return CodeCoverageWrapper
     */
    public static CodeCoverageWrapper parse(String json) {
        return (CodeCoverageWrapper) System.JSON.deserialize(json, CodeCoverageWrapper.class);
    }
}
