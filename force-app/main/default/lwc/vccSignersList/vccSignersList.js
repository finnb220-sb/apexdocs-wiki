/* eslint-disable @lwc/lwc/no-async-operation */
import { wire, api, LightningElement } from 'lwc';
import { publish, MessageContext } from 'lightning/messageService';
import VCC_PROGRESS_NOTE_PACT_CHANNEL from '@salesforce/messageChannel/vccProgressNoteFlowPact__c';
import { getSignersForRecord, addSignersToRecord, deleteSigners } from 'c/vccSignersController';
import vccAddSignersSelectLabel from '@salesforce/label/c.vccAddSignersSelectLabel';
import vccAddSignersTitleLabel from '@salesforce/label/c.vccAddSignersTitleLabel';
import { openLoadingModal } from 'c/vccLoadingModal';

const columns = [
    {
        label: '',
        type: 'button-icon',
        typeAttributes: {
            iconName: 'utility:dash',
            name: 'remove',
            variant: 'brand-inverse'
        },
        initialWidth: 50
    },
    { label: 'Name', fieldName: 'Name', sortable: false, initialWidth: 200 },
    { label: 'Title', fieldName: 'VCC_Title__c', sortable: false, initialWidth: 225 }
];
export default class VccSignersList extends LightningElement {
    vccAddSignersSelectLabel = vccAddSignersSelectLabel;
    vccAddSignersTitleLabel = vccAddSignersTitleLabel;
    signers = [];
    signerSet = new Set();
    columns = columns;
    isLoading = true;

    @wire(MessageContext)
    messageContext;

    @api
    recordId;

    @api
    getSigners() {
        if (this.isLoading === true) {
            return false;
        }
        return [...this.signers];
    }

    connectedCallback() {
        this.refresh();
    }

    @api
    async refresh() {
        this.isLoading = true;
        let signers = await getSignersForRecord({ recordId: this.recordId });
        if (Array.isArray(signers)) {
            this.signers = signers;
            this.signerSet = new Set();
            let signersList = [];
            for (let signer of signers) {
                signersList.push(signer?.Name);
                this.signerSet.add(signer?.VCC_DUZ__c);
            }
            let updatedSigners = { selectedSigners: signersList };
            publish(this.messageContext, VCC_PROGRESS_NOTE_PACT_CHANNEL, updatedSigners);
        }
        this.isLoading = false;
    }

    @api
    async addSigners(vistaUsers) {
        if (!Array.isArray(vistaUsers)) {
            return;
        }
        this.isLoading = true;

        try {
            let vistaUsersToAdd = [];
            for (let vistaUser of vistaUsers) {
                if (!this.signerSet.has(vistaUser.VCC_StaffIEN__c)) {
                    vistaUsersToAdd.push(vistaUser);
                }
            }

            if (!(vistaUsersToAdd.length > 0)) {
                return;
            }

            let result = await addSignersToRecord({ vistaUserList: vistaUsersToAdd, recordId: this.recordId });

            if (result !== true) {
                const logger = this.template.querySelector('c-logger');
                logger.error(JSON.stringify(result));
                logger.saveLog();
            } else {
                await this.refresh();
            }
        } catch (e) {
            const logger = this.template.querySelector('c-logger');
            logger.error(JSON.stringify(e));
            logger.saveLog();
        } finally {
            this.isLoading = false;
        }
    }

    @api
    async removeSignerByName(provider) {
        let matchedSigners = this.signers.flatMap((signer) => {
            if (signer.Name === provider.providername) {
                return signer;
            } else {
                return [];
            }
        });
        if (matchedSigners.length === 0) {
            this.template.dispatchEvent(
                new CustomEvent('signerremoved', {
                    detail: {
                        signers: [{ Name: provider.providername }]
                    },
                    composed: true
                })
            );
            return;
        }
        return await this.removeSigners([matchedSigners[0]]);
    }

    @api
    async removeSigners(signers, loadingModalPromise) {
        if (!Array.isArray(signers)) {
            return;
        }
        this.isLoading = true;
        try {
            let result = await deleteSigners({ signers: signers });
            if (result !== true) {
                const logger = this.template.querySelector('c-logger');
                logger.error(JSON.stringify(result));
                logger.saveLog();
            } else {
                this.template.dispatchEvent(
                    new CustomEvent('signerremoved', {
                        detail: {
                            signers,
                            loadingModalPromise
                        },
                        composed: true
                    })
                );
                await this.refresh();
            }
        } catch (e) {
            const logger = this.template.querySelector('c-logger');
            logger.error(JSON.stringify(e));
            logger.saveLog();
        } finally {
            this.isLoading = false;
        }
    }
    timerId;
    async handleRowAction(evt) {
        evt.preventDefault();
        await this.setAsyncTimeout(async () => {
            let {
                action: { name },
                row
            } = evt.detail;
            let loadingModalPromise = openLoadingModal({
                actionDescription: 'Removing signer...'
            });
            switch (name) {
                case 'remove':
                    await this.removeSigners([row], loadingModalPromise);
                    break;
                default:
                    break;
            }
        }, 500);
    }

    setAsyncTimeout(debounceCallBack, timeout = 0) {
        return new Promise((resolve) => {
            clearTimeout(this.timerId);
            this.timerId = setTimeout(() => {
                debounceCallBack();
                resolve();
            }, timeout);
        });
    }
}
