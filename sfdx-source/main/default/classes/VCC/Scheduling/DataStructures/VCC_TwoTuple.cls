/**
 * @description Class for relating two objects.
 * @see VCC_AppointmentUtilizationService
 */
public with sharing class VCC_TwoTuple {
    public Object valueOne;
    public Object valueTwo;

    /**
     * @description Constructor for setting internal properties.
     * @param valueOne `Object` Any sort of key that is related to the value property
     * @param valueTwo `Object` Any sort of value that is related to the key property.
     */
    public VCC_TwoTuple(Object valueOne, Object valueTwo) {
        this.valueOne = valueOne;
        this.valueTwo = valueTwo;
    }
}
