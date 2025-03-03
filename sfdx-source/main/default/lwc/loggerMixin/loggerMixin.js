/**
 *
 * @author Patrick Skamarak
 * Booz Allen Hamilton
 * skamarak_patrick@bah.com
 * pskamarak@gmail.com
 *
 * @description Mixin for Nebula Logger. Currently only supports function calls,
 * which is fine at the moment since there are no public properties on the logger LWC.
 * Could pose a problem in the future.
 *
 * @example //Add <c-logger></c-logger> to html, then in js file:
 *
 * import LoggerMixin from 'c/loggerMixin';
 *
 * export default class YourClass extends LoggerMixin(LightningElement){
 *      // call Nebula logger methods as usual by simply referencing this.Logger
 *      // ex. this.Logger.debug("Hello World")
 * }
 *
 */
export default function LoggerMixin(LightningElement) {
    let loggerState = new LoggerState();

    return class extends LightningElement {
        callLoggerMethods = async () => {
            let lockUuid = loggerState.getLock();
            if (lockUuid == null) {
                return;
            }

            while (loggerState.hasNext()) {
                let call = loggerState.getNext();
                try {
                    if (loggerState.loggerElementPromise == null) {
                        loggerState.loggerElementPromise = this.getLoggerElement();
                    }
                    call.resolve((await Promise.resolve(loggerState.loggerElementPromise))[call.methodName](...call.args));
                } catch (e) {
                    console.warn(`LoggerMixin Error: ${e}`);
                    call.resolve(e);
                }
            }

            loggerState.releaseLock(lockUuid);
        };

        getLoggerElement = function () {
            return new Promise((resolve, reject) => {
                let retries = 0;
                let intervalId;

                intervalId = setInterval(() => {
                    if (retries < 5) {
                        let logger = this.template.querySelector("c-logger");
                        if (logger != null || logger != undefined) {
                            clearInterval(intervalId);
                            resolve(logger);
                        }
                        retries++;
                    } else {
                        clearInterval(intervalId);
                        reject("Logger component not found.");
                    }
                }, 1000);
            });
        };

        Logger = new Proxy(
            {},
            {
                get: (target, prop, receiver) => {
                    return new Proxy((...args) => {}, {
                        apply: (target, thisArg, argumentsList) => {
                            let loggerCall = new LoggerCall();
                            loggerCall.args = argumentsList;
                            loggerCall.methodName = prop;

                            return new Promise((resolve, reject) => {
                                loggerCall.resolve = resolve;
                                loggerCall.reject = reject;
                                loggerState.addCall(loggerCall);
                                this.callLoggerMethods();
                            });
                        }
                    });
                }
            }
        );
    };
}

class LoggerCall {
    methodName;
    args;
    resolve;
    reject;
}

class LoggerState {
    callQueue = [];
    lockUuid = null;
    loggerElementPromise;

    getLock() {
        if (this.lockUuid != null) {
            return null;
        }
        this.lockUuid = crypto.randomUUID();
        return this.lockUuid;
    }

    releaseLock(uuid) {
        if (this.lockUuid != uuid) {
            return;
        }
        this.lockUuid = null;
    }

    addCall(loggerCall) {
        if (!(loggerCall instanceof LoggerCall)) {
            return;
        }
        this.callQueue.push(loggerCall);
    }

    hasNext() {
        if (this.callQueue.length == 0) {
            return false;
        }
        return true;
    }

    getNext() {
        return this.callQueue.shift();
    }
}
