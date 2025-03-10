/**
 * @name SObjectCatalog
 *
 * @description Collection-like utility class with convenience methods
 * for commonly used SObject patterns
 *
 * @Author Dupont Circle Solutions (Tim Phang)
 *
 * @group SObject Collection Utility
 * @see SObjectCatalogTest
 */
public class SObjectCatalog {
  public Map<Id, SObject> sObjectMap;

  /**
   * @description Constructor - create a Catalog for the given collection of SObjects
   * @param sObjects records for our collection
   */
  public SObjectCatalog(List<SObject> sObjects) {
    sObjectMap = new Map<Id, SObject>();
    for(SObject anObject : sObjects) {
      sObjectMap.put(anObject.Id, anObject);
    }
  }

  /**
   * @description Retrieve & return the SObject where Id = `objectId`. Returns
   * NULL if none found.
   *
   * @param objectId `Id` Id for record to find
   * @return SObject for given objectId, null if not in our collection
   */
  public sObject get(Id objectId) {
    return sObjectMap.get(objectId);
  }

  /**
   * @description Build a map of SObjects organized by `fieldName`
   * and return the SObject that matches `value`
   *
   * @param fieldName `String` containing API name of field to sort & match by
   * @param value `Object` Value of `fieldName` to match on
   * @return SObject record where fieldName = value in our collection or null if none are found
   */
  public sObject getBy(String fieldName, Object value) {
    return mapBy(fieldName).get(value);
  }

  /**
   * @description Returns a set of Ids of all SObjects in the catalog
   *
   * @return Set<Id> Set of all record Ids for our internal collection of SObjects, empty set if no records in catalog
   */
  public Set<Id> keys() {
    return sObjectMap.keySet();
  }

  /**
   * @description Builds a map of lists organized by `fieldName`. Useful
   * for creating a map that groups SObjects by an attribute.
   *
   * @param fieldName `String` API name of field by which we want to build a map of lists
   * @return Map<Object, List<SObject>> Map of Lists of SObjects from our collection, where the map keys
   * are fieldName values and map values are lists of all matching elements from our collection
   */
  public Map<Object, List<SObject>> listBy(String fieldName) {
    Map<Object, List<SObject>> mapByField = new Map<Object, List<SObject>>();

    for(SObject obj : sObjectMap.values()) {
      Object fieldValue = obj.get(fieldName);
      if(mapByField.get(fieldValue) == NULL) mapByField.put(fieldValue, new List<SObject>());

      mapByField.get(fieldValue).add(obj);
    }

    return mapByField;
  }

  /**
   * @description Build a map of SObjects by `fieldName`. Useful for creating a map of
   * SObjects by a single attribute. ASSUMPTION is that `fieldName` is unique across the
   * collection, otherwise the last element in the collection will be the only one added to the return map
   *
   * @param fieldName `String` API name of field by which we map records
   * @return Map<Object, SObject> Map of SObject records keyed off fieldName.
   */
  public Map<Object, SObject> mapBy(String fieldName) {
    Map<Object, SObject> mapByField = new Map<Object, SObject>();

    for(SObject obj : sObjectMap.values()) {
      mapByField.put(obj.get(fieldName), obj);
    }

    return mapByField;
  }

  /**
   * @description Convenience method to return a list of the SObjects
   * in the catalog
   *
   * @return List<SObject> List of Sobject records in our collection
   */
  public List<SObject> values() {
    return sObjectMap.values();
  }
}
