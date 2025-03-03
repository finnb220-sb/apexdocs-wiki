/**
 * @author Booz Allen Hamilton
 * @description Extension of LightningModal that formats the given list of flags into text for the user to review and acknowledge
 * @see vccFlagsModalLauncher
 * @see vccOnPersonAccountRead
 * @see vccFlags
 */
import LightningModal from 'lightning/modal';
import { api } from 'lwc';
import acknowledgeFlag from '@salesforce/apex/VCC_FlagsController.acknowledgeFlag';
import vccFlagPatientLabel from '@salesforce/label/c.VCC_Flag_Patient_Warning_Message';

const NEW_LINE = '\n';
const SPACE = ' ';
const MODAL_ASSIGNMENT_NARRATIVE = 'Assignment Narrative';
const MODAL_STRING_LABEL_TOKEN = '{0}';
const LABEL = 'Flag Acknowledgement';

export default class vccFlagsModal extends LightningModal {
    disableClose = true;
    isLoading = true;
    @api label = LABEL;
    @api recordId;
    size = 'small';
    textContents;
    @api flagsList = [];
    initialized = false;

    renderedCallback() {
        if (this.initialized === true) {
            return;
        }
        if (!Array.isArray(this.flagsList) || this.flagsList.length === 0) {
            return;
        }
        this.textContents = vccFlagPatientLabel.replace(
            MODAL_STRING_LABEL_TOKEN,
            this.calculateModalBody(this.flagsList)
        );
        this.refs?.header?.focus();
        this.initialized = true;
        this.isLoading = false;
    }

    async handleAcknowledgeClick() {
        this.isLoading = true;
        this.disableClose = false;
        await acknowledgeFlag({ recordId: this.recordId });
        this.close();
    }

    /**
     * @description Uses list of flag records to build a message for the flags modal body
     * - Each flag is processed by the `makeMessageForFlagRecord` function.
     * - The list of messages is joined together by carriage returns.
     * - Empty messages are ignored.
     * @param records A list of flag records
     * @return {string} A string to display in the flags modal.
     * @example
     * // returns 'TEST FLAG1\n Assignment Narrative\n SOME CONTENT1\n \nTEST FLAG2\n Assignment Narrative\n MORE CONTENT\n '
     * const flags = [
     *  {flagName: 'TEST FLAG1', content: {content: 'SOME CONTENT'}},
     *  {flagName: 'TEST FLAG2', content: {content: 'MORE CONTENT'}}
     * ];
     * const result = this.calculateModalBody(flags);
     */
    calculateModalBody(records = []) {
        const lines = records.map(this.makeMessageForFlagRecord).filter((line) => !!line);
        return lines.length > 0 ? NEW_LINE + lines.join(NEW_LINE) : '';
    }

    /**
     * @description Builds a message for a single flag record, using the flag name, the standard text "Assignment Narrative" and the flag's content.
     * - Each piece (flag name, assignment narrative, content) is followed by a new line and a space.
     * - A record with a null 'flagName' or null value at 'content.content' is ignored.
     * @param record A flag record
     * @return {string} The built message
     * @example
     * // returns 'TEST FLAG\n Assignment Narrative\n SOME CONTENT\n '
     * const flag = {flagName: 'TEST FLAG', content: {content: 'SOME CONTENT'}};
     * const message = this.makeMessageForFlagRecord(flag);
     */
    makeMessageForFlagRecord(record = {}) {
        if (!record?.flagName || !record?.content?.content) {
            return '';
        }
        let parts = [
            record?.flagName,
            NEW_LINE,
            SPACE,
            MODAL_ASSIGNMENT_NARRATIVE,
            NEW_LINE,
            SPACE,
            record?.content?.content,
            NEW_LINE,
            SPACE
        ];
        return parts.join('');
    }
}
