// This script demonstrates how to create VAID records using the MPI-3 Framework, for this to work, the MPI-3 package must be installed
// with all custom md records created. This logic needs to replace the logic that currently creates VA Identity records in the AddPatient Feature


// request
String body = JSON.serialize(new Map<String, String> {
    'ssn' => '762066618',
    'lastName' => 'Radish',
    'firstName' => 'Morgan',
    'userId' => 'VACH CRM'
});

// getting search results using mpi 3 framework, the second param informs the framework to use the "vahc" business unit custom md records
MPIDynamicPersonSearchController.ResponseWrap res = MPIDynamicPersonSearchController.mpiPatientSearch(body, 'VAHC');


// This was how the documentation recommend we retrieve the results, these could probably be objects
List<Object> searchResults  = (List<Object>) JSON.deserializeUntyped(res.allData);

Map<String, Object> resultsMap = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(searchResults[0]));

// don't remember what below was for
resultsMap.remove('correlatedIds');
resultsMap.remove('relationships');
resultsMap.put('dob', '1974-06-16');

// unfortunate, but this has to be reserialized. This could probably be an object
string serializedMap = json.serialize(resultsMap);

// see the VAHC_MPI_VAID_Map static resource, this is how the "framework" maps the VA Identity schema to the response from MPI
// String mpiSalesforceInsertFieldMap = '{"stateOfBirth":"Place_of_Birth_State__c","mothersMaidenName":"Mother_s_Maiden_Name__c","streetAddress3":"MPI_Primary_Address_Street_Line_3__c","birthState":"Place_of_Birth_State__c","lastName":"Last_Name__c","birthCity":"Place_of_Birth_City__c","middleName":"Middle_Name__c","icn":"ICN__c","dod":"Date_of_Death__c","phoneNumber":"MPI_Phone_Number__c","country":"MPI_Primary_Address_Country__c","state":"MPI_Primary_Address_State__c","firstName":"First_Name__c","streetAddress2":"MPI_Primary_Address_Street_Line_2__c","dob":"Date_of_Birth__c","personType":"MPI_Person_Type__c","gender":"Gender__c","ssn":"SSN__c","streetAddress":"MPI_Primary_Address_Street_Line_1__c","cityOfBirth":"Place_of_Birth_City__c","prefixName":"Prefix__c","suffixName":"Suffix__c","postalCode":"MPI_Primary_Address_Postal_Code__c","phone":"Phone_Number__c","city":"MPI_Primary_Address_City__c","streetAddressLine":"MPI_Primary_Address_Street_Line_1__c"}';
String mpiSalesforceInsertFieldMap = new VCC_StaticResourceSelector().selectByName('VAHC_MPI_VAID_Map')[0].Body.toString();

system.debug('heh ' + mpiSalesforceInsertFieldMap);

// This does the actual DML
sObject vaidRec = MPIDynamicPersonSearchController.saveForm('VA_Identity__c',mpiSalesforceInsertFieldMap, serializedMap , 'vahc', UserInfo.getUserName());