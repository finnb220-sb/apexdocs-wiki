# SObjectCatalog Class

`APIVERSION: 46`
`STATUS: ACTIVE`

SObjectCatalog 
 
Description: Collection-like utility class with convenience methods 
for commonly used SObject patterns

**Author** Dupont Circle Solutions (Tim Phang)

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

#### Signature
```apex
public SObjectCatalog(List<SObject> sObjects)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| sObjects | List&lt;SObject&gt; |  |

## Methods
### `get(objectId)`

Return the SObject with Id &#x3D; objectId. Returns 
NULL if none found.

#### Signature
```apex
public sObject get(Id objectId)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| objectId | Id |  |

#### Return Type
**sObject**

SObject

---

### `getBy(fieldName, value)`

Build a map of SObjects organized by _fieldName_ 
return the SObject that matches

#### Signature
```apex
public sObject getBy(String fieldName, Object value)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| fieldName | String |  |
| value | Object |  |

#### Return Type
**sObject**

SObject

---

### `keys()`

Return a set of IDs of all SObjects in the catalog

#### Signature
```apex
public Set<Id> keys()
```

#### Return Type
**Set&lt;Id&gt;**

Set&lt;Id&gt;

---

### `listBy(fieldName)`

Build a map of lists organized by fieldName. Useful 
for creating a map that groups SObjects by an attribute.

#### Signature
```apex
public Map<Object,List<SObject>> listBy(String fieldName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| fieldName | String |  |

#### Return Type
**Map&lt;Object,List&lt;SObject&gt;&gt;**

Map&lt;Object, List&lt;SObject&gt;&gt;

---

### `mapBy(fieldName)`

Build a map of SObjects by fieldName. Useful for creating 
a map of SObjects by a single attribute.

#### Signature
```apex
public Map<Object,SObject> mapBy(String fieldName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| fieldName | String |  |

#### Return Type
**Map&lt;Object,SObject&gt;**

Map&lt;Object, SObject&gt;

---

### `values()`

Conveience method to return a list of the SObjects 
in the catalog

#### Signature
```apex
public List<SObject> values()
```

#### Return Type
**List&lt;SObject&gt;**

List&lt;SObject&gt;