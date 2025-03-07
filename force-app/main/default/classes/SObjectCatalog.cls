/**
 * SObjectCatalog
 *
 * Description: Collection-like utility class with convenience methods
 * for commonly used SObject patterns
 *
 * @Author Dupont Circle Solutions (Tim Phang)
 */
public class SObjectCatalog {
  public Map<Id, SObject> sObjectMap;

  public SObjectCatalog(List<SObject> sObjects) {
    sObjectMap = new Map<Id, SObject>();
    for(SObject anObject : sObjects) {
      sObjectMap.put(anObject.Id, anObject);
    }
  }

  /**
   * Return the SObject with Id = objectId. Returns
   * NULL if none found.
   *
   * @param Id objectId
   * @return SObject
   */
  public sObject get(Id objectId) {
    return sObjectMap.get(objectId);
  }

  /**
   * Build a map of SObjects organized by _fieldName_
   * return the SObject that matches
   *
   * @param String fieldName
   * @param Object value
   * @return SObject
   */
  public sObject getBy(String fieldName, Object value) {
    return mapBy(fieldName).get(value);
  }

  /**
   * Return a set of IDs of all SObjects in the catalog
   *
   * @return Set<Id>
   */
  public Set<Id> keys() {
    return sObjectMap.keySet();
  }

  /**
   * Build a map of lists organized by fieldName. Useful
   * for creating a map that groups SObjects by an attribute.
   *
   * @param String fieldName
   * @return Map<Object, List<SObject>>
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
   * Build a map of SObjects by fieldName. Useful for creating
   * a map of SObjects by a single attribute.
   *
   * @param String fieldName
   * @return Map<Object, SObject>
   */
  public Map<Object, SObject> mapBy(String fieldName) {
    Map<Object, SObject> mapByField = new Map<Object, SObject>();

    for(SObject obj : sObjectMap.values()) {
      mapByField.put(obj.get(fieldName), obj);
    }

    return mapByField;
  }

  /**
   * Conveience method to return a list of the SObjects
   * in the catalog
   *
   * @return List<SObject>
   */
  public List<SObject> values(){
    return sObjectMap.values();
  }
}
