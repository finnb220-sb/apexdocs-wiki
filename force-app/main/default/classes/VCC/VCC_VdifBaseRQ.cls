/**
 * @description Base abstract class for VCC_Vdif RQ classes
 * @author      Booz Allen
 */
public abstract with sharing class VCC_VdifBaseRQ extends VCC_BaseRQ {
    /**
     * recordId used in VCC_VdifClient to generate http header
     */
    public Id recordId;
}
