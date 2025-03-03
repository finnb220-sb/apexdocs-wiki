import { api, LightningElement } from "lwc";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

/**
 * this exists because:
 * https://salesforce.stackexchange.com/questions/387924/lightning-modal-custom-event-not-working-in-winter-23-release
 */

// A promise, but it has it's resolve() and reject() exposed
class ExposedPromise extends Promise {
    resolve;
    reject;

    constructor(
        resolver = (resolve, reject) => {
            resolve;
            reject;
        }
    ) {
        if (typeof resolver != "function") {
            throw "The first argument must be a resolver function.";
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
export default class VccVaProfileModalFooter extends LightningElement {
    @api
    value;

    @api
    disableClose = false;

    handleBack() {
        this.dispatchEvent(
            new CustomEvent("back", {
                bubbles: true,
                composed: true
            })
        );
    }

    //.. so sorry about this
    async handleSubmit() {
        let validationPromise = new ExposedPromise();
        let submitPromise = new ExposedPromise();

        this.dispatchEvent(
            new CustomEvent("submit", {
                bubbles: true,
                composed: true,
                detail: {
                    value: this.value,
                    submitPromise: submitPromise,
                    validationPromise: validationPromise
                }
            })
        );

        try {
            let submitResult = await Promise.resolve(submitPromise);

            this.dispatchEvent(
                new ShowToastEvent({
                    title: submitResult?.title || "Success",
                    message: submitResult?.message || null,
                    variant: submitResult?.variant || "success",
                    mode: submitResult?.mode || "dismissible"
                })
            );
        } catch (e) {
            // console.warn(e);
            if (Array.isArray(e)) {
                for (let i = 0; i < e.length; i++) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: e[i]?.title || "Error",
                            message: e[i]?.message || "An unhandled error has occurred.",
                            variant: e[i]?.variant || "error",
                            mode: e[i]?.mode || "sticky"
                        })
                    );
                }
            } else {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: e?.title || "Error",
                        message: e?.message || "An unhandled error has occurred.",
                        variant: e?.variant || "error",
                        mode: e?.mode || "sticky"
                    })
                );
            }
        }
    }
}
