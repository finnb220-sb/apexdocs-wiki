# Reference Guide

## Miscellaneous

### [BatchJobBase](miscellaneous/BatchJobBase.md)

Provides common variables, methods and handling for all Batch Jobs. 
Subclasses must add following to class declaration even though the implementation is provided in this class 
implements Database.Batchable&lt;sObject&gt;, Schedulable 
Subclasses must provide implementation for these abstract methods 
global String getJobName() - for logging purposes - return the name of Job (ie Account Batch) 
global String getQueryString() - return a string with the query to be executed (no dynamic variables) 
global String getEmailGroupName() - return the name of the Group that specifies users who should receive emails 
global void execute(List&lt;SObject&gt; scope) - Actually perform processing on scope 
global void handleException(Exception exc) - handle exception

### [BatchJobBaseMock](miscellaneous/BatchJobBaseMock.md)

Name: BatchJobBaseMock

### [BatchJobBaseTest](miscellaneous/BatchJobBaseTest.md)

Name: BatchJobBaseTest

### [BatchJobConstants](miscellaneous/BatchJobConstants.md)

Name: BatchJobConstants

### [BatchJobSchedulingMgr](miscellaneous/BatchJobSchedulingMgr.md)

Name: BatchJobSchedulingMgr

### [BatchJobSchedulingMgrTest](miscellaneous/BatchJobSchedulingMgrTest.md)

Name: BatchJobSchedulingMgrTest

### [FieldMappingsUtil](miscellaneous/FieldMappingsUtil.md)

Created by: DC Solutions 
Created on: 2019-11-06 
 
Description: Utility class to parse out and use Field Mapping metadata to copy fields from 
one object (source) to another (target)

### [FieldMappingsUtilTest](miscellaneous/FieldMappingsUtilTest.md)

Created by DC Solutions on 2019-11-06. 
Description: Unit test for FieldMappingsUtil class

### [SObjectCatalog](miscellaneous/SObjectCatalog.md)

SObjectCatalog 
 
Description: Collection-like utility class with convenience methods 
for commonly used SObject patterns

### [SObjectCatalogTest](miscellaneous/SObjectCatalogTest.md)