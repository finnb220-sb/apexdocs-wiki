/**
 * @description vccMPISharedState is a shared state object that is used to share MPI data between components. Other lwc's can import MPISharedState
 * and have access to the MPI data via the getData function.
 */
import { MPISharedState } from './sharedState.js';
export { MPISharedState } from './sharedState.js';
import { LightningElement } from 'lwc';

export default class VCCMPISharedState extends LightningElement {
    //Resets the MPI data to null on page load
    connectedCallback() {
        MPISharedState.setData(null);
    }
}
