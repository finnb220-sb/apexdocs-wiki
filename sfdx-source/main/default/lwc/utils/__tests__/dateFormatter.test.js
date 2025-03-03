import { dateFormatter } from '../utils';

describe('salesForceDateTimeStringToMMDDYYYYHHMM', () => {
    test('formats a typical Salesforce DateTime string correctly', () => {
        const input = '2024-10-25T19:25:56.000+0000';
        const expectedOutput = '10/25/2024 7:25 pm';
        expect(dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(input)).toBe(expectedOutput);
    });

    test('formats a Salesforce DateTime string with midnight time correctly', () => {
        const input = '2024-10-25T00:00:00.000Z';
        const expectedOutput = '10/25/2024';
        expect(dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(input)).toBe(expectedOutput);
    });

    test('returns an empty string if input is null', () => {
        const input = null;
        const expectedOutput = '';
        expect(dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(input)).toBe(expectedOutput);
    });

    test('formats date with different am time correctly', () => {
        const input = '2024-10-25T08:15:00.000+0000';
        const expectedOutput = '10/25/2024 8:15 am';
        expect(dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(input)).toBe(expectedOutput);
    });

    test('formats date with 12 pm time correctly', () => {
        const input = '2024-10-25T12:00:00.000+0000';
        const expectedOutput = '10/25/2024 12:00 pm';
        expect(dateFormatter.salesForceDateTimeStringToMMDDYYYYHHMM(input)).toBe(expectedOutput);
    });
});
