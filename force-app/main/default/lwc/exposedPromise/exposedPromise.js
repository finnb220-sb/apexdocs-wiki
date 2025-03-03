export default class ExposedPromise extends Promise {
    resolve;
    reject;

    constructor(resolver = (resolve, reject) => {}) {
        if (typeof resolver != "function") {
            throw new Error("The first argument must be a resolver function.");
        }

        let promiseResolve, promiseReject;

        super((resolve, reject) => {
            resolver(resolve, reject);
            promiseResolve = resolve;
            promiseReject = reject;
        });

        this.resolve = promiseResolve;
        this.reject = promiseReject;
    }
}
