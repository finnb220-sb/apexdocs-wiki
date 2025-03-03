/**
 * @description This class represents a VistA site Id. Valid site id's look like '983' or '983CRNR'
 * @author Booz Allen Hamilton
 * @since 06/14/2024 Created for CCCM-30612
 */
public with sharing class VCC_SiteId {
    @TestVisible
    private static final String SITE_ID_REGEX = '^[0-9]{3}[a-zA-Z]{0,4}$';

    @TestVisible
    private static final String ILLEGAL_ARGUMENT_TEMPLATE = 'VCC_SiteId Error: "{0}" is an invalid site Id. A site Id must satisfy the regular expression: {1}';

    @TestVisible
    private String value;

    /**
     * @description constructor accepting a string, which is the siteId
     * @param siteId a site Id
     * @exception `IllegalArgumentException` when the siteId string doesn't match the regular expression '^[0-9]{3}[a-zA-Z]{0,4}$'
     */
    public VCC_SiteId(String siteId) {
        validateSiteId(siteId);
        this.value = siteId;
    }

    /**
     * @description Returns the site Id stored in private variable "value".
     * @return `String` the site Id
     */
    public override String toString() {
        return this.value;
    }

    @TestVisible
    private static void validateSiteId(String siteId) {
        if (siteId == null || String.isBlank(siteId)) {
            raiseIllegalArgumentException(siteId);
        }
        Pattern pattern = Pattern.compile(SITE_ID_REGEX);
        Matcher matcher = pattern.matcher(siteId);
        if (!matcher.matches()) {
            raiseIllegalArgumentException(siteId);
        }
    }

    @TestVisible
    private static void raiseIllegalArgumentException(String siteId) {
        throw new IllegalArgumentException(formatExceptionMessage(siteId));
    }

    @TestVisible
    private static String formatExceptionMessage(String siteId) {
        return String.format(ILLEGAL_ARGUMENT_TEMPLATE, new List<String>{ siteId ?? 'null', SITE_ID_REGEX });
    }
}
