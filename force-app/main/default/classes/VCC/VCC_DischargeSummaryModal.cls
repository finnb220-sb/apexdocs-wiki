/**
 * @author Kumar Balan
 * @group API - Bridg - Notes
 */
public with sharing class VCC_DischargeSummaryModal extends VCC_WrapperWithKeyword {
    @AuraEnabled
    public List<Sites> sites;

    public class Sites {
        @AuraEnabled
        public Data data;
    }

    public class Data {
        @AuraEnabled
        public List<Item> items;
    }

    public class Item {
        @AuraEnabled
        public String documentClass;
        @AuraEnabled
        public String encounterName;
        @AuraEnabled
        public String encounterUid;
        @AuraEnabled
        public String facilityCode;

        @AuraEnabled
        public String entered {
            get;
            set {
                if (value != null) {
                    String timeValue = String.valueOf(value);
                    enteredDateStr = timeValue.substring(4, 6) + '/' + timeValue.substring(6, 8) + '/' + timeValue.substring(0, 4); //+ ' '+ timeValue.substring(8,10) +':'+
                    //timeValue.substring(10,12);
                    this.enteredDate = Date.newInstance(
                        Integer.valueOf(timeValue.substring(0, 4)),
                        Integer.valueOf(timeValue.substring(4, 6)),
                        Integer.valueOf(timeValue.substring(6, 8))
                        //0,
                        //0,
                        //Integer.valueOf(timeValue.substring(8,10)),
                        //Integer.valueOf(timeValue.substring(10,12)),
                        //0
                    );
                }
                entered = value;
            }
        }
        @AuraEnabled
        public Date enteredDate;
        @AuraEnabled
        public String enteredDateStr;

        @AuraEnabled
        public String facilityName;
        @AuraEnabled
        public String referenceDateTime;
        @AuraEnabled
        public String statusName;
        @AuraEnabled
        public String urgency;
        @AuraEnabled
        public String attendingName;
        @AuraEnabled
        public String localTitle;

        @AuraEnabled
        public List<Text> text;
    }

    public class Text {
        @AuraEnabled
        public List<Clinicians> clinicians;
        @AuraEnabled
        public String content;
        @AuraEnabled
        public String status;
    }

    public class Clinicians {
        @AuraEnabled
        public String name;
        @AuraEnabled
        public String signature;
        @AuraEnabled
        public String role;
    }
}
