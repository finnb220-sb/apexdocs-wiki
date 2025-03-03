/**
 * @description Base abstract class for RQ classes.
 * @author      Booz Allen
 */
public abstract with sharing class VCC_BaseRQ {
    /**
     * @description Used to validate class properties are not null or blank
     * @return      `Boolean`
     */
    abstract public Boolean isValid();
}
