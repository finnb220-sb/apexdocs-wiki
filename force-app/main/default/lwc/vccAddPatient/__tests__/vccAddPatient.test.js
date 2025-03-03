import { createElement } from 'lwc';
import vccAddPatient from 'c/vccAddPatient';
import { newToastEvent } from '../vccAddPatientHelper';
import { searchCrm, searchMpi, SearchCrmParameters, SearchMpiParameters, addVeteran } from 'c/vccAddPatientController';

// TODO: How to handle mock of vccResult:instanceof
import { Result } from 'c/vccResult';

// Mocked via ./jest.config.js and ./force-app/test/jest-mocks/lightning/navigation.js
import { getNavigateCalledWith } from 'lightning/navigation';

// Loading mock data stored in the data folder
const mockCrmResponse = require('./data/mockCrmResponse.json');
const mockMpiResponse = require('./data/mockMpiResponse.json');
const mockVetResponse = require('./data/mockVetResponse.json');

// Mocking the vccAddPatientController module
jest.mock('c/vccAddPatientController', () => ({
    searchCrm: jest.fn(),
    searchMpi: jest.fn(),
    SearchCrmParameters: jest.fn(),
    SearchMpiParameters: jest.fn(),
    addVeteran: jest.fn()
}));

// Mocking the vccAddPatientHelper module
jest.mock('../vccAddPatientHelper', () => ({
    newToastEvent: jest.fn(),
    ToastPreset: {
        ERROR: {
            title: 'Error',
            variant: 'error',
            message: 'Unexpected error',
            mode: 'sticky'
        },
        PATIENT_EXISTS: {
            title: 'Existing Patient Record Found',
            variant: 'info',
            message: 'Navigating to record.'
        },
        PATIENT_CREATED: {
            title: ' New Patient Record Created',
            variant: 'success',
            message: 'Navigating to record.'
        }
    }
}));

// Mocking the nested components in the vccAddPatient.html
jest.mock('c/vccAddPatientSearch');
jest.mock('c/vccAddPatientSearchResult');

// Test Suite for the vccAddPatient component
describe('c-vcc-add-patient', () => {
    // Element is shared across test cases, created in beforeEach
    let element;

    /* "onsearchcrm" is required to run because
     * "vccAddPatient.showResults" is private, must be true to render
     * the search results component, and it ONLY renders AFTER the "onsearchcrm" event
     */
    beforeEach(async () => {
        // Create the vccTaskRelated component
        element = createElement('c-vcc-add-patient', {
            is: vccAddPatient
        });

        // Mock SearchCrmParameters constructor
        SearchCrmParameters.mockImplementation(() => ({
            ssn: '123456789',
            dob: '01/01/2004',
            lastName: 'Doe',
            firstName: 'John',
            middleName: ''
        }));

        //How to handle mock instanceof without dep on vccResult
        searchCrm.mockResolvedValue(Result.fromApex(mockCrmResponse));

        // Append the element to the DOM
        document.body.appendChild(element);

        // Query the c-vcc-add-patient-search component and fire the onsearchcrm event
        const addPatientSearch = element.shadowRoot.querySelector('c-vcc-add-patient-search');
        addPatientSearch.dispatchEvent(new CustomEvent('searchcrm'));
    });

    afterEach(() => {
        // The jsdom instance is shared across test cases in a single file so reset the DOM
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    // Helper function to wait until the microtask queue is empty.
    // Used when having to wait for asynchronous DOM updates.
    async function flushPromises() {
        return Promise.resolve();
    }

    // Validate CRM search results
    it('renders the c-vcc-add-patient component and displays CRM search results', async () => {
        // Query the lightning-card and check if the title of the lightning-card has been updated
        const postCRMLightningCard = element.shadowRoot.querySelector('lightning-card');
        expect(postCRMLightningCard.title).toBe('CRM Results');

        // Query the c-vcc-add-patient-search-result component
        const addPatientCRMSearchResult = element.shadowRoot.querySelector('c-vcc-add-patient-search-result');

        // Easier to reference the mock data
        const accountList = mockCrmResponse.value.accountList;

        // Assert that the search results match the mock data
        for (let i = 0; i < accountList.length; i++) {
            expect(addPatientCRMSearchResult.searchResults[i]).toEqual(
                expect.objectContaining({
                    Name: accountList[i].Name,
                    Id: accountList[i].Id
                })
            );
        }
    });

    // Validate MPI search results
    it('renders the c-vcc-add-patient component and displays MPI search results', async () => {
        // Mock SearchMpiParameters constructor
        SearchMpiParameters.mockImplementation(() => ({
            ssn: '987654321',
            dob: '01/01/2004-',
            lastName: 'Doe',
            firstName: 'John',
            middleName: ''
        }));

        //How to handle mock instanceof without dep on vccResult
        searchMpi.mockResolvedValue(Result.fromApex(mockMpiResponse));

        // Query the c-vcc-add-patient-search-result component
        const addPatientCRMSearchResult = element.shadowRoot.querySelector('c-vcc-add-patient-search-result');
        addPatientCRMSearchResult.dispatchEvent(new CustomEvent('searchmpi'));

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Check if the title of the lightning-card is correct
        const postMPILightningCard = element.shadowRoot.querySelector('lightning-card');
        expect(postMPILightningCard.title).toBe('External Results');

        // Query the c-vcc-add-patient-search-result component
        const addPatientMPISearchResult = element.shadowRoot.querySelector('c-vcc-add-patient-search-result');

        // Easier to reference the mock data
        const personList = mockMpiResponse.value.allData;

        // Assert that the search results match the mock data
        for (let i = 0; i < personList.length; i++) {
            expect(addPatientMPISearchResult.searchResults[i]).toEqual(
                expect.objectContaining({
                    FirstName: personList[i].firstName,
                    LastName: personList[i].lastName,
                    PersonBirthdate: personList[i].dob,
                    Id: personList[i].icn
                })
            );
        }
    });

    // Validate AddVet results
    it('renders the c-vcc-add-patient component and displays AddVet results', async () => {
        //How to handle mock instanceof without dep on vccResult
        addVeteran.mockResolvedValue(Result.fromApex(mockVetResponse));

        //Mock the newToastEvent function used in the handleAddVet method
        newToastEvent.mockReturnValue(new CustomEvent('mockEvent'));

        // Query the c-vcc-add-patient-search-result component
        const addPatientCRMSearchResult = element.shadowRoot.querySelector('c-vcc-add-patient-search-result');

        // Dispatch the addvet event, firing the handleAddVet method
        addPatientCRMSearchResult.dispatchEvent(new CustomEvent('addvet'));

        // Wait for any asynchronous DOM updates
        await flushPromises();

        //Get the pageRegerence, check imports for mock location.
        const { pageReference } = getNavigateCalledWith();

        // Assert pageReference values.
        expect(pageReference).not.toBeNull();
        expect(pageReference.type).toBe('standard__recordPage');
        expect(pageReference.attributes.objectApiName).toBe('Account');
        expect(pageReference.attributes.actionName).toBe('view');
    });
});
