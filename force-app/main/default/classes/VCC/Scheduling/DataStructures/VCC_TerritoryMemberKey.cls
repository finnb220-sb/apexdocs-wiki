/**
 * @description Class that 'Wraps' a ServiceTerritoryMember object so that we can key a ServiceTerritoryMember without
 * knowing the ServiceTerritoryMember's id. This is helpful when trying to determine what ServiceTerritoryMember is related to a shift,
 * since they are not directly related, rather they are related by their parent records.
 *
 * @see VCC_AppointmentUtilizationService
 * @see VCC_TerritoryMemberToTimeSlotMap
 *
 * @example
 *  Map<VCC_TerritoryMemberKey,Object> territoryMemberKeyToObjectMap = new Map<VCC_TerritoryMemberKey, Object>();
 *
 *
 * Shift myShiftIDontKnowTheServiceTerritoryMemberFor = new Shift(
 *          ServiceResourceID = foo,
 *          ServiceTerritoryId = bar
 *       );
 * VCC_TerritoryMemberKey keyDerivedFromAShift = new VCC_TerritoryMemberKey(
 *         myShiftIDontKnowTheServiceTerritoryMemberFor.serviceResourceId,
 *         myShiftIDontKnowTheServiceTerritoryMemberFor.ServiceTerritoryId
 *      );
 * territoryMemberKeyToObjectMap.get(keyDerivedFromAShift);
 *
 */
public inherited sharing class VCC_TerritoryMemberKey {
    public Id serviceTerritoryMemberId;
    public Id serviceResourceId;
    public Id serviceTerritoryId;
    public String visnName;

    /**
     * @description Constructor that takes a serviceTerritory member and sets the internal properties based on the fields on the sObject.
     * All fields are required on ServiceTerritoryMember so we can be certain they are set.
     * @param member `ServiceTerritoryMember` Salesforce Record that this Member Wraps.
     */
    public VCC_TerritoryMemberKey(ServiceTerritoryMember member) {
        this.serviceTerritoryMemberId = member.Id;
        this.serviceResourceId = member.ServiceResourceId;
        this.serviceTerritoryId = member.ServiceTerritoryId;
        this.visnName = member.ServiceTerritory.Name;
    }

    /**
     * @description Constructor that takes ServiceTerritory and Service Resource Ids.
     * Useful if you don't know the Id of the ServiceTerritoryMemberId.
     * @param serviceResourceId `Id` Id of the Service Resource we are keying off of.
     * @param serviceTerritoryId `Id` Id of the ServiceTerritory we are Keying off of.
     */
    public VCC_TerritoryMemberKey(Id serviceResourceId, Id serviceTerritoryId) {
        this.serviceResourceId = serviceResourceId;
        this.serviceTerritoryId = serviceTerritoryId;
    }

    /**
     * @description Definition of the equals method so we can compare this object based on just the ServiceResourceId and the ServiceTerritoryId
     * @param obj Object we are comparing to.
     * @return `Boolean` returns true or false based on whether the Service Resource Id and the Territory Id are the same.
     */
    public Boolean equals(Object obj) {
        if (!(obj instanceof VCC_TerritoryMemberKey)) {
            return false;
        }
        VCC_TerritoryMemberKey comparedKey = (VCC_TerritoryMemberKey) obj;
        return this.serviceResourceId == comparedKey.serviceResourceId &&
            this.serviceTerritoryId == comparedKey.serviceTerritoryId;
    }

    /**
     * @description To utilize this object in Hash based collections, Maps, Sets we must define a hash function.
     * This function adds the HashCodes of the field on the object, then multiplies it by the Prime number 31.
     * 31 is chosen because it is an odd prime that will not overflow on multiplication
     * and it is easily calculated by shifting, making it easy for the compiler to optimize
     * the multiplication.
     * @return Integer Hashcode representation of this object.
     */
    public Integer hashCode() {
        return (this.serviceResourceId.hashCode() + this.serviceResourceId.hashCode()) * 31;
    }
}
