/**
 * @description vccMPIDataSharedState is a shared state object that is used to share MPI data between components.
 */
import { publish, createMessageContext } from 'lightning/messageService';
import vccOnPersonAccountRead from '@salesforce/messageChannel/vccOnPersonAccountRead__c';
let _mpiData;
const messageContext = createMessageContext();
/**
 * @description The shared state object to import/export. Components that need the MPI data can call MPISharedState.getData() to
 * obtain fresh mpi data.
 */
const MPISharedState = {
    setData: (newVal) => {
        _mpiData = newVal;
        if (newVal) {
            // Publishes the message when the mpi data is set
            let message = { mpiData: newVal };
            publish(messageContext, vccOnPersonAccountRead, message);
        }
    },
    getData: () => {
        return _mpiData;
    }
};

Object.freeze(MPISharedState);

export { MPISharedState };
