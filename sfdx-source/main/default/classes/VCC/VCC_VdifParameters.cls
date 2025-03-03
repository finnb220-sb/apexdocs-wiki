/**
 * @description VCC_VdifParameters object definition
 *
 * @author Liberty
 * @since 01/09/2024
 * @group VAHC
 */
public with sharing class VCC_VdifParameters {
    /**
     * @description The record Id associated with this transaction
     */
    public Id recordId { get; set; }
    /**
     * @description getter/setter for vdifNote
     */
    public VCC_VdifNote vdifNote { get; set; }
    /**
     * @description getter/setter for vdifEncounter
     */
    public VCC_VdifEncounter vdifEncounter { get; set; }
    /**
     * @description getter/setter for vdifPatient
     */
    public VCC_VdifPatient vdifPatient { get; set; }
    /**
     * @description getter/setter for vdifProvider
     */
    public VCC_VdifProvider vdifProvider { get; set; }

    /**
     * @description default constructor method
     */
    public VCC_VdifParameters() {
        this.vdifNote = new VCC_VdifNote();
        this.vdifEncounter = new VCC_VdifEncounter();
        this.vdifPatient = new VCC_VdifPatient();
        this.vdifProvider = new VCC_VdifProvider();
    }
}
