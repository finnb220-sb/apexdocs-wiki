/**
 * @description       : holds helper methods for the territory related list LWC components (Location/VISN/Consortium)
 * @author            : WagnerJ@BAH
 * @group             :
 * @last modified on  : 02-17-2023
 * @last modified by  : WagnerJ@BAH
 **/
@SuppressWarnings('PMD.ApexDoc')
public with sharing class PC_RelatedListHelper {
    public class RelatedListException extends Exception {
    }

    //wrapper holding list of related records
    public class RelatedListResults {
        @AuraEnabled
        public List<RelatedListObject> records;
        //@AuraEnabled public String message;

        public RelatedListResults() {
            this.records = new List<RelatedListObject>();
        }

        /**
         * @description add to record list
         * @author WagnerJ@BAH | 06-07-2023
         * @param RelatedListObject rlo
         **/
        public void addToList(RelatedListObject rlo) {
            this.records.add(rlo);
        }
    }

    //single related list record
    public class RelatedListObject {
        @AuraEnabled
        public SObject record;
        @AuraEnabled
        public Boolean selected; //indicates to the LWC that the record has a pre-existing relationship to the territory
        @AuraEnabled
        public Boolean indirect; //indicates an indirect relationship between the record and the context territory

        public RelatedListObject(SObject record) {
            this.record = record;
            this.selected = false;
            this.indirect = false;
        }

        /**
         * @description sets the wrapper properties for the record indicating relationship status to the territory
         * 'selected' indicates that the record has a pre-existing relationship to the Territory so the respective row on the LWC table should be pre-checked
         * 'indirect' indicates that the record has a pre-existing relationship to the Territory, but it is not direct through a single junction
         * 'indirect' records will not be deselectable on the LWC table since requirements requested these relationships be undeletable due to their nature
         * @author WagnerJ@BAH | 03-20-2023
         * @param currentRelatedObjIdSet
         * @param idField
         * @param isIndirect
         **/
        public void setRelatedProperties(Set<Id> currentRelatedObjIdSet, String idField, Boolean isIndirect) {
            if (currentRelatedObjIdSet.contains(String.valueOf(record.get(idField)))) {
                this.selected = true; //indicates to the LWC that the record has a pre-existing relationship to the territory
                this.indirect = isIndirect; //indicates an indirect relationship between the record and the territory
            }
        }
    }
}
