# BatchJobBaseTest Class

`ISTEST`
`APIVERSION: 62`
`STATUS: ACTIVE`

Name: BatchJobBaseTest

**Group** Batch Framework

**Author** Brenda Finn

**Date** 2021-11-16

**See** [BatchJobBase](BatchJobBase.md)

**See** [BatchJobBaseTest](BatchJobBaseTest.md)

## Fields
### `TEST_ACCOUNT_NAME`

#### Signature
```apex
private static final TEST_ACCOUNT_NAME
```

#### Type
String

---

### `testConfig`

#### Signature
```apex
private static final testConfig
```

#### Type
Batch_Job_Config__mdt

## Methods
### `buildData()`

`TESTSETUP`

#### Signature
```apex
private static void buildData()
```

#### Return Type
**void**

---

### `testManual()`

`ISTEST`

#### Signature
```apex
private static void testManual()
```

#### Return Type
**void**

---

### `testHandleException()`

`ISTEST`

#### Signature
```apex
private static void testHandleException()
```

#### Return Type
**void**

---

### `testSetup()`

`ISTEST`

#### Signature
```apex
private static void testSetup()
```

#### Return Type
**void**

---

### `testBadQueryFilter()`

`ISTEST`

#### Signature
```apex
private static void testBadQueryFilter()
```

#### Return Type
**void**

---

### `manuallyFilterRecords()`

`ISTEST`

#### Signature
```apex
private static void manuallyFilterRecords()
```

#### Return Type
**void**