/**
 * @author Kumar Balan
 * @group API - Bridg - Labs
 */
public with sharing class VCC_LabModal extends VCC_WrapperWithKeyword {
    public VCC_LabModal() {
        this.sites = new List<Sites>();
    }

    @AuraEnabled
    public List<Sites> sites;

    public class Sites {
        public Sites() {
            this.results = new Results();
        }

        @AuraEnabled
        public Results results;

        @AuraEnabled
        public Boolean isMaxRecordsError;
    }

    public class Results {
        public Results() {
            this.labs = new Labs();
        }

        @AuraEnabled
        public Labs labs;
    }

    public class Labs {
        public Labs() {
            this.lab = new List<Lab>();
        }

        @AuraEnabled
        public List<Lab> lab;
    }

    public class Lab {
        public Lab() {
            this.testName = new TestName();
            this.collected = new Collected();
            this.provider = new Provider();
            this.result = new Result();
            this.performingLab = new PerformingLab();
            this.sample = new Sample();
            this.units = new Units();
            this.high = new High();
            this.low = new Low();
            this.interpretation = new Interpretation();
            this.labOrderID = new LabOrderID();
        }

        @AuraEnabled
        public TestName testName;
        @AuraEnabled
        public Collected collected;
        @AuraEnabled
        public Provider provider;
        @AuraEnabled
        public Result result;
        @AuraEnabled
        public PerformingLab performingLab;
        @AuraEnabled
        public Sample sample;
        @AuraEnabled
        public Units units;
        @AuraEnabled
        public High high;
        @AuraEnabled
        public Low low;
        @AuraEnabled
        public Interpretation interpretation;
        @AuraEnabled
        public LabOrderID labOrderID;
        @AuraEnabled
        public Status status;
        @AuraEnabled
        public Type type;
        @AuraEnabled
        public Test test;
        @AuraEnabled
        public Facility facility;

        @AuraEnabled
        public Comment comment;

        @AuraEnabled
        public Loinc loinc;
    }

    public class Status {
        @AuraEnabled
        public String value;
    }
    public class Type {
        @AuraEnabled
        public String value;
    }
    public class Test {
        @AuraEnabled
        public String value;
    }
    public class Facility {
        @AuraEnabled
        public String name;
    }
    public class Comment {
        @AuraEnabled
        public String content;
    }
    public class Result {
        @AuraEnabled
        public String value;
    }

    public class TestName {
        @AuraEnabled
        public String value;
    }

    public class Collected {
        @AuraEnabled
        public String value {
            get;
            set {
                if (this.value == null) {
                    this.value = value;
                    this.collectedDate = VCC_Util.getDateFromNumber(value);
                    this.collectedDateStr = this.collectedDate.month() + '/' + this.collectedDate.day() + '/' + this.collectedDate.year();
                }
            }
        }
        @AuraEnabled
        public Date collectedDate;
        @AuraEnabled
        public String collectedDateStr;
    }

    public class Provider {
        @AuraEnabled
        public String name;
    }

    public class PerformingLab {
        @AuraEnabled
        public String value;
    }

    public class Sample {
        @AuraEnabled
        public String value;
    }

    public class Units {
        @AuraEnabled
        public String value;
    }

    public class High {
        @AuraEnabled
        public String value;
    }

    public class Low {
        @AuraEnabled
        public String value;
    }
    public class Interpretation {
        @AuraEnabled
        public String value;
    }

    public class LabOrderID {
        //W-011235 changing from double to string
        @AuraEnabled
        public String value;
    }

    public class Loinc {
        @AuraEnabled
        public String value;
    }

    /*public override Map<String, String> getKeywordTranslationMap() {
		return new Map<String, String> {
			'test' => 'testName'
		};
	}
	*/
}
