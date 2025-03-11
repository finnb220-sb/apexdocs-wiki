# Reference Guide

## Batch Framework

### [BatchJobBase](batch-framework/BatchJobBase.md)

Provides common variables, methods and handling for all Batch Jobs. 
Subclasses must add following to class declaration even though the implementation is provided in this class 
 `implements Database.Batchable<sObject>, Schedulable` 
Subclasses must provide implementation for these abstract methods 
 `global String getJobName()` - for logging purposes - return the name of Job (ie Account Batch) 
 `global String getQueryString()` - return a string with the query to be executed (no dynamic variables) 
 `global String getEmailGroupName()` - return the name of the Group that specifies users who should receive emails 
 `global void execute(List<SObject> scope)` - Actually perform processing on scope 
 `global void handleException(Exception exc)` - handle exception

### [BatchJobBaseMock](batch-framework/BatchJobBaseMock.md)

Name: BatchJobBaseMock

### [BatchJobBaseTest](batch-framework/BatchJobBaseTest.md)

Name: BatchJobBaseTest

### [BatchJobConstants](batch-framework/BatchJobConstants.md)

Name: BatchJobConstants

### [BatchJobSchedulingMgr](batch-framework/BatchJobSchedulingMgr.md)

Name: BatchJobSchedulingMgr

### [BatchJobSchedulingMgrTest](batch-framework/BatchJobSchedulingMgrTest.md)

Name: BatchJobSchedulingMgrTest

## Field Mapping Utility

### [FieldMappingsUtil](field-mapping-utility/FieldMappingsUtil.md)

Created by: DC Solutions 
Created on: 2019-11-06 
 
Description: Utility class to parse out and use Field Mapping metadata to copy fields from 
one object (source) to another (target)

### [FieldMappingsUtilTest](field-mapping-utility/FieldMappingsUtilTest.md)

Created by DC Solutions on 2019-11-06. 
Description: Unit test for FieldMappingsUtil class

## SObject Collection Utility

### [SObjectCatalog](sobject-collection-utility/SObjectCatalog.md)

Collection-like utility class with convenience methods 
for commonly used SObject patterns

### [SObjectCatalogTest](sobject-collection-utility/SObjectCatalogTest.md)

Apex Unit Test for Collection-like utility class