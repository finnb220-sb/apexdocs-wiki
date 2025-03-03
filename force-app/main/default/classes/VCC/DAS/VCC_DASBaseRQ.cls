/**
 * @description This is an abstract base class for all DAS request classes in the VCC module.
 * It provides a method to validate the request and a helper method to handle null values.
 * @author Booz Allen
 */
public abstract with sharing class VCC_DASBaseRQ {
    /**
     * This is an abstract method that must be implemented by all subclasses.
     * It should return true if the request is valid, and false otherwise.
     * @return Boolean - true if the request is valid, false otherwise
     */
    public abstract Boolean isValid();

    /**
     * @description DAS does not like null values and always expects a string of some kind.
     * This method is used in the setters of all RQ class properties
     * @param value - helper getter to ensure nulls are empty strings
     * @return String - the value or an empty string
     */
    protected String propertyGetter(String value) {
        if (value == null) {
            return '';
        }
        return value;
    }
}
