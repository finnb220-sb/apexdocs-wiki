// TODO: import custom label for deceased patient
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export const ToastPreset = {
    ERROR: {
        title: 'Error',
        message: 'Unexpected error',
        variant: 'error',
        mode: 'sticky'
    },
    PATIENT_EXISTS: {
        title: 'Existing Patient Record Found',
        variant: 'info',
        message: 'Navigating to record.'
    },
    PATIENT_CREATED: {
        title: 'New Patient Record Created',
        variant: 'success',
        message: 'Navigating to record.'
    }
};

export function newToastEvent(toastPreset, e) {
    if (toastPreset === ToastPreset.PATIENT_CREATED) {
        return new ShowToastEvent(ToastPreset.PATIENT_CREATED);
    }

    if (toastPreset === ToastPreset.PATIENT_EXISTS) {
        return new ShowToastEvent(ToastPreset.PATIENT_EXISTS);
    }

    //javascript error
    if (e instanceof Error) {
        return new ShowToastEvent({
            ...ToastPreset.ERROR,
            title: e.name,
            message: e.message
        });
    }

    // "duck typing" for VCC_AddPatientController.AddPatientControllerError
    // ie. if it walks like a duck and quacks like a duck, its a duck
    if (typeof e.type == 'string' && typeof e.message == 'string') {
        return new ShowToastEvent({
            ...ToastPreset.ERROR,
            title: e.type,
            message: e.message
        });
    }

    // "duck typing" for uncaught apex exception aka a (kind-of) Fetch API Response object
    // find more info here https://developer.salesforce.com/blogs/2020/08/error-handling-best-practices-for-lightning-web-components
    if (typeof e.status == 'number' && typeof e.statusText == 'string' && typeof e.body?.message == 'string') {
        return new ShowToastEvent({
            ...ToastPreset.ERROR,
            title: `${e.statusText}${e.body?.exceptionType ? ` (${e.body.exceptionType})` : ''}`,
            message: e.body.message
        });
    }

    //fallback
    return new ShowToastEvent(ToastPreset.ERROR);
}
