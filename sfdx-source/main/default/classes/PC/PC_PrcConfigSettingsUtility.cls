/**
 * @description Class used to faciliate custom metadata value being updated
 * @author Booz Allen
 * @since 2024
 **/
public with sharing class PC_PrcConfigSettingsUtility {
    /**
     * @description Method that allows test execution to set the Routing_Config ndth custom metadata to false, default value will be current Org's setting
     * @return Boolean Routing_Config custom metadata value
     **/
    public static Boolean ndthRoutingEnabled {
        get {
            return ndthRoutingEnabled = ndthRoutingEnabled ??
                PrC_Config_Settings__mdt.getInstance('Routing_Config').NDTH_Routing_Enabled__c;
        }
        set;
    }

    /**
     * @description Method that allows test execution to set the Routing_Config visn custom metadata to false, default value will be current Org's setting
     * @return Boolean Routing_Config custom metadata value
     **/
    public static Boolean visnRoutingEnabled {
        get {
            return visnRoutingEnabled = visnRoutingEnabled ??
                PrC_Config_Settings__mdt.getInstance('Routing_Config').VISN_Routing_Enabled__c;
        }
        set;
    }

    /**
     * @description Method that allows flow execute with Routing_Config custom metadata value
     * @return List<FlowOutput> Value of type Boolean passed to flow
     **/
    @InvocableMethod(
        label='Get NDTH Routing Setting'
        description='Returns the NDTH Routing Enabled value of the PrC Config Setting custom metadata'
    )
    public static List<FlowOutput> getNdthRoutingSetting() {
        FlowOutput output = new FlowOutput();
        output.ndthRoutingEnabledValue = ndthRoutingEnabled;
        return new List<FlowOutput>{ output };
    }

    /********************************************* Wrapper Class ***************************************************/
    /**
     * @description This wrapper class will be used by flow to send data
     **/
    public class FlowOutput {
        @InvocableVariable
        public Boolean ndthRoutingEnabledValue;
    }
}
