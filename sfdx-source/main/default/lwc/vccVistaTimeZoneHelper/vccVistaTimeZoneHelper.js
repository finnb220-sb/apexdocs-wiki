/**
 * @description This js file is used to convert VistA Time Zone values to Time Zone values acceptable to Salesforce.
 */
const vistaTimeZoneMap = {
    ATLANTIC: 'America/Halifax',
    EASTERN: 'America/New_York',
    CENTRAL: 'America/Chicago',
    FERNANDO_DE_NORONHA: 'America/Noronha',
    ACRE: 'America/Rio_Branco',
    AMAZON: 'America/Manaus',
    BRASILIA: 'America/Sao_Paulo',
    MOUNTAIN: 'America/Denver',
    NEWFOUNDLAND: 'America/St_Johns',
    PACIFIC: 'America/Los_Angeles',
    ALASKA: 'America/Anchorage',
    HAWAII_ALEUTIAN: 'Pacific/Honolulu',
    CUBA: 'America/Havana',
    ARGENTINA: 'America/Argentina/Buenos_Aires',
    EASTERN_EUROPEAN: 'Europe/Bucharest',
    GREENWICH: 'Etc/Greenwich',
    WESTERN_EUROPEAN: 'Europe/Lisbon',
    CENTRAL_EUROPEAN: 'Europe/Berlin',
    COCOS_ISLANDS: 'Indian/Cocos',
    CENTRAL_AFRICAN: 'Africa/Lagos',
    CHATHAM_ISLAND: 'Pacific/Chatham',
    AZORES: 'Atlantic/Azores',
    IRISH: 'Europe/Dublin',
    BRITISH: 'Europe/London',
    ISRAEL: 'Asia/Jerusalem',
    ARABIA: 'Asia/Riyadh',
    PHILIPPINE: 'Asia/Manila',
    SAMOA: 'Pacific/Apia',
    CHAMORRO: 'Pacific/Guam'
};

/**
 * @description getTimezoneValue accepts a Vista Time Zone and returns a Salesforce friendly Time Zone
 * @param {String} timezoneName The VistA Time Zone to convert to one of the values in vistaTimeZoneMap
 * @returns {String} The Time Zone value that corresponds to the passed in VistA Time Zone
 */
export function getTimezoneValue(timezoneName) {
    var hasProperty = Object.prototype.hasOwnProperty.call(vistaTimeZoneMap, timezoneName);
    if (hasProperty) {
        return vistaTimeZoneMap[timezoneName];
    }
    return null;
}
