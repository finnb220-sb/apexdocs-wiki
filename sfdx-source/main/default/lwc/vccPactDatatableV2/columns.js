export const COLUMN_TEMPLATE = {
    teamMemberColumns: "teamMemberColumns",
    nonVAColumns: "nonVAColumns",
    cprs: "cprs"
};

export const teamMemberColumns = [
    { label: "Role", fieldName: "roleName" },
    {
        label: "Name",
        fieldName: "name",
        type: "button",
        scope: "col",
        typeAttributes: {
            label: { fieldName: "name" },
            title: "Click to view more",
            name: "displayStationDetails",
            variant: "base"
        }
    },
    { label: "Phone Number", fieldName: "phone" },
    { label: "Facility Name & Number", fieldName: "stationNameAndNumber" },
    { label: "Team Name", fieldName: "teamName" }
];

export const teamMemberTrunc = [
    { label: "Role", fieldName: "roleName" },
    {
        label: "Name",
        fieldName: "name",
        type: "button",
        scope: "col",
        typeAttributes: {
            label: { fieldName: "name" },
            title: "Click to view more",
            name: "displayStationDetails",
            variant: "base"
        }
    },
    { label: "Facility Name & Number", fieldName: "stationNameAndNumber" },
    { label: "Phone Number", fieldName: "phone" }
];

export const nonVAColumns = [
    {
        label: "Name",
        fieldName: "providerName",
        type: "button",
        scope: "col",
        typeAttributes: {
            label: { fieldName: "providerName" },
            title: "Click to view more",
            name: "displayStationDetails",
            variant: "base"
        }
    },
    { label: "Speciality", fieldName: "specialtyName" },
    { label: "Phone Number", fieldName: "phone" },
    { label: "City/State", fieldName: "city" },
    { label: "Team Name", fieldName: "teamName" }
];
