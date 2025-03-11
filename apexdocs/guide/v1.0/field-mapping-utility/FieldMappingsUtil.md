# FieldMappingsUtil Class

`APIVERSION: 62`
`STATUS: ACTIVE`

Created by: DC Solutions 
Created on: 2019-11-06 
 
Description: Utility class to parse out and use Field Mapping metadata to copy fields from 
one object (source) to another (target)

**Group** Field Mapping Utility

**See** FieldMapping custom metadata type

## Fields
### `mappingsByTargetObj`

#### Signature
```apex
public mappingsByTargetObj
```

#### Type
Map&lt;String,Map&lt;String,Field_Mapping__mdt&gt;&gt;

---

### `objectAPIName`

#### Signature
```apex
private objectAPIName
```

#### Type
String

---

### `testMappings`

`TESTVISIBLE`

#### Signature
```apex
private static testMappings
```

#### Type
List&lt;Field_Mapping__mdt&gt;

## Properties
### `globalDescribe`

Return schema information for all objects in org

#### Signature
```apex
public static globalDescribe
```

#### Type
Map&lt;String,Schema.sObjectType&gt;

## Constructors
### `FieldMappingsUtil(processName)`

#### Signature
```apex
public FieldMappingsUtil(String processName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| processName | String |  |

## Methods
### `buildSoqlQuery(targetObjectName, blnSourceFields)`

Build and return a SOQL query from configured field names for our process. targetObjectName 
indicates the target object for which mappings are being returned.

#### Signature
```apex
public String buildSoqlQuery(String targetObjectName, Boolean blnSourceFields)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| targetObjectName | String | API Name of target object |
| blnSourceFields | Boolean | true if building soql for source object, false if building it for 
targetObjectName. |

#### Return Type
**String**

comma-separated list of fields to be retrieved suitable for a soql query

---

### `getSrcFields(targetObjectName)`

Return the set of source fields for the given target object mappings.

#### Signature
```apex
public Set<String> getSrcFields(String targetObjectName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| targetObjectName | String | API name of target object mappings |

#### Return Type
**Set&lt;String&gt;**

set of source fields for targetObjectName mappings

---

### `mapValues(toObject, fromObject)`

Map values from the source record (fromObject) to the target record (toObject) 
using our configured mappings

#### Signature
```apex
public void mapValues(SObject toObject, SObject fromObject)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| toObject | SObject | instance of configured source object |
| fromObject | SObject | instance of configured target object to copy values to |

#### Return Type
**void**

---

### `mapValues(mapping, toObject, fromObject)`

Internal method to map individual value for prop on fromObject to toField 
on toObject.

#### Signature
```apex
private void mapValues(Field_Mapping__mdt mapping, SObject toObject, SObject fromObject)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| mapping | Field_Mapping__mdt | Configuration details for the field currently being mapped from 
fromObject to toObject |
| toObject | SObject | instance of configured source object |
| fromObject | SObject | instance of configured target object to copy values to |

#### Return Type
**void**

---

### `isValidObjectName(objName)`

Return true or false to indicate if objName is a valid object

#### Signature
```apex
public static boolean isValidObjectName(String objName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| objName | String | API Name of object to verify |

#### Return Type
**boolean**

true if objName is a valid API Object Name

---

### `isValidField(objName, fieldName)`

Return true or false to indicate if fieldName is a valid field on object named objName

#### Signature
```apex
public static boolean isValidField(String objName, String fieldName)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| objName | String | API Name of object to verify |
| fieldName | String | API Name of field to check objName for validity |

#### Return Type
**boolean**

true if fieldName on objName is valid