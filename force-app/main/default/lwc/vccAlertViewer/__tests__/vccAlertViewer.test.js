/**
 * @description Jest test file for vccAlertViewer web component.
 * @author Booz Allen Hamilton
 */
import { createElement } from 'lwc';
import vccAlertViewer from 'c/vccAlertViewer';
import { refreshAlerts } from '@salesforce/apex/VCC_ViewAlerts.refreshAlerts';

const mockResponseData = require('./data/responseData.json');
const mockAuthExceptionData = require('./data/authExceptionData.json');
mockAuthExceptionData.body.message = JSON.stringify(mockAuthExceptionData.body.message);

jest.mock(
    '@salesforce/apex/VCC_ViewAlerts.refreshAlerts',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

describe('c-vcc-alert-viewer', () => {
    afterEach(() => {
        /**
         * The jsdom instance is shared across test cases in a single file,
         * so reset the DOM to its original state after each test.
         */
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    /**
     * @description Checking that the component renders correctly.
     */
    it('should render correctly', () => {
        // Create the element and append it to the DOM
        const element = createElement('c-vcc-alert-viewer', { is: vccAlertViewer });
        document.body.appendChild(element);

        // Perform the query on the newly added element
        const div = element.shadowRoot.querySelector('div');
        // Example assertion, replace with actual logic
        expect(div).not.toBeNull();
    });

    /**
     * @description Checking that the component fetches and displays alerts correctly when some facility's data fetch is successful and others fail due to VTC_AuthException.
     * When this happens, the response is returned in an error object.
     * Previously, the component would display a generic error message when this occurred, so we are also checking that the generic error message is NOT displayed.
     */
    it("fetches and displays alerts correctly when some facility's data fetch is successful and others fail due to VTC_AuthException", async () => {
        // Mock the Apex method to return a successful response
        refreshAlerts.mockRejectedValueOnce(mockAuthExceptionData);

        // Create the component
        const element = createElement('c-vcc-alert-viewer', {
            is: vccAlertViewer
        });
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        // Duplicating the Promise.resolve, otherwise the data table is not rendered. This is also how it's done in the lwc-recipes-repo
        await Promise.resolve();
        await Promise.resolve();

        // Verify that the Apex method was called
        expect(refreshAlerts).toHaveBeenCalled();

        // Query the lightning data table component
        const datatable = element.shadowRoot.querySelector('lightning-datatable');

        // Verify that the alerts data is displayed
        expect(datatable).not.toBeNull();
        expect(datatable.data.length).toBe(JSON.parse(mockAuthExceptionData.body.message).length);

        // Verify the content of the first alert row
        const firstAlertRow = datatable.data[0];
        expect(firstAlertRow.patientName).toBe('PATIENT1,TEST');
        expect(firstAlertRow.patientLast4SSN).toBe('9991');
        expect(firstAlertRow.facilityId).toBe('512');
        expect(firstAlertRow.dateTime).toBe('2025-01-16T09:52:37');
        expect(firstAlertRow.message).toBe('Scheduled Consult: PHYSICAL THERAPY OUT');
        expect(firstAlertRow.forwardedBy).toBe('PATEL,TUSHAR P');
        expect(firstAlertRow.forwardedDateTime).toBe('07/25/24 10:57:20');
        expect(firstAlertRow.forwardedComment).toBe('"RESTORED FROM SURROGATE 1"');
        expect(firstAlertRow.surrogateName).toBe('LUCIANO LOPEZ,RUBEN A GONZALEZ ROMESKO');

        // Verify the content of the last alert row
        const lastAlertRow = datatable.data[datatable.data.length - 1];
        expect(lastAlertRow.patientName).toBe('PATIENT4,TEST');
        expect(lastAlertRow.patientLast4SSN).toBe('9994');
        expect(lastAlertRow.facilityId).toBe('517');
        expect(lastAlertRow.dateTime).toBe('2025-01-15T06:02:04');
        expect(lastAlertRow.message).toBe('Comment Added to Consult COMMUNITY CARE-DENTA');
        expect(lastAlertRow.forwardedBy).toBe('PATEL,TUSHAR P');
        expect(lastAlertRow.forwardedDateTime).toBe('08/01/24 10:57:20');
        expect(lastAlertRow.forwardedComment).toBe('"RESTORED FROM SURROGATE 8"');
        expect(lastAlertRow.surrogateName).toBe('L');
        // Verify that the 'Unexpected Error' error message is NOT displayed
        const errorDiv = element.shadowRoot.querySelector('.slds-notify.slds-notify_alert.slds-alert_error');
        expect(errorDiv).toBeNull();
    });

    /**
     * @description Checking that the component fetches and displays alerts correctly when all facility's data is fetched successfully and that no error message is displayed.
     */
    it("fetches and displays alerts correctly when all facility's data is fetched successfully", async () => {
        // Mock the Apex method to return a successful response
        refreshAlerts.mockResolvedValue(mockResponseData);

        // Create the component
        const element = createElement('c-vcc-alert-viewer', {
            is: vccAlertViewer
        });
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        // Duplicating the Promise.resolve, otherwise the data table is not rendered. This is also how it's done in the lwc-recipes-repo
        await Promise.resolve();
        await Promise.resolve();

        // Verify that the Apex method was called
        expect(refreshAlerts).toHaveBeenCalled();

        // Wait for the lightning-datatable component to be rendered
        await Promise.resolve();
        const datatable = element.shadowRoot.querySelector('lightning-datatable');

        // Verify that the alerts data is displayed
        expect(datatable).not.toBeNull();
        const totalAlerts = mockResponseData.records.length;
        expect(datatable.data.length).toBe(totalAlerts);

        // Verify the content of the first alert row
        const firstAlertRow = datatable.data[0];
        expect(firstAlertRow.patientName).toBe('JR,GDXYL K');
        expect(firstAlertRow.patientLast4SSN).toBe('2277');
        expect(firstAlertRow.facilityId).toBe('982');
        expect(firstAlertRow.dateTime).toBe('2025-01-23T05:01:01.000Z');
        expect(firstAlertRow.message).toBe('UNSIGNED VIST GENERAL OFFICE VISIT Dated 09/17/24 OVERDUE for SIGNATURE');
        expect(firstAlertRow.forwardedBy).toBe('PATEL,TUSHAR P');
        expect(firstAlertRow.forwardedDateTime).toBe('07/25/24 10:57:20');
        expect(firstAlertRow.forwardedComment).toBe('"RESTORED FROM SURROGATE 1"');
        expect(firstAlertRow.surrogateName).toBe('LUCIANO LOPEZ,RUBEN A GONZALEZ ROMESKO');
        // Verify the content of the second alert row
        const secondAlertRow = datatable.data[1];
        expect(secondAlertRow.patientName).toBe('LH JALDU,PLASHU G');
        expect(secondAlertRow.patientLast4SSN).toBe('7990');
        expect(secondAlertRow.facilityId).toBe('982');
        expect(secondAlertRow.dateTime).toBe('2025-01-23T05:01:00.000Z');
        expect(secondAlertRow.message).toBe(
            'UNSIGNED GEM INPATIENT PROGRESS NOTE Dated 08/28/24 OVERDUE for SIGNATURE'
        );
        expect(secondAlertRow.forwardedBy).toBe('PATEL,TUSHAR P');
        expect(secondAlertRow.forwardedDateTime).toBe('07/26/24 10:57:20');
        expect(secondAlertRow.forwardedComment).toBe('"RESTORED FROM SURROGATE 2"');
        expect(secondAlertRow.surrogateName).toBe('LUCIANO LOPEZ,RUBEN A GONZALEZ');

        // Verify the content of the last alert row
        const lastAlertRow = datatable.data[datatable.data.length - 1];
        expect(lastAlertRow.patientName).toBe('BALINA,MINGO GERRY');
        expect(lastAlertRow.patientLast4SSN).toBe('5595');
        expect(lastAlertRow.facilityId).toBe('982');
        expect(lastAlertRow.dateTime).toBe('2025-01-23T05:01:00.000Z');
        expect(lastAlertRow.message).toBe('UNSIGNED Adverse React/Allergy Dated 04/09/24 OVERDUE for SIGNATURE');
        expect(lastAlertRow.forwardedBy).toBe('PATEL,TUSHAR P');
        expect(lastAlertRow.forwardedDateTime).toBe('07/30/24 10:57:20');
        expect(lastAlertRow.forwardedComment).toBe('"RESTORED FROM SURROGATE 6"');
        expect(lastAlertRow.surrogateName).toBe('LUCIANO');
        // Verify that the generic error message is NOT displayed
        const errorDiv = element.shadowRoot.querySelector('.slds-notify.slds-notify_alert.slds-alert_error');
        expect(errorDiv).toBeNull();
    });
});
