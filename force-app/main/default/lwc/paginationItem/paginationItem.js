// disabling es lint rules below as this is legacy code, we need to revisit these at a future time
/* eslint-disable consistent-return */
/* eslint-disable no-unused-expressions */
/* eslint-disable no-useless-escape */
import { LightningElement, api, track } from 'lwc';
import { getAddendums, fetchAddSigners, formatDate, arrErrors } from './paginationItemHelper';
import hasTestingErrorCustompPerm from '@salesforce/customPermission/VAHC_Error_Testing';
import testMessage from '@salesforce/label/c.VAHC_No_Add_Signers_Err';
const SPACE_STRING = ' ';
const COMMA_STRING = ',';
const BLANK_STRING = '';
const FOR_STRING = ' FOR ';
const YES_STRING = 'YES';
const SURROGATE_DEFAULT = 'SURROGATE SIGNER';
const NEW_LINE_AND_TAB = '\n\t';

export default class PaginationItem extends LightningElement {
    @api display;
    @api recordId;
    @api context;
    @track displayCopy;
    loading;
    @track additionalSigners = [];
    @track additionalAndSurrogateSigners = [];
    @track additionalSignersAvailable = false;
    @track addendums = [];
    activeSections = ['Signers', 'Content', 'Addendums']; //accordian Salesforce
    @track displayMessage;
    @track exceptionMessage;
    @track noteSigner;

    /**
     * @description connected callback to get additional signers, adendums, and turn off loading
     */
    async connectedCallback() {
        this.loading = true;
        this.context && this.display;
        this.getProgressNotesAdditionalSigners();
        this.addendums = await getAddendums(this.display?.documents, {
            id: this.context.id,
            sObject: this.context.sObject,
            assigningFacility: this.display?.facilityCode.substring(0, 3),
            assigningAuthority: 'USVHA',
            nationalId: this.context?.id
        });
        this.loading = false;
    }

    /**
     * @description method that gets additional signers for a progress note
     */
    async getProgressNotesAdditionalSigners() {
        try {
            const document = this.display?.id?.split(':')?.slice(-1);
            this.additionalSigners = await fetchAddSigners({
                assigningFacility: this.display?.facilityCode.substring(0, 3),
                id: this.context?.id,
                sObject: this.context?.sObject,
                documents: document,
                assigningAuthority: 'USVHA',
                nationalId: this.context?.id
            });

            if (Array.isArray(arrErrors) && arrErrors.length > 0) {
                this.exceptionMessage = arrErrors[0]?.exceptionMessage;
                this.displayMessage = arrErrors[0]?.displayMessage;
                if (document[0].match(/([0-9a-zA-Z\-_;:\|]+)/g).length !== 1) {
                    this.exceptionMessage = `Additional signers unavailable for document type "${this.display?.typeName}" with uid "${this.display?.id}"`;
                }
                while (arrErrors.length > 0) {
                    //CCCM-22954 flush errors so that we don't see the same one again
                    arrErrors.shift();
                }
            }

            if (hasTestingErrorCustompPerm) {
                this.exceptionMessage = testMessage.split('|')[0];
                this.displayMessage = testMessage.split('|')[1];
                this.additionalSignerError = true;
            }

            this.additionalSignersAvailable =
                !Array.isArray(this.additionalSigners) || this.additionalSigners.length === 0;
        } catch (err) {
            this.additionalSigners = null;
            console.error(err);
        }
    }

    /**
     * @description getter for formatted date
     */
    @api get formattedDate() {
        try {
            return formatDate(this.display.referenceDateTime);
        } catch (err) {
            return '\u2014';
        }
    }

    /**
     * @description getter for content
     */
    @api get content() {
        let textString = this.display.documents[0].content;
        //fix <br> tag displaying in address
        const finalText = textString.replace('<br>', '');
        return finalText;
    }

    /**
     * @description getter for clinicians
     */
    @api get clinicians() {
        return this.display.clinicians;
    }

    /**
     * @description getter to determine if addendums exist
     */
    get hasAddendums() {
        return this.addendums?.length;
    }

    /**
     * @description getter to determine if additional signers exist
     */
    get hasAdditionalSigners() {
        if (Array.isArray(this.additionalSigners) && this.additionalSigners.length > 0) {
            this.processAdditionalAndSurrogateSigners();
            return true;
        }
        return false;
    }

    /**
     * @description helper method to handle surrogate signers logic
     */
    processAdditionalAndSurrogateSigners() {
        var practitionerName;
        var surrogateName = SURROGATE_DEFAULT;
        this.additionalSigners.forEach((signer) => {
            let formattedSigner = {
                // OR is to account for when something might be null or undefined
                name:
                    (signer.family || BLANK_STRING) +
                    COMMA_STRING +
                    (signer.given || BLANK_STRING) +
                    SPACE_STRING +
                    (signer.middle || BLANK_STRING),
                title: signer.signatureBlockTitle,
                date: signer.date
            };
            if (signer.signedBySurrogate === YES_STRING) {
                if (signer?.preFormatted?.signer?.practitioner?.name) {
                    practitionerName = signer.preFormatted.signer.practitioner.name;
                    surrogateName =
                        (practitionerName.family || BLANK_STRING) +
                        COMMA_STRING +
                        (practitionerName.given || BLANK_STRING) +
                        SPACE_STRING +
                        (practitionerName.middle || BLANK_STRING);
                }
                formattedSigner.name = surrogateName + FOR_STRING + NEW_LINE_AND_TAB + formattedSigner.name;
            }
            this.additionalAndSurrogateSigners.push(formattedSigner);
        });
    }
}
