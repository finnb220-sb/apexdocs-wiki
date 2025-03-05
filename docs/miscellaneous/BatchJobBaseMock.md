# BatchJobBaseMock Class

`ISTEST`
`APIVERSION: 62`
`STATUS: ACTIVE`

Name: BatchJobBaseMock

**Author** brendafinn

**Date** 11/16/21

**See** [BatchJobBase](BatchJobBase.md)

**See** [BatchJobBaseTest](BatchJobBaseTest.md)

**Inheritance**

[BatchJobBase](BatchJobBase.md)

**Implements**

Database.Batchable&lt;SObject&gt;, 
Database.Stateful, 
Schedulable

## Fields
### `blnExecuteInvoked`

#### Signature
```apex
public static blnExecuteInvoked
```

#### Type
Boolean

---

### `blnThrowException`

`TESTVISIBLE`

#### Signature
```apex
private blnThrowException
```

#### Type
Boolean

---

### `blnReturnInvalidQuery`

`TESTVISIBLE`

#### Signature
```apex
private blnReturnInvalidQuery
```

#### Type
Boolean

---

### `numSuccesses`

*Inherited*

#### Signature
```apex
global numSuccesses
```

#### Type
Integer

---

### `errors`

*Inherited*

#### Signature
```apex
global errors
```

#### Type
List&lt;String&gt;

---

### `config`

*Inherited*

#### Signature
```apex
global config
```

#### Type
Batch_Job_Config__mdt

---

### `records`

*Inherited*

`TESTVISIBLE`

#### Signature
```apex
protected records
```

#### Type
List&lt;SObject&gt;

## Properties
### `numErrors`

*Inherited*

#### Signature
```apex
global numErrors
```

#### Type
Integer

## Methods
### `getJobName()`

#### Signature
```apex
global override String getJobName()
```

#### Return Type
**String**

---

### `getQueryString()`

#### Signature
```apex
global override String getQueryString()
```

#### Return Type
**String**

---

### `execute()`

#### Signature
```apex
global override void execute()
```

#### Return Type
**void**

---

### `getClassName()`

#### Signature
```apex
global override String getClassName()
```

#### Return Type
**String**

---

### `setConfig(ourConfig)`

*Inherited*

Set our configuration to details in ourConfig record

#### Signature
```apex
global void setConfig(Batch_Job_Config__mdt ourConfig)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| ourConfig | Batch_Job_Config__mdt | instance of Batch Job Config metadata containing configuration details 
such as batch size, schedule, query filters. |

#### Return Type
**void**

---

### `setup(cronSchedule)`

*Inherited*

Run this job using given cronSchedule

#### Signature
```apex
global void setup(String cronSchedule)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| cronSchedule | String | String representing schedule to run this batch job on |

#### Return Type
**void**

---

### `setup(batch, cronSchedule)`

*Inherited*

Setup the job specified (batch) to run on the schedule specified by the cronSchedule

#### Signature
```apex
global static void setup(BatchJobBase batch, String cronSchedule)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| batch | [BatchJobBase](BatchJobBase.md) | instance of job to run on cronSchedule |
| cronSchedule | String | String representing schedule to run job on |

#### Return Type
**void**

---

### `manual(jobName, batch)`

*Inherited*

Run the job at designated date and time

#### Signature
```apex
global static void manual(String jobName, BatchJobBase batch)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| jobName | String | - Unique name of job |
| batch | [BatchJobBase](BatchJobBase.md) | - Instance of a batch class to run now |

#### Return Type
**void**

---

### `start(bc)`

*Inherited*

BATCHABLE INTERFACE

#### Signature
```apex
global Database.QueryLocator start(Database.BatchableContext bc)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| bc | Database.BatchableContext |  |

#### Return Type
**Database.QueryLocator**

---

### `finish(bc)`

*Inherited*

Once all the records have been processed for this batch execution, perform any final processing. 
Right now, for this job, it involves preparing summary text of the job results, logging that message 
and sending out a status email with the summary text to interested parties. The recipients are defined by a Group.

#### Signature
```apex
global void finish(Database.BatchableContext bc)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| bc | Database.BatchableContext | - batch context |

#### Return Type
**void**

---

### `sendStatusEmail(messageBody)`

*Inherited*

Send the status email to members of a Group

#### Signature
```apex
protected void sendStatusEmail(String messageBody)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| messageBody | String | - the message body |

#### Return Type
**void**

---

### `markRecordAsSuccess(record)`

*Inherited*

END BATCHABLE INTERFACE

#### Signature
```apex
global virtual void markRecordAsSuccess(SObject record)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| record | SObject |  |

#### Return Type
**void**

---

### `markRecordAsError(recordInError, dbErrors)`

*Inherited*

For record that failed to process, add the error to the errors list and update the numErrors in the batch job

#### Signature
```apex
global virtual void markRecordAsError(SObject recordInError, List<Database.Error> dbErrors)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| recordInError | SObject | - SObject record that threw an error when processed in the batch |
| dbErrors | List&lt;Database.Error&gt; | - List of Database.Error |

#### Return Type
**void**

---

### `markRecordAsError(record, errorMsg)`

*Inherited*

For record that failed to process, write the error to the errors list and update the numErrors in the batch job

#### Signature
```apex
global virtual void markRecordAsError(SObject record, String errorMsg)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| record | SObject | - SObject record that threw an error when processed in the batch |
| errorMsg | String | - string that details the error for the failed record |

#### Return Type
**void**

---

### `manuallyFilterRecords(recordIds)`

*Inherited*

Manually filter the records further by only processing records with Ids in recordIds. 
The default version assumes the recordIds are of the same SObject being processed. If this is not the 
case, sub-classes should override this method.

#### Signature
```apex
global virtual List<SObject> manuallyFilterRecords(Set<Id> recordIds)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| recordIds | Set&lt;Id&gt; | set of Ids to limit processing set to |

#### Return Type
**List&lt;SObject&gt;**

list of records to process - for use in calling manuallyProcessRecords()

---

### `manuallyProcessRecords(records)`

*Inherited*

Provides a way to process a given set of records rather than executing batch query 
To get set of eligible records, use manuallyFilterRecords

#### Signature
```apex
global virtual void manuallyProcessRecords(List<SObject> records)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| records | List&lt;SObject&gt; | list of records to process manually |

#### Return Type
**void**

---

### `handleException(exc)`

*Inherited*

Handle exception thrown during processing. For now - this is in sub-classes but 
there may be some core/base functionality we can pull out to this class

#### Signature
```apex
global virtual void handleException(Exception exc)
```

#### Parameters
| Name | Type | Description |
|------|------|-------------|
| exc | Exception | - generic exception |

#### Return Type
**void**

---

### `finish()`

*Inherited*

If there is additional processing to be done after the email is sent, it can be done in this method. 
This is called by the Batchable finish() method. Provide a no-op version

#### Signature
```apex
global virtual void finish()
```

#### Return Type
**void**

---

### `getEmailGroupName()`

*Inherited*

Return the name of the Group whose members receive status email. Defaults to Email Groupis sent, it can be done in this method.

#### Signature
```apex
global virtual String getEmailGroupName()
```

#### Return Type
**String**

string - name of the email Group message should be sent to

---

### `doSendFinishEmail()`

*Inherited*

If true, we send a status email on finish, if false, we do not. Defaults to true

#### Signature
```apex
global virtual Boolean doSendFinishEmail()
```

#### Return Type
**Boolean**

boolean

## Classes
### BatchTestException Class