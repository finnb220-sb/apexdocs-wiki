/**
 * @description Developer defined variables for Case Close Form
 */

/** Object of fields for lightning-record-edit-form by workstream
 * Key is the Case RecordType Developer Name
 * Value is an array of custom objects holding field definitions
 * -- Key - Value Description
 * -- visible - Boolean: Determines whether to display the field
 * -- blank - Boolean: True value holds a blank space in the column
 * -- api - String*: Case object's field api value *REQUIRED - can be '_blank', '_blank1', '_blank2', etc*
 * -- onchangeevent - String: Specifies which onchange switch function to run
 * -- readonly - Boolean: Makes the field read-only
 * -- disabled - Boolean: Makes the field disabled
 * -- required - Boolean: Makes the field required
 * -- newcolumn - Boolean: Defines a new column / section and sets that field at the top of that column / section
 * -- onecolumn - Boolean: Sets the field in a single column in the grid row
 * -- value - String: String representation of lightning-input-field value override
 *
 * Array of field objects are displayed top down, then down, in a 2 column grid
 */
export const FIELDS_BY = {
    VCC_Pharmacy: [
        { visible: true, api: 'Subject', readonly: true },
        { visible: true, api: 'VCC_Case_Type__c', readonly: true },
        { visible: true, api: 'VCC_Case_Sub_Type__c', onchangeevent: 'case_sub_type_multi', required: true },

        { newcolumn: true, visible: true, api: 'Status', onchangeevent: 'status_pharm', required: true },
        { visible: false, api: 'VCC_Opened_in_Error__c', required: true, onchangeevent: 'opened_in_error' },
        { visible: false, api: 'VCC_Other_Information__c', required: true },

        {
            onecolumn: true,
            visible: true,
            api: 'VCC_Case_Reason_Multi__c',
            onchangeevent: 'case_reason',
            required: true
        },
        { onecolumn: true, visible: false, api: 'VCC_Other_Case_Reason__c', required: true },

        { newcolumn: true, visible: true, api: 'VCC_Medication_Name__c', required: false },
        {
            onecolumn: true,
            visible: true,
            api: 'VCC_Case_Outcome_Multi__c',
            onchangeevent: 'case_outcome',
            required: true
        },
        { visible: false, api: 'VCC_Other_Case_Outcome__c', required: true }
    ],

    VCC_Clinical_Triage: [
        { visible: true, api: 'Subject', required: true },
        { visible: true, api: 'VCC_Case_Type__c', readonly: true },
        { visible: true, api: 'VCC_Case_Sub_Type__c', onchangeevent: 'case_sub_type', required: true },
        { visible: true, api: 'VCC_Case_Reason__c', onchangeevent: 'case_reason', required: true },
        { visible: false, api: 'VCC_Other_Case_Reason__c', required: true },
        { visible: false, api: 'VCC_Medication_Name__c', readonly: false },

        { newcolumn: true, visible: true, api: 'Status', onchangeevent: 'status', required: true },
        { visible: false, api: 'VCC_Opened_in_Error__c', required: true, onchangeevent: 'opened_in_error' },
        { visible: false, api: 'VCC_Other_Information__c', required: true },
        { visible: true, api: 'VCC_Follow_Up_Appt_Needed__c', onchangeevent: 'follow_up_needed' },
        { visible: false, api: 'VCC_Recommended_Preferred_Appt_Modality__c', required: true },
        { visible: false, api: 'VCC_Appointment_Service__c', required: true },
        { visible: true, api: 'VCC_Case_Outcome__c', onchangeevent: 'case_outcome', required: true },
        { visible: false, api: 'VCC_Other_Case_Outcome__c', required: true }
    ],

    VCC_Vitrual_Clinic_Visit: [
        { visible: true, api: 'Subject', required: true },
        { visible: true, api: 'VCC_Case_Type__c', required: true, readonly: true },
        { visible: true, api: 'VCC_Case_Sub_Type__c', required: true },

        { newcolumn: true, visible: true, api: 'Status', onchangeevent: 'status_vcv', required: true },
        { visible: false, api: 'VCC_Opened_in_Error__c', required: true, onchangeevent: 'opened_in_error' },

        { visible: false, api: 'VCC_Follow_Up_Appt_Needed__c' },

        { visible: true, api: 'VCC_Case_Outcome__c', onchangeevent: 'case_outcome', required: true },
        { visible: false, api: 'VCC_Other_Case_Outcome__c', required: true },

        { visible: false, api: 'VCC_Other_Information__c', required: true },

        { visible: false, api: 'VCC_Case_Reason__c', onchangeevent: 'case_reason', required: false, disabled: true },

        { visible: false, api: 'VCC_Other_Case_Reason__c', required: true },
        { visible: false, api: 'VCC_Recommended_Preferred_Appt_Modality__c', required: true },
        { visible: false, api: 'VCC_Appointment_Service__c', required: true }
    ],
    VCC_Administrative: [
        { visible: true, api: 'Subject', required: true },
        { visible: true, api: 'Status', onchangeevent: 'status_admin', required: true },
        { visible: false, api: 'VCC_Opened_in_Error__c', required: true, onchangeevent: 'opened_in_error' },
        { visible: false, api: 'VCC_Other_Information__c', required: true },

        { newcolumn: true, visible: true, api: 'VCC_Case_Type__c', readonly: true },

        {
            visible: true,
            api: 'VCC_Case_Sub_Type__c',
            onchangeevent: 'case_sub_type_msa',
            required: true,
            readonly: false
        },

        {
            newcolumn: true,
            visible: true,
            api: 'VCC_Case_Reason_Multi__c',
            onchangeevent: 'case_reason_multi_msa',
            required: true,
            onecolumn: true
        },
        { visible: false, api: 'VCC_Medication_Name__c', onecolumn: true },
        { visible: false, api: 'VCC_Other_Case_Reason__c', required: true, onecolumn: true },
        { visible: false, api: 'VCC_Mental_Health_Appointment__c', required: true, onecolumn: true },
        {
            visible: true,
            api: 'VCC_Case_Outcome_Multi__c',
            onchangeevent: 'case_outcome_multi_msa',
            required: true,
            onecolumn: true
        },
        { visible: false, api: 'VCC_Other_Case_Outcome__c', required: true, onecolumn: true },
        { visible: false, api: 'VCC_Cannot_Comp_Scheduling_Action_Reason__c', required: true, onecolumn: true },
        {
            visible: false,
            api: 'VCC_Requested_Services_Multi__c',
            required: true,
            onchangeevent: 'requested_service',
            onecolumn: true
        },
        { visible: false, api: 'VCC_Specialty_Community_Care_Requested__c', required: true, onecolumn: true }
    ]
};
