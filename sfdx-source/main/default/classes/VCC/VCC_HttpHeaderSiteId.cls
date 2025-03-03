/**
 * @description This class represents an HTTP header field specifically for the Site ID.
 * @author      Booz Allen Hamilton
 */
public with sharing class VCC_HttpHeaderSiteId extends VCC_HttpHeaderField {
    public static final String HEADER_NAME = System.label.VCC_HeaderName_SiteId;

    /**
     * @description Constructor for VCC_HttpHeaderSiteId.
     * Initializes the header name and value by calling the superclass constructor.
     *
     * @param siteId The siteId.
     */
    public VCC_HttpHeaderSiteId(VCC_SiteId siteId) {
        super(HEADER_NAME, String.valueOf(siteId ?? new VCC_SiteId(null)));
    }
}
