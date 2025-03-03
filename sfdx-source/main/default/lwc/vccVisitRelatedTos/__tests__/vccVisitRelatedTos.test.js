/**
 * @description Jest test file for vccVisitRelatedTos LWC
 * @author Booz Allen Hamilton
 */
/* eslint-disable */
import { createElement } from 'lwc';
import vccVisitRelatedTos from 'c/vccVisitRelatedTos';
import { getRecord } from 'lightning/uiRecordApi';
import retrieveVetInfo from '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo';

const RETRIEVE_VET_INFO_EMPTY = JSON.stringify({
    vetsV3: [{ ee: {} }]
});
const GET_RECORDS_DATA_EMPTY = {
    fields: {
        VCC_Case__r: {
            value: {
                fields: {
                    AccountId: {
                        value: 'test'
                    }
                }
            }
        }
    }
};
jest.mock(
    '@salesforce/apex/VCC_OnPatientLoadController.retrieveVetInfo',
    () => ({
        default: jest.fn()
    }),
    { virtual: true }
);

describe('c-vcc-visit-related-tos', () => {
    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }

        // clearing mocks between tests
        jest.clearAllMocks();
    });

    async function flush_promises() {
        await Promise.resolve();
    }

    it('does not render the "Rated Disabilities" info', async () => {
        // setting imperative mock before calling createElement
        retrieveVetInfo.mockResolvedValue(RETRIEVE_VET_INFO_EMPTY);
        //create and append element
        const element = createElement('c-vcc-visit-related-tos', {
            is: vccVisitRelatedTos
        });
        document.body.appendChild(element);

        // emitting getRecord wire adapter after creating element
        getRecord.emit(GET_RECORDS_DATA_EMPTY);

        // set record Id to trigger mpi callout so the stuff we want to test happens
        element.recordId = '000000000000000000';
        await flush_promises();
        expect(element.shadowRoot.innerHTML).not.toContain('Rated Disabilities');
    });

    it('does not render the "Service Connected" info', async () => {
        // setting imperative mock before calling createElement
        retrieveVetInfo.mockResolvedValue(RETRIEVE_VET_INFO_EMPTY);
        //create and append element
        const element = createElement('c-vcc-visit-related-tos', {
            is: vccVisitRelatedTos
        });
        document.body.appendChild(element);

        // emitting getRecord wire adapter after creating element
        getRecord.emit(GET_RECORDS_DATA_EMPTY);

        // set record Id to trigger mpi callout so the stuff we want to test happens
        element.recordId = '000000000000000000';
        await flush_promises();
        expect(element.shadowRoot.innerHTML).not.toContain('Service Connected');
    });

    it('renders rated disability info', async () => {
        // test data setup
        let ratedDisabilities = [
            { disability: 'hi', percentage: '20' },
            { disability: 'test', percentage: '100' }
        ];

        // setting imperative mock before calling createElement
        retrieveVetInfo.mockResolvedValue(
            JSON.stringify({
                vetsV3: [
                    {
                        ee: {
                            ratedDisabilities: ratedDisabilities
                        }
                    }
                ]
            })
        );

        //create and append element
        const element = createElement('c-vcc-visit-related-tos', {
            is: vccVisitRelatedTos
        });
        document.body.appendChild(element);

        let crypto = require('crypto');
        Object.defineProperty(globalThis, 'crypto', {
            value: {
                randomUUID: () => {
                    return crypto.randomUUID();
                }
            }
        });

        // emitting getRecord mock data  after creating element
        getRecord.emit(GET_RECORDS_DATA_EMPTY);

        // set record Id to trigger mpi callout so the stuff we want to test happens
        element.recordId = '000000000000000000';
        await flush_promises();

        expect(element.shadowRoot.innerHTML).toContain('Rated Disabilities');
        for (let disability of ratedDisabilities) {
            expect(element.shadowRoot.innerHTML).toContain(`${disability.disability} ${disability.percentage}%`);
        }
    });

    it('renders Service Connected info', async () => {
        // test data setup
        let ratedDisabilities = [];
        let serviceConnectedPercentage = '100';

        // setting imperative mock before calling createElement
        retrieveVetInfo.mockResolvedValue(
            JSON.stringify({
                vetsV3: [
                    {
                        ee: {
                            serviceConnectedPercentage: serviceConnectedPercentage
                        }
                    }
                ]
            })
        );

        //create and append element
        const element = createElement('c-vcc-visit-related-tos', {
            is: vccVisitRelatedTos
        });
        document.body.appendChild(element);

        // emitting getRecord mock data  after creating element
        getRecord.emit(GET_RECORDS_DATA_EMPTY);

        // set record Id to trigger mpi callout so the stuff we want to test happens
        element.recordId = '000000000000000000';
        await flush_promises();

        expect(element.shadowRoot.innerHTML).toContain('Service Connected');
        expect(element.shadowRoot.innerHTML).toContain(`${serviceConnectedPercentage}%`);
    });
});
