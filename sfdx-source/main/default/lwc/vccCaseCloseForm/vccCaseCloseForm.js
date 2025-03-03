import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { FlowNavigationFinishEvent } from 'lightning/flowSupport';
import { FIELDS_BY } from './constants';

export default class VccCaseCloseForm extends LightningElement {
    @api
    caseInfo;

    @api
    taskCheck;

    @api
    unsignedProgressNotes;

    isLoading = true;

    // Store updatable field attributes from CONSTANTS
    fieldArray = [];

    // HTML translated iterable variable to display workstream specific field configurations
    @track
    fields = [];

    // Map field api value to index in this.fields array
    apiMap = {};
    _caseRT;
    @api
    getcaseRT() {
        return this._caseRT;
    }
    setcaseRT(value) {
        this._caseRT = value;
    }
    connectedCallback() {
        this.caseRT = this.caseInfo?.recordTypeDeveloperName;

        // Get Field Mapping
        switch (this.caseRT) {
            case 'VCC_Clinical_Triage':
            case 'VCC_Vitrual_Clinic_Visit':
            case 'VCC_Pharmacy':
            case 'VCC_Administrative':
                this.fieldArray = JSON.parse(JSON.stringify(FIELDS_BY[this.caseRT]));
                break;
            default:
                this.template.dispatchEvent(
                    new ShowToastEvent({
                        message:
                            'Component, vcc-case-close-form, is not configured for this Case Record Type: ' +
                            this.caseRT +
                            '.',
                        variant: 'error',
                        mode: 'sticky'
                    })
                );
        }

        this.mapFieldToIndex(this.fieldArray);

        switch (this.caseRT) {
            case 'VCC_Pharmacy':
                if (this.taskCheck) {
                    this.setFieldTo('Status', 'disabled', 'Pending Future Renewal Request');
                }
                break;
            default:
                break;
        }

        this.fields = this.convertToColumns(this.fieldArray);
    }

    // Create map index for easier parsing / update to this.fieldArray
    mapFieldToIndex(fA) {
        this.apiMap = {};
        fA.forEach((f, i) => (this.apiMap[f.api] = i));
    }

    // Convert to an array (sections) of objects containing list of items (fields) & CSS grid style variables
    // fields = [{key:0, rows:[XA, ... XY], cols:Y, style:'--grid-rows:XX; --grid-cols:YY', items:[field1, field2, {}, etc.]}, ...]
    convertToColumns(fA) {
        let maxCols = 2;
        let fields = [{ key: 0, rows: [0], cols: 1, items: [] }];

        let sections = 0; // current section key
        let rows = 0; // current number of rows for this column
        let cols = 1; // number of columns in this section, up to maxCols before a new section is created
        let lastType; // when field has onecolumn, then it is 1/1, otherwise 1/2, helps determine if new section is needed
        fA.forEach((f) => {
            if (f.visible) {
                // Determine if new section is required
                if (
                    lastType &&
                    ((lastType === '1/2' && f.onecolumn) || // Going from two columns to one column
                        (lastType === '1/1' && !f.onecolumn) || // Going from a one column section to two columns
                        (cols === maxCols && f.newcolumn)) // Adding a column beyond maximum
                ) {
                    sections++;
                    cols = 1;
                    rows = 0;
                    fields.push({ key: sections, rows: [0], cols: cols, items: [] });
                }
                // Determine if new column is required
                else if (lastType && f.newcolumn) {
                    cols++;
                    rows = 0;
                    fields[fields.length - 1].rows.push(0);
                }

                // Add enriched field to section's items array
                f.inputclass = f.onecolumn ? 'slds-form-element_1-col' : '';
                fields[fields.length - 1].items.push(f);

                // Loop variable updates
                lastType = f.onecolumn ? '1/1' : '1/2';

                fields[fields.length - 1].cols = cols;

                rows++; // Update rows tracking variable and current row count
                let fri = fields[fields.length - 1].rows.length - 1;
                fields[fields.length - 1].rows[fri] = rows;
            }
        });

        // Set section CSS variables via style attribute
        fields.forEach((e) => {
            e.style = `--grid-rows:${Math.max(...e.rows)}; --grid-cols:${e.cols}`;
        });

        // Add blank fields in the other columns when a non-first column is longer
        fields.forEach((e) => {
            let rowMax = Math.max(...e.rows);
            let blankKey = 0;
            let itemIndex = e.items.length - 1;
            if (e.rows.length >= 2) {
                for (let revInd = e.rows.length - 1; revInd >= 0; revInd--) {
                    itemIndex -= e.rows[revInd];
                    if (revInd !== e.rows.length - 1) {
                        let r = e.rows[revInd];
                        if (r < rowMax) {
                            let addcount = rowMax - r;
                            //disabled because of error "Function declared in a loop contains unsafe references to variables 'blankKey'"
                            /* eslint-disable */
                            e.items.splice(
                                itemIndex + r + 1,
                                0,
                                ...[...Array(addcount).keys()].map((a) => ({
                                    blank: true,
                                    api: '_autoblank' + (1 + a + blankKey)
                                }))
                            );
                            blankKey += addcount;
                            /* eslint-enable */
                        }
                    }
                }
            }
        });

        return fields;
    }

    // Grab the value of the dom lightning-input-field by API
    getFieldValue(fieldAPI) {
        let domField = this.template.querySelector('lightning-input-field[data-field="' + fieldAPI + '"]');
        return domField ? domField.value : undefined;
    }

    // Accept a csv of field attributes and/or a value to set the field to
    setFieldTo(fieldAPI, actionsCSV, value) {
        let domField = this.template.querySelector('lightning-input-field[data-field="' + fieldAPI + '"]');

        if (actionsCSV) {
            let strActionsCSV = '' + actionsCSV;
            let actions = strActionsCSV.split(',').map((e) => e?.trim());
            actions.forEach((a) => {
                let act = a?.toLowerCase();
                let actKey = act?.slice(0, 4) === 'not-' ? act?.slice(4) : act;
                let result = act?.slice(0, 4) !== 'not-';
                switch (act) {
                    case 'visible':
                    case 'required':
                    case 'readonly':
                    case 'disabled':
                    case 'not-visible':
                    case 'not-required':
                    case 'not-readonly':
                    case 'not-disabled':
                        this.fieldArray[this.apiMap[fieldAPI]][actKey] = result;
                        break;
                    case 'reset':
                        if (domField) {
                            domField.reset();
                        }
                        delete this.fieldArray[this.apiMap[fieldAPI]].value;
                        break;
                    default:
                        break;
                }
            });
        }

        if (value !== undefined) {
            if (domField) {
                domField.value = value;
            }
            this.fieldArray[this.apiMap[fieldAPI]].value = value;
        }
    }

    validateFields() {
        let domFields = this.template.querySelectorAll('lightning-input-field');
        //supressing eslint error because impact of timeout is unknown
        // eslint-disable-next-line
        setTimeout(() => domFields.forEach((e) => e && e.reportValidity()), 0);
    }

    // Define common / workstream specific onchange events, matched on the constants file
    handleChange(event) {
        let domElem = event?.target;
        let newValue = domElem?.value;
        switch (event?.target?.dataset?.event) {
            case 'status':
                this.fieldArray[this.apiMap.VCC_Opened_in_Error__c].visible = newValue === 'Opened in Error';
                if (newValue === 'Opened in Error' && this.caseRT !== 'VCC_Administrative') {
                    this.setFieldTo('VCC_Opened_in_Error__c', 'visible');
                    [
                        'VCC_Case_Outcome__c',
                        'VCC_Other_Case_Outcome__c',
                        'VCC_Case_Sub_Type__c',
                        'VCC_Case_Reason__c',
                        'VCC_Other_Case_Reason__c',
                        'VCC_Follow_Up_Appt_Needed__c',
                        'VCC_Medication_Name__c',
                        'VCC_Recommended_Preferred_Appt_Modality__c',
                        'VCC_Appointment_Service__c'
                    ].forEach((e) => this.setFieldTo(e, 'not-visible'));
                } else {
                    ['VCC_Opened_in_Error__c', 'VCC_Other_Information__c'].forEach((e) =>
                        this.setFieldTo(e, 'not-visible')
                    );
                    [
                        'VCC_Case_Outcome__c',
                        'VCC_Case_Sub_Type__c',
                        'VCC_Case_Reason__c',
                        'VCC_Follow_Up_Appt_Needed__c'
                    ].forEach((e) => this.setFieldTo(e, 'visible'));
                }

                this.validateFields();

                break;

            //Need to create a new condition for vcv cases because case reason is not being utilized for vcv
            case 'status_vcv':
                this.fieldArray[this.apiMap.VCC_Opened_in_Error__c].visible = newValue === 'Opened in Error';
                if (newValue === 'Opened in Error') {
                    this.setFieldTo('VCC_Opened_in_Error__c', 'visible');
                    [
                        'VCC_Case_Outcome__c',
                        'VCC_Other_Case_Outcome__c',
                        'VCC_Case_Sub_Type__c',
                        'VCC_Follow_Up_Appt_Needed__c'
                    ].forEach((e) => this.setFieldTo(e, 'not-visible'));
                } else {
                    ['VCC_Opened_in_Error__c', 'VCC_Other_Information__c', 'VCC_Follow_Up_Appt_Needed__c'].forEach(
                        (e) => this.setFieldTo(e, 'not-visible')
                    );
                    ['VCC_Case_Outcome__c', 'VCC_Case_Sub_Type__c'].forEach((e) => this.setFieldTo(e, 'visible'));
                }

                this.validateFields();
                break;

            case 'status_admin':
                if (newValue === 'Opened in Error') {
                    this.setFieldTo('VCC_Opened_in_Error__c', 'visible');
                    [
                        'VCC_Case_Outcome_Multi__c',
                        'VCC_Other_Case_Outcome__c',
                        'VCC_Case_Sub_Type__c',
                        'VCC_Case_Reason_Multi__c',
                        'VCC_Other_Case_Reason__c',
                        'VCC_Medication_Name__c',
                        'VCC_Cannot_Comp_Scheduling_Action_Reason__c',
                        'VCC_Requested_Services_Multi__c',
                        'VCC_Mental_Health_Appointment__c',
                        'VCC_Specialty_Community_Care_Requested__c'
                    ].forEach((e) => this.setFieldTo(e, 'not-visible'));
                } else {
                    ['VCC_Opened_in_Error__c', 'VCC_Other_Information__c'].forEach((e) =>
                        this.setFieldTo(e, 'not-visible')
                    );
                    ['VCC_Case_Outcome_Multi__c', 'VCC_Case_Sub_Type__c', 'VCC_Case_Reason_Multi__c'].forEach((e) =>
                        this.setFieldTo(e, 'visible')
                    );
                }
                this.validateFields();

                break;

            case 'status_pharm':
                if (newValue === 'Opened in Error') {
                    this.setFieldTo('VCC_Opened_in_Error__c', 'visible');
                    [
                        'VCC_Case_Outcome_Multi__c',
                        'VCC_Other_Case_Outcome__c',
                        'VCC_Case_Sub_Type__c',
                        'VCC_Case_Reason_Multi__c',
                        'VCC_Other_Case_Reason__c',
                        'VCC_Medication_Name__c'
                    ].forEach((e) => this.setFieldTo(e, 'not-visible'));
                } else {
                    ['VCC_Opened_in_Error__c', 'VCC_Other_Information__c'].forEach((e) =>
                        this.setFieldTo(e, 'not-visible')
                    );
                    ['VCC_Case_Outcome_Multi__c', 'VCC_Case_Sub_Type__c', 'VCC_Case_Reason_Multi__c'].forEach((e) =>
                        this.setFieldTo(e, 'visible')
                    );
                }
                this.validateFields();
                break;
            case 'case_sub_type':
                this.setFieldTo('VCC_Case_Reason__c', undefined, '');
                this.setFieldTo('VCC_Other_Case_Reason__c', 'not-visible');
                this.fieldArray[this.apiMap.VCC_Medication_Name__c].visible = newValue.includes(
                    'Pharmacy Quality Assurance Issue'
                );
                this.fieldArray[this.apiMap.VCC_Medication_Name__c].required = newValue.includes(
                    'Pharmacy Quality Assurance Issue'
                );
                break;
            case 'case_sub_type_multi':
                this.setFieldTo('VCC_Case_Reason_Multi__c', undefined, '');
                this.setFieldTo('VCC_Other_Case_Reason__c', 'not-visible');
                this.fieldArray[this.apiMap.VCC_Medication_Name__c].required = newValue.includes(
                    'Pharmacy Quality Assurance Issue'
                );
                break;
            case 'case_sub_type_msa':
                this.setFieldTo('VCC_Case_Reason_Multi__c', undefined, '');
                this.setFieldTo('VCC_Other_Case_Reason__c', 'not-visible');
                this.fieldArray[this.apiMap.VCC_Medication_Name__c].visible = newValue.includes(
                    'Pharmacy Quality Assurance Issue'
                );
                this.fieldArray[this.apiMap.VCC_Medication_Name__c].required = newValue.includes(
                    'Pharmacy Quality Assurance Issue'
                );
                break;
            case 'case_reason':
                this.fieldArray[this.apiMap.VCC_Other_Case_Reason__c].visible = newValue.includes('Other');
                break;
            case 'case_outcome':
                this.fieldArray[this.apiMap.VCC_Other_Case_Outcome__c].visible = newValue.includes('Other');
                break;
            case 'follow_up_needed':
                this.fieldArray[this.apiMap.VCC_Recommended_Preferred_Appt_Modality__c].visible = !!newValue;
                this.fieldArray[this.apiMap.VCC_Appointment_Service__c].visible = !!newValue;
                break;
            case 'case_outcome_multi_msa':
                this.fieldArray[this.apiMap.VCC_Other_Case_Outcome__c].visible = newValue.includes('Other');
                this.fieldArray[this.apiMap.VCC_Cannot_Comp_Scheduling_Action_Reason__c].visible = newValue.includes(
                    'Cannot Complete Scheduling Action'
                );
                this.fieldArray[this.apiMap.VCC_Requested_Services_Multi__c].visible = newValue.includes(
                    'Cannot Complete Scheduling Action'
                );
                break;
            case 'case_reason_multi_msa':
                this.fieldArray[this.apiMap.VCC_Other_Case_Reason__c].visible = newValue.includes('Other');
                this.fieldArray[this.apiMap.VCC_Mental_Health_Appointment__c].visible =
                    newValue.includes('Cancel Appointment');
                break;
            case 'requested_service':
                this.fieldArray[this.apiMap.VCC_Specialty_Community_Care_Requested__c].visible =
                    newValue.includes('Community Care') || newValue.includes('Specialty Care');
                break;
            case 'opened_in_error':
                this.fieldArray[this.apiMap.VCC_Other_Information__c].visible = newValue === 'Other';
                break;
            default:
                break;
        }

        this.fields = this.convertToColumns(this.fieldArray);
    }

    handleFormLoad() {
        this.isLoading = false;

        // Processing Depending on Case record info, by workstream
        switch (this.caseInfo?.recordTypeDeveloperName) {
            case 'VCC_Clinical_Triage': {
                // Make Subject read-only, not required, when it is populated for CT
                let f = this.fieldArray[this.apiMap.Subject];
                f.readonly = !!this.caseInfo?.subject;
                f.required = !f.readonly;

                this.loadFollowUpFields();
                break;
            }
            case 'VCC_Vitrual_Clinic_Visit':
                this.loadFollowUpFields();
                break;
            case 'VCC_Administrative':
                this.loadMSAFollowUpValues();

                break;
            default:
                break;
        }

        // Common on load checks to maintain UI dependencies
        if (
            this.getFieldValue('VCC_Case_Outcome__c') === 'Other' ||
            this.getFieldValue('VCC_Case_Outcome_Multi__c') === 'Other'
        ) {
            this.setFieldTo('VCC_Other_Case_Outcome__c', 'visible');
        }
        if (
            this.getFieldValue('VCC_Case_Reason__c') === 'Other' ||
            this.getFieldValue('VCC_Case_Reason_Multi__c') === 'Other'
        ) {
            this.setFieldTo('VCC_Other_Case_Reason__c', 'visible');
        }

        if (this.getFieldValue('VCC_Opened_in_Error__c') && this.getFieldValue('VCC_Opened_in_Error__c') === 'Other') {
            this.setFieldTo('VCC_Other_Information__c', 'visible');
        }

        if (
            this.getFieldValue('VCC_Case_Sub_Type__c') &&
            this.getFieldValue('VCC_Case_Sub_Type__c') === 'Pharmacy Quality Assurance Issue'
        ) {
            this.setFieldTo('VCC_Medication_Name__c', 'visible');
            this.setFieldTo('VCC_Medication_Name__c', 'required');
        }

        this.fields = this.convertToColumns(this.fieldArray);
    }

    handleSubmit() {
        this.isLoading = true;
    }

    handleSuccess() {
        this.template.dispatchEvent(new FlowNavigationFinishEvent());
        this.isLoading = false;
    }

    handleError() {
        this.isLoading = false;
    }

    handleSave(e) {
        let statusField = this.template.querySelector('lightning-input-field[data-field="Status"]');
        if (statusField?.value === 'Open' || statusField?.value === 'New') {
            this.template.dispatchEvent(
                new ShowToastEvent({
                    message: 'Case Status must be "Closed"',
                    variant: 'error'
                })
            );
            e.preventDefault();
            e.stopPropagation();
        }
    }

    loadFollowUpFields() {
        if (this.getFieldValue('VCC_Follow_Up_Appt_Needed__c')) {
            ['VCC_Recommended_Preferred_Appt_Modality__c', 'VCC_Appointment_Service__c'].forEach((e) =>
                this.setFieldTo(e, 'visible')
            );
        }

        if (this.getFieldValue('VCC_Case_Sub_Type__c') === 'Pharmacy Quality Assurance Issue') {
            this.setFieldTo('VCC_Medication_Name__c', 'visible');
        }
    }

    loadMSAFollowUpValues() {
        if (
            this.getFieldValue('VCC_Case_Outcome_Multi__c') &&
            this.getFieldValue('VCC_Case_Outcome_Multi__c').includes('Cannot Complete Scheduling Action')
        ) {
            ['VCC_Requested_Services_Multi__c', 'VCC_Cannot_Comp_Scheduling_Action_Reason__c'].forEach((e) =>
                this.setFieldTo(e, 'visible')
            );
        }
        if (
            this.getFieldValue('VCC_Case_Outcome_Multi__c') &&
            this.getFieldValue('VCC_Case_Outcome_Multi__c').includes('Other')
        ) {
            this.setFieldTo('VCC_Other_Case_Outcome__c', 'visible');
        }

        if (
            this.getFieldValue('VCC_Case_Reason_Multi__c') &&
            this.getFieldValue('VCC_Case_Reason_Multi__c').includes('Other')
        ) {
            this.setFieldTo('VCC_Other_Case_Reason__c', 'visible');
        }

        if (
            this.getFieldValue('VCC_Case_Sub_Type__c') &&
            this.getFieldValue('VCC_Case_Sub_Type__c') === 'Pharmacy Quality Assurance Issue'
        ) {
            this.setFieldTo('VCC_Medication_Name__c', 'visible');
        }

        if (
            this.getFieldValue('VCC_Case_Reason_Multi__c') &&
            this.getFieldValue('VCC_Case_Reason_Multi__c').includes('Cancel Appointment')
        ) {
            this.setFieldTo('VCC_Mental_Health_Appointment__c', 'visible');
        }

        if (
            this.getFieldValue('VCC_Requested_Services_Multi__c') &&
            this.getFieldValue('VCC_Requested_Services_Multi__c').includes('Specialty Care')
        ) {
            this.setFieldTo('VCC_Specialty_Community_Care_Requested__c', 'visible');
        }

        if (
            this.getFieldValue('VCC_Requested_Services_Multi__c') &&
            this.getFieldValue('VCC_Requested_Services_Multi__c').includes('Community Care')
        ) {
            this.setFieldTo('VCC_Specialty_Community_Care_Requested__c', 'visible');
        }
    }
}
