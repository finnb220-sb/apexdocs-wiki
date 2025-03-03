const MAIL_CITY_FIELD_HELP =
    'Enter the city in which this applicant resides [2-15 characters]. If the space provided is not sufficient please abbreviate the city to the best of your ability.';
const MAIL_ZIP_FIELD_HELP =
    'Answer with either the 5 digit format (e.g. 12345) or the nine digit format (e.g. 12345-6789 or 123456789).';

export const states = [
    { label: '- Select -', value: '' },
    { label: 'Alabama', value: 'AL' },
    { label: 'Alaska', value: 'AK' },
    { label: 'Arizona', value: 'AZ' },
    { label: 'Arkansas', value: 'AR' },
    { label: 'California', value: 'CA' },
    { label: 'Colorado', value: 'CO' },
    { label: 'Connecticut', value: 'CT' },
    { label: 'Delaware', value: 'DE' },
    { label: 'District Of Columbia', value: 'DC' },
    { label: 'Florida', value: 'FL' },
    { label: 'Georgia', value: 'GA' },
    { label: 'Guam', value: 'GU' },
    { label: 'Hawaii', value: 'HI' },
    { label: 'Idaho', value: 'ID' },
    { label: 'Illinois', value: 'IL' },
    { label: 'Indiana', value: 'IN' },
    { label: 'Iowa', value: 'IA' },
    { label: 'Kansas', value: 'KS' },
    { label: 'Kentucky', value: 'KY' },
    { label: 'Louisiana', value: 'LA' },
    { label: 'Maine', value: 'ME' },
    { label: 'Maryland', value: 'MD' },
    { label: 'Massachusetts', value: 'MA' },
    { label: 'Michigan', value: 'MI' },
    { label: 'Minnesota', value: 'MN' },
    { label: 'Mississippi', value: 'MS' },
    { label: 'Missouri', value: 'MO' },
    { label: 'Montana', value: 'MT' },
    { label: 'Nebraska', value: 'NE' },
    { label: 'Nevada', value: 'NV' },
    { label: 'New Hampshire', value: 'NH' },
    { label: 'New Jersey', value: 'NJ' },
    { label: 'New Mexico', value: 'NM' },
    { label: 'New York', value: 'NY' },
    { label: 'North Carolina', value: 'NC' },
    { label: 'North Dakota', value: 'ND' },
    { label: 'Ohio', value: 'OH' },
    { label: 'Oklahoma', value: 'OK' },
    { label: 'Oregon', value: 'OR' },
    { label: 'Pennsylvania', value: 'PA' },
    { label: 'Puerto Rico', value: 'PR' },
    { label: 'Rhode Island', value: 'RI' },
    { label: 'South Carolina', value: 'SC' },
    { label: 'South Dakota', value: 'SD' },
    { label: 'Tennessee', value: 'TN' },
    { label: 'Texas', value: 'TX' },
    { label: 'Utah', value: 'UT' },
    { label: 'Vermont', value: 'VT' },
    { label: 'Virgin Islands', value: 'VI' },
    { label: 'Virginia', value: 'VA' },
    { label: 'Washington', value: 'WA' },
    { label: 'West Virginia', value: 'WV' },
    { label: 'Wisconsin', value: 'WI' },
    { label: 'Wyoming', value: 'WY' }
];

export const countries = [
    { label: 'United States', value: 'USA' },
    { label: 'Non-US Country', value: '' }
];

export const addressFields = {
    mail: [
        {
            key: 'street1',
            text: true,
            properties: {
                className: 'slds-col slds-size_1-of-1',
                label: 'Street Line 1',
                required: true,
                minLength: 3,
                maxLength: 35,
                pattern: '^[a-zA-Z0-9 /-#*,.()":;&#39;@&]*$'
            }
        },
        {
            key: 'street2',
            text: true,
            properties: {
                className: 'slds-col slds-size_1-of-2',
                label: 'Street Line 2',
                minLength: 3,
                maxLength: 30,
                pattern: '^[a-zA-Z0-9 /-#*,.()":;&#39;@&]*$'
            }
        },
        {
            key: 'street3',
            text: true,
            properties: {
                className: 'slds-col slds-size_1-of-2',
                label: 'Street Line 3',
                minLength: 3,
                maxLength: 30,
                pattern: '^[a-zA-Z0-9 /-#*,.()":;&#39;@&]*$'
            }
        },
        {
            key: 'city',
            text: true,
            properties: {
                className: 'slds-col slds-size_1-of-2',
                label: 'City',
                required: true,
                fieldLevelHelp: MAIL_CITY_FIELD_HELP,
                minLength: 2,
                maxLength: 15,
                pattern: '^[a-zA-Z0-9 /-#*,.()":;&#39;@&]*$'
            }
        },
        {
            key: 'state',
            combobox: true,
            properties: {
                className: 'slds-col slds-size_1-of-2',
                label: 'State',
                required: true,
                options: states,
                pattern: '^[a-zA-Z0-9 /-#*,.()":;&#39;@&]*$'
            }
        },
        {
            key: 'zipExt',
            text: true,
            properties: {
                className: 'slds-col slds-size_1-of-2',
                label: 'Zip Code',
                required: true,
                fieldLevelHelp: MAIL_ZIP_FIELD_HELP,
                minLength: 5,
                pattern: '[0-9]{5}(-?[0-9]{4})?'
            }
        },
        {
            key: 'country',
            combobox: true,
            properties: {
                className: 'slds-col slds-size_1-of-2',
                label: 'Country',
                options: countries,
                required: true,
                readOnly: true,
                pattern: '^[a-zA-Z0-9 /-#*,.()":;&#39;@&]*$'
            }
        }
    ]
};
