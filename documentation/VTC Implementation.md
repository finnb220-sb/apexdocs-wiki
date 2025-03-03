# VTC Implementation Guide

__Table of Contents__
- [Changes to a HDR component & its controller](#changes-to-a-hdr-component--its-controller)
	- [The Apex Controller 🎮](#the-apex-controller)
	- [The LWC Component 🧩](#the-lwc-component)
- [Load More Functionality](#load-more-functionality)
- [Using Logger](#using-logger)
- [Base HDR Frame Documentation](#base-hdr-frame-documentation)
	- [Attributes ⚙️](#attributes)
	- [Custom Events 🎟️](#custom-events)

<br><br>

# Changes to a HDR component & its controller

<br>

This [Pull Request](https://github.com/department-of-veterans-affairs/va-teams/pull/3498) contains more side-by-side examples

<br>

## The Apex Controller

1. Update the main header with a mention to the `VCR_HealthDataRepo` OR Data Repo class you are using
``` java
@see `VCR_HealthDataRepo` to see the shape of the Health Data Config returned to LWC
```

<br>

2. Instantiate the Health Data Repo OR the specific repo for your component data type. This can be found easily in the Apex Class `VCC_WorkstreamSettingsController`
``` java
/**
 * @description instantiates a <YOUR_COMPONENT_NAME_HERE> health data repo
 */
@TestVisible
private static VCR_HealthDataRepo healthDataRepo {
	get {
		if (healthDataRepo == null) {
			healthDataRepo = new VCR_HealthDataRepo('<YOUR_COMPONENT_NAME_HERE>');
		}
		return healthDataRepo;
	}
	set;
}
```

<br>

3. Create the method to be used by the LWC to grab specified data in the Health Data shape
``` java
/**
 * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
 * @param icn - ICN to query org against
 * @return Returns patient birthyear, and workstream settings
 */
@AuraEnabled(Cacheable=true)
public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
	healthDataRepo.setPatientByICN(icn);
	return healthDataRepo.fetchHealthDataConfig();
}
```

<br>

4. Updates to the Controller Test must be made. Here are some approaches to testing the methods from the `VCC_LabControllerTest.cls`
``` java
// Use during your initialization test
Assert.isTrue(VCC_LabController.healthDataRepo != null, 'Expected healthDataRepo to be initialized');
```

``` java
@IsTest
private static void unitFetchHealthDataConfig() {
	VCC_WorkstreamSettingsController.VCC_Model workstreamSettingsModel = new VCC_WorkstreamSettingsController.VCC_Model(
		'labs',
		Datetime.now(),
		Datetime.now(),
		12
	);

	VCR_HealthDataRepo.Model healthDataRepoModel = new VCR_HealthDataRepo.Model(
		'1999',
		workstreamSettingsModel,
		'2024',
		'2022'
	);
	VCC_LabController.healthDataRepo = createHealthDataRepo('labs', healthDataRepoModel);
	User vaVetUser = createTestUser();

	Test.startTest();
	System.runAs(vaVetUser) {
		VCR_HealthDataRepo.Model healthDataConfig = (VCR_HealthDataRepo.Model) VCC_LabController.fetchHealthDataConfig(
			FAKE_ICN
		);
		Assert.isTrue(healthDataConfig != null, 'Expected valid non-null model to be returned.');
	}
	Test.stopTest();
}
```

``` java
private static VCR_HealthDataRepo createHealthDataRepo(
	String healthDataType,
	VCR_HealthDataRepo.Model returnValue
) {
	return (VCR_HealthDataRepo) new VATEST_StubBuilder(VCR_HealthDataRepo.class)
		.mockingMethodCall('fetchHealthDataConfig')
		.withParameterTypes()
		.returning(returnValue)
		.mockingMethodCall('setPatientByICN')
		.withParameterTypes(String.class)
		.withParameterValues(FAKE_ICN)
		.returning()
		.defineStub();
}
```

[^ BACK TO TOP](#vtc-implementation-guide)

<br><br>

## The LWC Component

1. In the `componentDependencies.js` file of your LWC, add the following object that will be used to dynamically render this information in the HDR Frame. Be sure to match the showAddToNote with existing functionality (true or false). Make sure to add this to the `exports`
``` js
const actionsComponent = {
    name: 'c/vccHdrDatatableActions',
    props: {
        showAddToNote: false,
        options: []
    }
};
```

<br>

2. In the HTML file, update the HDR frame's properties to include the following new properties. More information on them can be found below
``` html
<c-base-h-d-r-frame
	lwc:ref="hdrFrame"
	actions-component={actionsComponent}
	onloadmore={handleLoadMore}
	onreloadhealthdata={handleReloadHealthData}
```

<br>

The remainder of these changes will be done in the JS file

<br>

3. Import the new method from your Apex Controller
``` js
import getHealthDataConfig from '@salesforce/apex/VCC_<YOUR_COMPONENT_NAME_HERE>Controller.fetchHealthDataConfig';
```

<br>

4. Ensure the import of your `componentDependencies.js` exists. It should look like this
``` js
import { componentDependencies as service } from './componentDependencies.js';
```

<br>

5. Set up your variables
``` js
actionsComponent = service.actionsComponent; // grabs the actionsComponent object from the component dependencies
patientBirthYear; // holds patient year to dynamically create the load more options until that year
calloutsPerformed = []; // batches of data returned via wire calls
```

<br>

6. Update the `wiredGetIcn` method to do only that task
``` js
/**
 * @description Gets ICN number for patient from recordId
 * @param string recordId
 */
@wire(getICN, { recordId: '$recordId' })
wiredGetIcn({ data, error }) {
	if (data) {
		this.icn = data;
	}
	if (error) {
		this.logger(error);
	}
}
```

<br>

7. Add the `wiredHDRConfig` method to get the config data
``` js
/**
 * @description Gets patient birth year, and workstream settings, the data required to perform calls to VTC
 * @param string icn to query DB against
 */
@wire(getHealthDataConfig, { icn: '$icn' })
wiredHDRConfig({ data, error }) {
	if (data) {
		this.patientBirthYear = data.patientBirthYear;
        service.setLoadMoreOptions.call(this, data);

		this.vtcArgs = {
			icn: this.icn,
			startDate: new Date(data.workstreamSettings.startDate).toISOString().split('T')[0], // ex: "2023-12-17"
			stopDate: new Date(data.workstreamSettings.endDate).toISOString().split('T')[0]  // ex: "2024-06-17"
		};
	}

	if (error) {
		this.logger(error);
	}
}
```

<br>

8. Update the "Get the HDR Data" method to now use the `calloutsPerformed` approach allowing for the reload
``` js
/**
 * @description Get Visits for the patient via wire after icn and workstream settings are retrieved
 * @param data records returned via wired VTC call
 * @param error
 */
@wire(<YOUR_DATA_FETCH_VTC_CALL>, { args: '$vtcArgs' })
wiredCallout(value) {
    const { data, error } = value;
    if (data) {
        service.handleCalloutSuccess.call(this, data, this.vtcArgs);
    }

    if (error) {
        this.logger(error);
        if (error.body?.exceptionType?.includes('System.LimitException')) {
            service.handleCalloutError.call(this, error, this.vtcArgs);
        }
    }

    this.isShowSpinner = false;
}
```

<br>

9. Add the method to handle the `onloadmore` custom event

``` js
/**
 * @description Loads more data into this component, the start date of the previous request becomes the current stop date and the start date is set from the year returned in the event param
 * @param {`object`} event Expecting a year e.g. '2004'
 */
handleLoadMore(event) {
	service.handleLoadMore.call(this, event);
}
```

<br>

10. Add the method to handle the `onreloadhealthdata` custom event

``` js
/**
 * @description invoke refreshApex on batches returned by wired callouts
 */
handleReloadHealthData() {
	service.refreshDataInBatchesAsync.call(this);
}
```

<br>

11. Add the method to call when the max limit is reached (May not apply to all components)

``` js
< - this will be replaced with the LOAD MORE FUNCTIONALITY step 1 ->
```

<br>

12. Add the method to toggle the loading property on the actions component

``` js
/**
 * @description invokes the setLoading method on the dynamically generated actions component
 * @param loading state of loading on actions component
 */
setLoading(loading) {
	this.refs?.hdrFrame?.invokePublicMethodsInActionsComponent([{ methodName: 'setLoading', args: [loading] }]);
}
```
[^ BACK TO TOP](#vtc-implementation-guide)

<br><br>

# Load More Functionality

1. replace the previous `handleMaxLimitReached` method with the following
``` js
/**
 * @description breaks down a large request into a batch of smaller requests. The requests are run asynchronously
 */
async handleMaxLimitReached(wiredCall) {
    const dateFieldForLimit = '<DATE_FIELD_YOUR_DATA_IS_QUERIED_ON>'; // the date field your data is queried on

    this.setLoading(true);

    const maxHitDateRangeRequest = wiredCall.cachedResult.sites
        .filter((site) => site.records.length === wiredCall.args.max)
        .flatMap((site) => site.records)
        .sort((a, b) => new Date(b[dateFieldForLimit]) - new Date(a[dateFieldForLimit]))
        .reduce(
            (acc, record, index, arr) => {
                if (index === 0) {
                    acc.stopDate = record[dateFieldForLimit].split('T')[0];
                }
                if (index === arr.length - 1) {
                    acc.startDate = record[dateFieldForLimit].split('T')[0];
                }
                return acc;
            },
            { ...this.vtcArgs, max: 1000 }
        );

    const batchOfNewRequests = service.createRequests(maxHitDateRangeRequest);
    await this.executeAsyncCalls(batchOfNewRequests);
    this.setLoading(false);
}
```

<br>

2. confirm the callout method matches the following
``` js
/**
 * @description Get data for the patient via wire after icn and workstream settings are retrieved
 * @param data records returned via wired VTC call
 * @param error
 */
@wire(<YOUR_DATA_FETCH_VTC_CALL>, { args: '$vtcArgs' })
wiredCallout(value) {
    const { data, error } = value;
    if (data) {
        service.handleCalloutSuccess.call(this, data, this.vtcArgs);
    }

    if (error) {
        this.logger(error);
        if (error.body?.exceptionType?.includes('System.LimitException')) {
            service.handleCalloutError.call(this, error, this.vtcArgs);
        }
    }

    this.isShowSpinner = false;
}
```

<br>

3. add the `executeAsyncCalls` method
``` js
/**
 * @description this method is called inside the handleMaxLimitReached as part of the batch of smaller requests
 */
async executeAsyncCalls(requests) {
    const asyncCalls = await Promise.allSettled(
        requests.map((request) =>
            <YOUR_DATA_FETCH_VTC_CALL>({ args: request })
                .then((result) => {
                    return {
                        response: result,
                        request: request
                    };
                })
                .catch((error) => {
                    return {
                        hasError: true,
                        response: error,
                        request: request
                    };
                })
        )
    );

    asyncCalls.forEach((result) => {
        if (result.status === 'fulfilled') {
            if (result.value.hasError) {
                service.handleCalloutError.call(this, result.value.response, result.value.request);
            } else {
                service.handleCalloutSuccess.call(this, result.value.response, result.value.request);
            }
        } else {
            service.handleCalloutError.call(this, result.value.response, result.request);
        }
    });
}
```
[^ BACK TO TOP](#vtc-implementation-guide)

<br><br>

# Using Logger

1. In the HTML file, make sure to add this to the top on line 2
``` html
<c-logger></c-logger>
```

<br>

2. In the JS file, add this method at the bottom. Use in place of console logs/errors ex: `this.logger(error);`
``` js
/**
 * @description Fetches the dependent custom nebula logger LWC and that will be used for logging
 * @param {*} incomingError - object/string that represents the error that has occured
 */
logger(incomingError) {
	const logger = this.template.querySelector('c-logger');
	if (!logger) {
		return;
	}
	logger.error(JSON.stringify(incomingError));
	logger.saveLog();
}
```
[^ BACK TO TOP](#vtc-implementation-guide)

<br><br>

# Base HDR Frame Documentation

<br><br>

## Attributes

| Name | Type | Description |
|------|------|-------------|
| `lwc:ref` | String | used to easily reference & access this component in the JavaScript <br> [Query DOM Elements with Refs](https://help.salesforce.com/s/articleView?id=release-notes.rn_lwc_templaterefs.htm&release=242&type=5)
| `actions-components` | Object | Information that will be sent into the dynamically rendered component in the HDR Frame <br><br> ex: `{ name: 'c/vccHdrDatatableActions', props: { showAddToNote: true, options: [] } }`
| `date-range-field` | String | Which "fieldName" from the columns array in the componentDependency.js will be used as the Date Range to default sort by <br><br> ex: `"onsetDate"` |
| `settings` | Object | Defines the Title and Icon for the Component. Happens on the frame level to ensure consistent UI <br><br> ex: `{ title: 'Problems', icon: 'standard:document_reference'}` |
| `list` | Array |  This is the HDR Data that comes back from the callout executed by this component |
| `columns` | Array |  The columns to be displayed in the data table |
| `size` | flexipageRegionWidth | The size of the component on the flexipage |
| `current-object` | String | Conditionally render elements based on the Salesforce Object <br><br> ex: `"VCC_Progress_Note__c"` |
| `show-add-to-note` | Boolean | Decide whether or not the Add To Note button is shown |
| `hdr-message` <br> (Optional value) | String | Used for base error message component that will display as a "note" variant |

[^ BACK TO TOP](#vtc-implementation-guide)

<br><br>

## Custom Events

| Name | Fires... | Returns... |
|------|----------|------------|
| `onloadmore` 		| when a year is selected from the combobox, the event bubbles up from the `vccHDRDatatableActions` component | an Object with the value inside of the "detail" |
| `onreloadhealthdata` | when the "Reload" button is pressed | - |
| `onrowselected` 	| when a row is selected using the checkbox on the table | an Object with row information inside of the "detail" |
| `onaddtonote` 	| when the Add to Note button is clicked inside the HDR frame  | - |

[^ BACK TO TOP](#vtc-implementation-guide)
