@suppressWarnings('pmd.VariableNamingConventions')
public with sharing class VCC_Lab {
    // public String Comment{ get; set; }
    public String DateTestVCC { get; set; }
    public String Interpretation { get; set; }
    public String Loinc { get; set; }
    public String Provider { get; set; }
    public String Result { get; set; }
    public String Sample { get; set; }
    public String Status { get; set; }
    public String Test { get; set; }

    public VCC_Lab() {
    }

    public VCC_Lab(String dateTestVCC, String interpretation, String loinc, String provider, String result, String sample, String status, String test) {
        this.DateTestVCC = dateTestVCC;
        this.Interpretation = interpretation;
        this.Loinc = loinc;
        this.Provider = provider;
        this.Result = result;
        this.Sample = sample;
        this.Status = status;
        this.Test = test;
    }

    public VCC_Lab(String comment, String dateTestVCC, String interpretation, String loinc, String provider, String result, String sample, String status, String test) {
        // this.Comment = comment;
        this.DateTestVCC = dateTestVCC;
        this.Interpretation = interpretation;
        this.Loinc = loinc;
        this.Provider = provider;
        this.Result = result;
        this.Sample = sample;
        this.Status = status;
        this.Test = test;
    }
}
