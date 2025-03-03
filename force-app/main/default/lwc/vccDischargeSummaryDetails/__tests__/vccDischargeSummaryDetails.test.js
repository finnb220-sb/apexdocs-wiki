/**
 * @description - Jest Test for vccDischargeSummaryDetails
 */
import { createElement } from 'lwc';
import vccDischargeSummaryDetails from 'c/vccDischargeSummaryDetails';

const mockDischargeRecord = require('./mockData/mockDataResponse.json');
const mockDischargeNewRecordSelected = require('./mockData/mockDataResponseNewRecord.json');

const PARAGRAPH_TAG = 'p';
const HORIZONTAL_DIV_CLASS = '.horizontal.info';
const INITIAL_DISCHARGE_DATE = '8/26/2024';
const NEW_DISCHARGE_DATE = '10/26/2024';
const RECORD_ID = '101010101';
const ARGS = '1212';
const SET_SELECTED_RECORD_SPY = 'setSelectedRecord';

describe('Testing Suite for vccDischargeSummaryDetails', () => {
    let element;
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
        jest.clearAllMocks();
    });

    /**
     * @description - Verifies that the selected record passing into the component is populating on the DOM
     */
    test('vccDischargeSummaryDetails - Verify getter and setters have value + setDischargeProperties function is called', () => {
        element = createElement('c-vcc-discharge-summary-details', {
            is: vccDischargeSummaryDetails
        });
        element.setDischargeProperties = jest.fn();
        element.selectedRecord = {
            dischargeSummarySelected: mockDischargeRecord,
            vtcArgs: { args: ARGS },
            recordId: RECORD_ID
        };

        let dischargeRecord = element.selectedRecord;
        element.setDischargeProperties();
        document.body.appendChild(element);
        const divElement = element.shadowRoot.querySelector(HORIZONTAL_DIV_CLASS);
        const paragraphText = divElement.querySelector(PARAGRAPH_TAG);

        expect(paragraphText.textContent).toBe(INITIAL_DISCHARGE_DATE);
        expect(dischargeRecord).toBeDefined();
        expect(element.setDischargeProperties).toHaveBeenCalled();
    });

    /**
     * @description - Verifies that when a new record is selected, that record's data's populating on the DOM
     */
    test('vccDischargeSummaryDetails - Verify setSelectedRecord is called', async () => {
        element = createElement('c-vcc-discharge-summary-details', {
            is: vccDischargeSummaryDetails
        });
        element.selectedRecord = {
            dischargeSummarySelected: mockDischargeRecord,
            vtcArgs: { args: ARGS },
            recordId: RECORD_ID
        };
        document.body.appendChild(element);

        //Emulate Selecting a new Record and verifying Date Changed on HTML
        const spy = jest.spyOn(element, SET_SELECTED_RECORD_SPY);
        element.setSelectedRecord(mockDischargeNewRecordSelected);
        document.body.appendChild(element);

        expect(spy).toHaveBeenCalled();
        expect(spy).toHaveBeenCalledWith(mockDischargeNewRecordSelected);
        expect(mockDischargeNewRecordSelected).toBeDefined();
        const divElement = element.shadowRoot.querySelector(HORIZONTAL_DIV_CLASS);
        const paragraphText = divElement.querySelector(PARAGRAPH_TAG);
        expect(paragraphText.textContent).toBe(NEW_DISCHARGE_DATE);
    });
});
