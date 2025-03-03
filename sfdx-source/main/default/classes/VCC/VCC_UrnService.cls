/**
 * @description
 *
 * @author Patrick Skamarak
 * @since 02/01/2023
 * updated 01/11/2024 by Lung Joe - PMD compliance
 *
 * URN - Uniform Resource Name Syntax (RFC 8141)
 *       Augmented Backus-Naur Form (ABNF)
 *
 * namestring    = assigned-name
 *                 [ rq-components ]
 *                 [ "#" f-component ]
 * assigned-name = "urn" ":" NID ":" NSS
 * NID           = (alphanum) 0*30(ldh) (alphanum)
 * ldh           = alphanum / "-"
 * alphanum      = ALPHA / DIGIT
 * NSS           = pchar *(pchar / "/")
 *
 * rq-components = [ "?+" r-component ]
 *                 [ "?=" q-component ]
 * r-component   = pchar *( pchar / "/" / "?" )
 * q-component   = pchar *( pchar / "/" / "?" )
 * f-component   = fragment
 *
 * fragment      = *( pchar / "/" / "?" )
 * pchar         = unreserved / pct-encoded / sub-delims / ":" / "@"
 * unreserved    = ALPHA / DIGIT / "-" / "." / "_" / "~"
 * pct-encoded   = "%" HEXDIG HEXDIG
 * sub-delims    = "!" / "$" / "&" / "'" / "(" / ")" / "*" / "+" / "," / ";" / "="
 *
 */
public with sharing class VCC_UrnService {
    @TestVisible
    private static VCC_UrnService privateInstance;

    public final String parseExceptionTemplate = 'URN Parsing Failed: {0}.';

    /**
     * Regex Patterns for the above definitions
     * alphanum         [A-Za-z0-9]
     * unreserved       [A-Za-z]|[0-9]|-|\\.|_|~
     * sub-delims       !|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=
     * pct-encoded      %[A-Fa-f0-9]{2}
     * pchar            (?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|(?::|@)
     */
    public final String urnPattern =
        '(urn)' + //'urn'
        '(?::)' + // :
        '([A-Za-z0-9](?:[A-Za-z0-9]|-){0,30}[A-Za-z0-9])' + //NID
        '(?::)' + // :
        '(' + //NSS
        '(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|:|@)' + //NSS
        '(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|:|@|\\/){0,}' + //NSS
        ')' + //NSS
        '(?:(?:\\?\\+)(' + //r-components
        '(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|(?::|@))' + //r-components
        '(?:(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|(?::|@))|\\/(?:\\?(?!=))){0,}' + //r-components
        '))?' + //r-components
        '(?:(?:\\?=)(' + //q-components
        '(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|(?::|@))' + //q-components
        '(?:(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|(?::|@))|\\/|\\?){0,}' + //q-components
        '))?' + //q-components
        '(?:(?:#)(' + //f-components
        '(?:(?:(?:[A-Za-z0-9]|-|\\.|_|~)|(?:%[A-Fa-f0-9]{2})|(?:!|\\$|&|\'|\\(|\\)|\\*|\\+|,|;|=)|(?::|@))|\\/|\\?){0,}' + //f-components
        '))?'; //f-components

    /**
     * @description boilerplate code start
     */
    public static VCC_UrnService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_UrnService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub urnServiceStub = new VCC_Stub(VCC_UrnService.class);
        VCC_UrnService.privateInstance = (VCC_UrnService) urnServiceStub.instance;
        return urnServiceStub;
    }
    //boilerplate code end

    /**
     * @description throws custom VCC_UrnServiceException
     * @param reason
     * @exception
     */
    public void raiseParseException(String reason) {
        throw new VCC_UrnServiceException(String.format(this.parseExceptionTemplate, new List<String>{ reason }));
    }
    /**
     * @description parses string into URN object
     *
     * @param urnString
     * @return  `Urn`
     */
    public Urn parseUrn(String urnString) {
        if (String.isBlank(urnString)) {
            raiseParseException('Argument must not be null or blank');
        }

        Matcher mchr = Pattern.compile(urnPattern).matcher(urnString);
        if (mchr.find() == false) {
            raiseParseException('Invalid URN: Regex did not match input string');
        }

        Urn parsedUrn = new Urn();
        parsedUrn.urnPrefix = mchr.group(1);
        parsedUrn.namespaceId = mchr.group(2);
        parsedUrn.namespaceSpecificSection = mchr.group(3);
        parsedUrn.rComponent = mchr.group(4);
        parsedUrn.qComponent = mchr.group(5);
        parsedUrn.fComponent = mchr.group(6);

        return parsedUrn;
    }
    /**
     * @description checks if valid if string argument matches regex
     *
     * @param urnString
     * @return  `Boolean`
     */
    public Boolean isValidUrn(String urnString) {
        return Pattern.matches(urnPattern, urnString);
    }
    /**
     * @description
     *
     * @param urn
     * @return  `Boolean`
     */
    public Boolean isValidUrn(Urn urn) {
        return this.isValidUrn(urn.toFullString());
    }
    /**
     * @description custom UrnServiceException denoting parsing error during parseUrn method
     */
    public class VCC_UrnServiceException extends Exception {
    }
}
