import { createElement } from 'lwc';
import VccTaskRelated from 'c/vccTaskRelated';
import getRelatedTaskDetail from '@salesforce/apex/VCC_TaskMedicationController.getRelatedTaskDetail';
import { subscribe } from 'lightning/messageService';
import VCC_UI_UPDATE from '@salesforce/messageChannel/vccUIUpdate__c';

// Loading mock data stored in the __data__ folder
const mockCaseRelatedTaskDetails = require('./data/caseRelatedTaskDetails.json');
const mockProgressNoteRelatedTaskDetails = require('./data/progressNoteRelatedTaskDetails.json');
const mockAccountRelatedTaskDetails = require('./data/accountRelatedTaskDetails.json');
const mockTaskRelatedTaskDetails = require('./data/taskRelatedTaskDetails.json');

// Mocking the logger component in the vccTaskRelated.html
jest.mock('c/logger');

// Mocking imperative Apex method call
jest.mock(
    '@salesforce/apex/VCC_TaskMedicationController.getRelatedTaskDetail',
    () => {
        return {
            default: jest.fn()
        };
    },
    { virtual: true }
);

// Test Suite for the vccTaskRelated component
describe('c-vcc-task-related', () => {
    let element;
    beforeEach(() => {
        // Create the vccTaskRelated component
        element = createElement('c-vcc-task-related', {
            is: VccTaskRelated
        });
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

    // Test case for no records returned.
    it('renders the c-base-empty-state component when noRecords is true', async () => {
        // Mock the imperative Apex method to return an empty array
        getRelatedTaskDetail.mockResolvedValue([]);

        // Set the recordId attribute on the component
        element.recordId = '000000000000000001';
        // Append the element to the DOM
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Get the baseEmptyState element for assertions
        const baseEmptyStateElement = element.shadowRoot.querySelector('c-base-empty-state');

        // Assert that the baseEmptyState element is rendered
        expect(baseEmptyStateElement).not.toBeNull();
    });

    // Test case for confirming registeration with LMS
    it('registers the LMS subscriber during the component lifecycle', () => {
        // Mock the imperative Apex method to return an empty array
        getRelatedTaskDetail.mockResolvedValue([]);

        // Set the recordId attribute on the component
        element.recordId = '000000000000000001';

        // Append the element to the DOM
        document.body.appendChild(element);

        // Assert that the subscribe method was called
        expect(subscribe).toHaveBeenCalled();

        // Assert that the first time the subscribe method was called we used the messageChannel vccUIUpdate__c
        expect(subscribe.mock.calls[0][1]).toBe(VCC_UI_UPDATE);
    });

    // Test case for rendering datatable on progress notes record
    it('renders the lightning-datatable component on Progress Note record', async () => {
        // Mock the imperative Apex method to return the mockProgressNoteRelatedTaskDetails data
        getRelatedTaskDetail.mockResolvedValue(mockProgressNoteRelatedTaskDetails);

        // Set the recordId attribute on the component
        element.recordId = 'a1a000000000000001';

        // Append the element to the DOM
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Get the datatable element for assertions
        const table = element.shadowRoot.querySelector('lightning-datatable');

        // Assert that the datatable data length matches the mock data length
        expect(table.data.length).toBe(mockProgressNoteRelatedTaskDetails.length);

        // Assert that the datatable data matches the mock data
        for (let i = 0; i < mockProgressNoteRelatedTaskDetails.length; i++) {
            expect(table.data[i]).toEqual(
                expect.objectContaining({
                    CaseNumber: mockProgressNoteRelatedTaskDetails[i].What.Name,
                    Subject: mockProgressNoteRelatedTaskDetails[i].Subject,
                    Status: mockProgressNoteRelatedTaskDetails[i].Status,
                    recordLink: '/' + mockProgressNoteRelatedTaskDetails[i].WhatId,
                    recordLink2: '/' + mockProgressNoteRelatedTaskDetails[i].OwnerId,
                    recordLink3: '/' + mockProgressNoteRelatedTaskDetails[i].CreatedBy.Id,
                    recordLink4: '/' + mockProgressNoteRelatedTaskDetails[i].Id
                })
            );
        }
    });

    it('renders the lightning-datatable component on Case record', async () => {
        // Mock the imperative Apex method to return the mockCaseRelatedTaskDetails data
        getRelatedTaskDetail.mockResolvedValue(mockCaseRelatedTaskDetails);

        // Set the recordId attribute on the component
        element.recordId = '500000000000000001';

        // Append the element to the DOM
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Get the datatable element for assertions
        const table = element.shadowRoot.querySelector('lightning-datatable');

        // Assert that the datatable data length matches the mock data length
        expect(table.data.length).toBe(mockCaseRelatedTaskDetails.length);

        // Assert that the datatable data matches the mock data
        for (let i = 0; i < mockCaseRelatedTaskDetails.length; i++) {
            expect(table.data[i]).toEqual(
                expect.objectContaining({
                    Subject: mockCaseRelatedTaskDetails[i].Subject,
                    Status: mockCaseRelatedTaskDetails[i].Status, //2
                    recordLink: '/' + mockCaseRelatedTaskDetails[i].WhatId,
                    recordLink2: '/' + mockCaseRelatedTaskDetails[i].OwnerId,
                    recordLink3: '/' + mockCaseRelatedTaskDetails[i].CreatedBy.Id, //3
                    recordLink4: '/' + mockCaseRelatedTaskDetails[i].Id
                })
            );
        }
    });

    it('renders the lightning-datatable component on Account record', async () => {
        // Mock the imperative Apex method to return the mockAccountRelatedTaskDetails data
        getRelatedTaskDetail.mockResolvedValue(mockAccountRelatedTaskDetails);

        // Set the recordId attribute on the component
        element.recordId = '001000000000000001';

        // Append the element to the DOM
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Get the datatable element for assertions
        const table = element.shadowRoot.querySelector('lightning-datatable');

        // Assert that the datatable data length matches the mock data length
        expect(table.data.length).toBe(mockAccountRelatedTaskDetails.length);

        // Assert that the datatable data matches the mock data
        for (let i = 0; i < mockAccountRelatedTaskDetails.length; i++) {
            expect(table.data[i]).toEqual(
                expect.objectContaining({
                    Subject: mockAccountRelatedTaskDetails[i].Subject,
                    Status: mockAccountRelatedTaskDetails[i].Status,
                    recordLink: '/' + mockAccountRelatedTaskDetails[i].WhatId,
                    recordLink2: '/' + mockAccountRelatedTaskDetails[i].OwnerId,
                    recordLink3: '/' + mockAccountRelatedTaskDetails[i].CreatedBy.Id,
                    recordLink4: '/' + mockAccountRelatedTaskDetails[i].Id
                })
            );
        }
    });

    it('renders the lightning-datatable component on Task record', async () => {
        // Mock the imperative Apex method to return the mockTaskRelatedTaskDetails data
        getRelatedTaskDetail.mockResolvedValue(mockTaskRelatedTaskDetails);

        // Set the recordId attribute on the component
        element.recordId = '00T000000000000001';

        // Append the element to the DOM
        document.body.appendChild(element);

        // Wait for any asynchronous DOM updates
        await flushPromises();

        // Get the datatable element for assertions
        const table = element.shadowRoot.querySelector('lightning-datatable');

        // Assert that the datatable data length matches the mock data length
        expect(table.data.length).toBe(mockTaskRelatedTaskDetails.length);

        // Assert that the datatable data matches the mock data
        for (let i = 0; i < mockTaskRelatedTaskDetails.length; i++) {
            expect(table.data[i]).toEqual(
                expect.objectContaining({
                    Subject: mockTaskRelatedTaskDetails[i].Subject,
                    Status: mockTaskRelatedTaskDetails[i].Status,
                    recordLink: '/' + mockTaskRelatedTaskDetails[i].WhatId,
                    recordLink2: '/' + mockTaskRelatedTaskDetails[i].OwnerId,
                    recordLink3: '/' + mockTaskRelatedTaskDetails[i].CreatedBy.Id,
                    recordLink4: '/' + mockTaskRelatedTaskDetails[i].Id
                })
            );
        }
    });
});
