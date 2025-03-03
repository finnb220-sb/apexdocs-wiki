/**
 * VCC_MedicationsRS
 * @description Top level response shape for VCC Medications.
 * @author Liberty
 * @date 12/8/2021
 */

public with sharing class VCC_MedicationsData {
    public List<VCC_Site> sites { get; set; }

    public VCC_MedicationsData() {
        this.sites = new List<VCC_Site>();
    }

    public class VCC_Site {
        public VCC_Results results { get; set; }

        public VCC_Site() {
            this.results = new VCC_Results();
        }
    }

    public class VCC_Results {
        public VCC_Meds meds { get; set; }

        public VCC_Results() {
            this.meds = new VCC_Meds();
        }
    }

    public class VCC_Meds {
        public List<VCC_Med> med { get; set; }
        public String total { get; set; }
        public String timeZone { get; set; }
        public String version { get; set; }

        public VCC_Meds() {
            this.med = new List<VCC_Med>();
        }
    }

    public class VCC_Med {
        public VCC_ValueType expires { get; set; }
        public VCC_Doses doses { get; set; }
        public VCC_ValueType vaStatus { get; set; }
        public VCC_ValueType fillsAllowed { get; set; }
        public VCC_ValueType medID { get; set; }
        public VCC_CodeNameType pharmacist { get; set; }
        public VCC_ValueType lastFilled { get; set; }
        public VCC_ValueType type { get; set; }
        public VCC_Products products { get; set; }
        public VCC_ContentType sig { get; set; }
        public VCC_ValueType routing { get; set; }
        public VCC_ValueType fillsRemaining { get; set; }
        public VCC_ValueType id { get; set; }
        public VCC_Fills fills { get; set; }
        public VCC_ValueType vaType { get; set; }
        public VCC_ValueType ordered { get; set; }
        public VCC_Provider orderingProvider { get; set; }
        public VCC_ValueType quantity { get; set; }
        public VCC_ValueType orderID { get; set; }
        public VCC_ValueType daysSupply { get; set; }
        public VCC_ValueType start { get; set; }
        public VCC_ValueType fillCost { get; set; }
        public VCC_ValueType form { get; set; }
        public VCC_ValueType stop { get; set; }
        public VCC_ValueType prescription { get; set; }
        public VCC_ValueType name { get; set; }
        public VCC_CodeNameType location { get; set; }
        public VCC_CodeNameType facility { get; set; }
        public VCC_Provider currentProvider { get; set; }
        public VCC_ValueType status { get; set; }

        public VCC_Med() {
            this.expires = new VCC_ValueType();
            this.doses = new VCC_Doses();
            this.vaStatus = new VCC_ValueType();
            this.fillsAllowed = new VCC_ValueType();
            this.medID = new VCC_ValueType();
            this.pharmacist = new VCC_CodeNameType();
            this.lastFilled = new VCC_ValueType();
            this.type = new VCC_ValueType();
            this.products = new VCC_Products();
            this.sig = new VCC_ContentType();
            this.routing = new VCC_ValueType();
            this.fillsRemaining = new VCC_ValueType();
            this.id = new VCC_ValueType();
            this.fills = new VCC_Fills();
            this.vaType = new VCC_ValueType();
            this.ordered = new VCC_ValueType();
            this.orderingProvider = new VCC_Provider();
            this.quantity = new VCC_ValueType();
            this.orderID = new VCC_ValueType();
            this.daysSupply = new VCC_ValueType();
            this.start = new VCC_ValueType();
            this.fillCost = new VCC_ValueType();
            this.form = new VCC_ValueType();
            this.stop = new VCC_ValueType();
            this.prescription = new VCC_ValueType();
            this.name = new VCC_ValueType();
            this.location = new VCC_CodeNameType();
            this.facility = new VCC_CodeNameType();
            this.currentProvider = new VCC_Provider();
            this.status = new VCC_ValueType();
        }
    }

    public class VCC_Provider {
        public String content { get; set; }
        public String service { get; set; }
        public String email { get; set; }
        public String vuid { get; set; }
    }

    public class VCC_Doses {
        public List<VCC_Dose> dose { get; set; }

        public VCC_Doses() {
            this.dose = new List<VCC_Dose>();
        }
    }

    public class VCC_Dose {
        public String schedule { get; set; }
        public String dose { get; set; }
        public String doseStop { get; set; }
        public String route { get; set; }
        public String noun { get; set; }
        public String unitsPerDose { get; set; }
        public String units { get; set; }
        public String doseStart { get; set; }
    }

    public class VCC_Fills {
        public List<VCC_Fill> fill { get; set; }

        public VCC_Fills() {
            this.fill = new List<VCC_Fill>();
        }
    }

    public class VCC_Fill {
        public String fillDate { get; set; }
        public String fillDaysSupply { get; set; }
        public String fillQuantity { get; set; }
        public String fillRouting { get; set; }
    }

    public class VCC_Products {
        public List<VCC_Product> product { get; set; }

        public VCC_Products() {
            this.product = new List<VCC_Product>();
        }
    }

    public class VCC_Product {
        public VCC_CodeNameVuidType vaGeneric { get; set; }
        public String code { get; set; }
        public String role { get; set; }
        public VCC_CodeNameVuidType vaProduct { get; set; }
        public String name { get; set; }
        public String concentration { get; set; }
        public VCC_CodeNameVuidType x_class { get; set; }

        public VCC_Product() {
            this.vaGeneric = new VCC_CodeNameVuidType();
            this.vaProduct = new VCC_CodeNameVuidType();
            this.x_class = new VCC_CodeNameVuidType();
        }
    }

    public class VCC_ContentType {
        public String content { get; set; }
    }

    public class VCC_CodeNameType {
        public String code { get; set; }
        public String name { get; set; }
    }

    public class VCC_CodeNameVuidType {
        public String code { get; set; }
        public String name { get; set; }
        public String vuid { get; set; }
    }

    public class VCC_ValueType {
        public String value { get; set; }
    }
}
