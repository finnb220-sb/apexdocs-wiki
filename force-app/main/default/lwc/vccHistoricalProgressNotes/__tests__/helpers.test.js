import { assignAuthor } from '../helpers';

describe('helpers.assignAuthor', () => {
    it('sets authorName property to blank when clinicians list is empty or null/undefined', () => {
        let mockNotes = [{ clinicians: [] }];
        assignAuthor(mockNotes);
        let authorName = mockNotes[0].authorName;
        expect(authorName).toBe('');
    });

    it('sets authorName property to the clinicians name whose role is "A"', () => {
        let mockAuthorName = 'Test Author Name';
        let mockNotes = [
            { someOtherProperty: {}, someProperty: {}, clinicians: [{ role: 'A', name: mockAuthorName }] }
        ];
        assignAuthor(mockNotes);
        let authorName = mockNotes[0].authorName;
        expect(authorName).toBe(mockAuthorName);
    });
});
