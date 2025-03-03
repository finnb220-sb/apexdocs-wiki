# Documentation of Apex & JavaScript

[Apex Examples](#apex-class-header) &nbsp; | &nbsp; [JavaScript Examples](#js-file-header)

<br>
<br><img src="./images/apex_header.png" alt="Apex title banner"><br>

## Apex Class Header

### ✅ Positive Example

``` java
/**
 * @description  Helper class used by the VATEST_UserFactory and test classes 
 *   to instantiate a user with the correct Profile, Permission 
 *   Sets,and other attributes pursuant to given Persona and test scenario.
 *   APIs are built in fluent-style to make creation simple & streamlined.  
 *   See example below.
 *
 * @author        Booz Allen Hamilton
 * @example       
 * VATEST_UserBuilder nurseJackieBuilder = new VATEST_UserBuilder()
 *
 * User nurseJackieUser = 
 *    nurseJackieBuilder.withPermissionSet('BasicNurseAccess')
 *                      .withProfile('Salesforce User')
 *                      .withStandardData()
 *                      .build();
 *
 * VATEST_UserBuilder nurseMaryBuilder = new VATEST_UserBuilder()
 *
 * User nurseMaryBuilder = 
 *    nurseMaryBuilder.withPermissionSet('BasicNurseAccess')
 *                    .withPermissionSet('ExtendedNurseAccess')
 *                    .withProfile('Salesforce User')
 *                    .withStandardData()
 *                    .build();
 *
 * @see VATEST_UserFactory
 * @see VATEST_UserPersonaEnum
 **/
public class VATEST_UserBuilder {…}
```

### 🛑 Negative Example

``` java
/**
 * @description VCR_OpportunityRepo
 * @author            
 **/
public class VCR_OpportunityRepo {…}
```

<br><br>

## Apex Method Header

### ✅ Positive Example

``` java
/**
 * @description For each Territory member, this method calculates their total 
 *     utilization percentage and inserts a metric record with that data, for 
 *     future reporting.
 * @param territoryMembers `List<ServiceTerritoryMember>` List of providers 
 *     we need 
 *     to run the calculation on.
 * @param range `VCC_DateRange` The Date range we are calculating on.
 **/
public void calculateUtilizationForTerritoryMembersInRange(
    List<ServiceTerritoryMember> territoryMembers,
    VCC_DateRange range
)  {…}
```

### 🛑 Negative Example

``` java
/**
 * @description Get opportunities
 * @param id
 * @return List<Opportunity>
 **/
public List<Opportunity> fetchRecordsById(Id id)  {…}
```

<br><br>

## Apex Class with Justification Header

### ✅ Positive Example

``` java
/**
 * @description VCR_AppointmentRepo is a repository class used to handle all 
 *       DML statements for the VCC_Appointment object.
 * @author Booz Allen Hamilton
 * @justification getQueryLocator uses SYSTEM_MODE to query 
 *       VCC_Appointment__c records for the scheduled batch class.
 * The user that schedules the job will be System Admin but may not have all 
 *       necessary object and field access. Using a query run in SYSTEM_MODE   
 *       solves this issue for the batch class to run successfully, without 
 *       having to grant additional permissions to the user that would not be 
 *       needed beyond batch class.
 * @see VTC_BaseRepo
 * @see VCR_AppointmentRepoTest
 **/
public inherited sharing class VCR_AppointmentRepo extends VTC_BaseRepo {}
```

### 🛑 Negative Example

``` java
/**
 * @description VCR_AppointmentRepo is a repository class
 * @justification getQueryLocator uses SYSTEM_MODE to query 
 *       VCC_Appointment__c records for the scheduled batch class.
 **/
public inherited sharing class VCR_AppointmentRepo extends VTC_BaseRepo {}
```

<br><br>
<br><br>

<br><img src="./images/js_header.png" alt="JavaScript title banner"><br>
## JS File Header

### ✅ Positive Example

``` js
/**
 * @description vccScheduleAppointment acts as the confirmation screen, and  
 * the success screen when scheduling an appointment. It is responsible for 
 * showing the User their Time Slot selections, Clinic, and patient 
 * eligibility data, as well as calling the apex method for creating the 
 * appointment.
 *
 * @author Booz Allen Hamilton
 * @see VCC_ScheduleAppointmentController
 **/
export default class vccScheduleAppointment extends LightningElement {…}
```

### 🛑 Negative Example

``` js
/**
 * @description vccScheduleAppointment
 * @author            
 **/
export default class vccScheduleAppointment extends LightningElement {…}
```

<br><br>

## JS Method Header

### ✅ Positive Example

``` js
    /**
     * @description This function contains the logic needed to decide which set of options 
     *  and labels are needed for displaying Appointment Types.
     * 
     * @param apptRequestType String containing type of Appointment Request to check
     * @returns Boolean Returns true if the Appointment Request Type is APPT or RTC, 
     *     false if the Appointment Request Type is not APPT or RTC
     **/
    checkAppointmentRequestType(apptRequestType) {…}

    /**
     * @description connectedCallback for vccScheduleAppointment. It subscribes to the 
     * vccOnPersonAccountRead message channel, sets initial properties to display in the 
     * html,  and sorts the timeslots by date time
     *
     **/
    connectedCallback() {…}

    /**
     * @description The start time of the earliest Time Slot selected
     * @return Returns the current value of records property
     **/
    get records() {…}

    /**
     * @description setter for the records attribute. When the parent component retrieves 
     * new data and updates the records property, this setter will inject the displayField 
     * property and the keyField property into the list of records that will be used to display in 
     * the vccSearch lwc. They will be instantiated with the value of the displayField and 
     * keyField properties that were passed in from the parent component. This is the trick 
     * that allows this lwc to be used with any data source.
     *
     * @param value New data for records attribute
     *
     * @see keyField     
     * @see displayField
     **/
    @api
    set records(value) {…}
```

### 🛑 Negative Example

``` js
connectedCallback() {} // A lifecycle method with no documentation
get startTime() {…} // A property with no documentation
```


<br><br>

<br><br>

Have any suggestions or additions? Submit a PR with them please.

<br><br>
