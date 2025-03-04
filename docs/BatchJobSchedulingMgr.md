# BatchJobSchedulingMgr Class

Name: BatchJobSchedulingMgr

**Author** Brenda Finn

**Date** 11/14/21

**See** BMAccountSuspendLicenseBatch.cls

**See** BatchJobSchedulingMgrTest.cls for unit tests

**See** Do_Not_Run_Automations_Day__mdt custom metadata

## Fields
### `testConfigs`

`TESTVISIBLE`

#### Signature
```apex
private static testConfigs
```

#### Type
List&lt;Do_Not_Run_Automations_Day__mdt&gt;

---

### `testDate`

`TESTVISIBLE`

#### Signature
```apex
private static testDate
```

#### Type
Date

---

### `testBatchJobConfigs`

`TESTVISIBLE`

#### Signature
```apex
private static testBatchJobConfigs
```

#### Type
List&lt;Batch_Job_Config__mdt&gt;

---

### `defaultAutomationType`

#### Signature
```apex
public static defaultAutomationType
```

#### Type
String

---

### `batchJobConfigs`

#### Signature
```apex
private batchJobConfigs
```

#### Type
Map&lt;String,Batch_Job_Config__mdt&gt;

---

### `configs`

#### Signature
```apex
private configs
```

#### Type
Map&lt;String,List&lt;Do_Not_Run_Automations_Day__mdt&gt;&gt;

---

### `singleton`

#### Signature
```apex
private static singleton
```

#### Type
[BatchJobSchedulingMgr](BatchJobSchedulingMgr.md)

## Constructors
### `BatchJobSchedulingMgr()`

Private constructor - singleton class

#### Signature
```apex
private BatchJobSchedulingMgr()
```

## Methods
### `instance()`

Return the singleton instance of this class.

#### Signature
```apex
public static BatchJobSchedulingMgr instance()
```

#### Return Type
**[BatchJobSchedulingMgr](BatchJobSchedulingMgr.md)**

Instance to use for determining if job should be run today

---

### `startJobs()`

For all currently active Batch Job Config metadata records, start the 
batch job on the specified schedule

#### Signature
```apex
public void startJobs()
```

#### Return Type
**void**

---

### `manualProcess(batchJobConfigName, recordIds)`

Process the given records with the the batch job with configuration specified in batchJobConfigName 
without running a Batch but rather just directly processing the records by the worker/service class

#### Signature
```apex
public void manualProcess(String batchJobConfigName, Set<Id> recordIds)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| batchJobConfigName | String | Developer Name for a Batch_Job_Config metadata record containing 
configuration details for job to be scheduled/started. |
| recordIds | Set&lt;Id&gt; | Set of record ids to process - further filters records being processed 
to allow for controlling data set during testing. |

#### Return Type
**void**

---

### `startJob(batchJobConfigName, blnSingleRun)`

Start the batch job with configuration specified in batchJobConfigName

#### Signature
```apex
public void startJob(String batchJobConfigName, Boolean blnSingleRun)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| batchJobConfigName | String | Developer Name for a Batch_Job_Config metadata record containing 
configuration details for job to be scheduled/started. |
| blnSingleRun | Boolean | if true, kickoff a single one-off batch job run, otherwise schedule it |

#### Return Type
**void**

---

### `doRunAutomation()`

Returns true or false to indicate if the default automation type provided 
should be run today based on the currently configured metadata records

#### Signature
```apex
public Boolean doRunAutomation()
```

#### Return Type
**Boolean**

true if default automation is defined and should run today, false otherwise,[object Object],  including if no default automation is provided

---

### `doRunAutomation(automationType)`

Returns true or false to indicate if the automation type provided should be run 
today based on the currently configured metadata records

#### Signature
```apex
public Boolean doRunAutomation(String automationType)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| automationType | String | type of automation - one of the P/L values from metadata type definition. 
Right now, only Suspension jobs are being managed |

#### Return Type
**Boolean**

true if automation should run, false otherwise