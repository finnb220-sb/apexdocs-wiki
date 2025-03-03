/**
 * @author Booz Allen
 * @description Jest test for the vccAllergyDetails lwc
 * @see c/vccAllergyDetails
 *
 * Created 01/2025
 */
import { createElement } from 'lwc';
import vccAllergyDetails from 'c/vccAllergyDetails';

//Mock record
const mockSelectedRecord = require('./data/record.json');
//Mock config
const mockCommentConfig = require('./data/commentColConfig.json');

describe('c-vcc-allergy-details', () => {
    let element;
    /**
     * @description init the allergy details element with required data before each test and appends it to the DOM
     */
    beforeEach(() => {
        element = createElement('c-vcc-allergy-details', { is: vccAllergyDetails });
        element.commentColumns = [];
        element.selectedRecord = {};
        document.body.appendChild(element);
    });

    /**
     * @description reset the DOM after each test
     */
    afterEach(() => {
        while (document.body.firstChild) {
            document.body.removeChild(document.body.firstChild);
        }
    });

    /**
     * @description checks that the component rendered and that the date elements referrring to the lightning formatted date time element
     * has the expected properties after render, positive
     */
    it('should not render null', () => {
        expect(element).not.toBeNull();
        const dateElement = element.shadowRoot.querySelector('lightning-formatted-date-time');
        expect(dateElement.year).toBe('numeric');
        expect(dateElement.month).toBe('numeric');
        expect(dateElement.day).toBe('numeric');
        expect(dateElement.timeZone).toBe('UTC');
        expect(dateElement.hour).toBe('numeric');
        expect(dateElement.minute).toBe('numeric');
    });

    /**
     * @description when the component is provided mock record data, checks for the respective Causative Agent data
     * to be populated when looking at the immediate next paragraph element, positive
     */
    it('check agent text in DOM', () => {
        element.selectedRecord = mockSelectedRecord;
        element.commentColumns = mockCommentConfig;

        return Promise.resolve().then(() => {
            let pElements = element.shadowRoot.querySelectorAll('p');
            let agentText;
            pElements.forEach((paraElement, index) => {
                const text = paraElement.textContent;
                if (text === 'Causative Agent') {
                    agentText = pElements[index + 1].textContent;
                }
            });
            expect(agentText).not.toBeNull();
            expect(agentText).toBe(mockSelectedRecord.agent);
        });
    });

    /**
     * @description when the component is provided mock data and then rendered, the getter method should return a non null value, positive
     */
    it('set selected record var', () => {
        expect(JSON.stringify(element.selectedRecord)).toBe('{}');

        element.setSelectedRecord(mockSelectedRecord);

        return Promise.resolve().then(() => {
            expect(element.selectedRecord).not.toBeNull();
        });
    });
});
