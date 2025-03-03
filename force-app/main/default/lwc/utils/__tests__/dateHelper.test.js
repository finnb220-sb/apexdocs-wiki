import { dateHelper } from '../utils';
describe('dateHelper.asUtc', () => {
    it('accepts and returns a date object', () => {
        let originalDate = new Date();
        let newDate = dateHelper.asUtc(originalDate);
        expect(newDate).not.toBe(null);
        expect(newDate).toBeInstanceOf(Date);
        expect(newDate).not.toBe(originalDate);
    });

    it('rejects input that is not an object', () => {
        let typeError;
        try {
            dateHelper.asUtc('hello world');
            throw new Error('Expected an exception to be thrown because the first argument is not a Date');
        } catch (anyError) {
            typeError = anyError;
        }
        expect(typeError).not.toBe(null);
        expect(typeError).toBeInstanceOf(TypeError);
        expect(typeError.message).toContain(dateHelper.NOT_INSTANCE_OF_DATE_ERROR_MESSAGE);
    });

    it('returns the correct date value', () => {
        let now = new Date(Date.now());
        let nowAsUtc = dateHelper.asUtc(now);
        // using getUTC* methods because otherwise it will convert the new date into local time
        expect(nowAsUtc.getUTCDate()).toBe(now.getDate());
        expect(nowAsUtc.getUTCDay()).toBe(now.getDay());
        expect(nowAsUtc.getUTCFullYear()).toBe(now.getFullYear());
        expect(nowAsUtc.getUTCHours()).toBe(now.getHours());
        expect(nowAsUtc.getUTCMilliseconds()).toBe(now.getMilliseconds());
        expect(nowAsUtc.getUTCMinutes()).toBe(now.getMinutes());
        expect(nowAsUtc.getUTCMonth()).toBe(now.getMonth());
        expect(nowAsUtc.getUTCSeconds()).toBe(now.getSeconds());
    });
});
