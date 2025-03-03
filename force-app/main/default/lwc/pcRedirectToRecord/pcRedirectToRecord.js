import { LightningElement, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class PcRedirectToRecord extends NavigationMixin(LightningElement) {
    @api sendToRecord;
    @api sendToPage;

    connectedCallback() {
        if (this.sendToRecord) {
            this[NavigationMixin.Navigate]({
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.sendToRecord,
                    objectApiName: this.objectName,
                    actionName: 'view'
                }
            });
        }
    }
}
