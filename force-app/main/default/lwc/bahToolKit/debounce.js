/**
 * @description Creates a debounced function that delays the execution of the provided function until
 * after the specified wait time has elapsed since the last time the debounced function was called.
 *
 * @param func - The function to debounce.
 * @param waitMs - The number of milliseconds to delay.
 */
export function debounce(func, waitMs) {
    let timeout;

    return function executedFunction() {
        const context = this;
        const args = arguments;
        const later = function () {
            timeout = null;
            func.apply(context, args);
        };
        window.clearTimeout(timeout);
        /* eslint-disable */
        timeout = window.setTimeout(later, waitMs);
        /* eslint-enable */
    };
}
