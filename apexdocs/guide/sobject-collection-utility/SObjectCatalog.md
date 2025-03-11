# SObjectCatalog Class

`APIVERSION: 46`
`STATUS: ACTIVE`

Collection-like utility class with convenience methods 
for commonly used SObject patterns

**Name** 

SObjectCatalog

**Group** SObject Collection Utility

**Author** Dupont Circle Solutions (Tim Phang)

**See** [SObjectCatalogTest](SObjectCatalogTest.md)

## Fields
### `sObjectMap`

#### Signature
```apex
public sObjectMap
```

#### Type
Map&lt;Id,SObject&gt;

## Constructors
### `SObjectCatalog(sObjects)`

Constructor - create a Catalog for the given collection of SObjects

#### Signature
```apex
public SObjectCatalog(List<SObject> sObjects)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjects | List&lt;SObject&gt; | records for our collection |

## Methods
### `get(objectId)`

Retrieve &amp; return the SObject where Id &#x3D; `objectId` . Returns 
NULL if none found.

#### Signature
```apex
public sObject get(Id objectId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| objectId | Id | `Id` Id for record to find |

#### Return Type
**sObject**

SObject for given objectId, null if not in our collection

---

### `getBy(fieldName, value)`

Build a map of SObjects organized by `fieldName` 
and return the SObject that matches `value`

#### Signature
```apex
public sObject getBy(String fieldName, Object value)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| fieldName | String | `String` containing API name of field to sort &amp; match by |
| value | Object | `Object` Value of `fieldName` to match on |

#### Return Type
**sObject**

SObject record where fieldName &#x3D; value in our collection or null if none are found

---

### `keys()`

Returns a set of Ids of all SObjects in the catalog

#### Signature
```apex
public Set<Id> keys()
```

#### Return Type
**Set&lt;Id&gt;**

Set&lt;Id&gt; Set of all record Ids for our internal collection of SObjects, empty set if no records in catalog

---

### `listBy(fieldName)`

Builds a map of lists organized by `fieldName` . Useful 
for creating a map that groups SObjects by an attribute.

#### Signature
```apex
public Map<Object,List<SObject>> listBy(String fieldName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| fieldName | String | `String` API name of field by which we want to build a map of lists |

#### Return Type
**Map&lt;Object,List&lt;SObject&gt;&gt;**

Map&lt;Object, List&lt;SObject&gt;&gt; Map of Lists of SObjects from our collection, where the map keys,[object Object],are fieldName values and map values are lists of all matching elements from our collection

---

### `mapBy(fieldName)`

Build a map of SObjects by `fieldName` . Useful for creating a map of 
SObjects by a single attribute. ASSUMPTION is that `fieldName` is unique across the 
collection, otherwise the last element in the collection will be the only one added to the return map

#### Signature
```apex
public Map<Object,SObject> mapBy(String fieldName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| fieldName | String | `String` API name of field by which we map records |

#### Return Type
**Map&lt;Object,SObject&gt;**

Map&lt;Object, SObject&gt; Map of SObject records keyed off fieldName.

---

### `values()`

Convenience method to return a list of the SObjects 
in the catalog

#### Signature
```apex
public List<SObject> values()
```

#### Return Type
**List&lt;SObject&gt;**

List&lt;SObject&gt; List of Sobject records in our collection