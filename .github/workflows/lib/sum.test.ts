import { sum } from "./sum.ts";
import { jest } from '@jest/globals'; // Import function to test
test("adds 1 + 2 to equal 3", () => {
    expect(sum(1, 2)).toBe(3);
});