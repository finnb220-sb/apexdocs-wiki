@isTest
/**
 * @author Patrick Skamarak
 * @since 02/01/2023
 */
public with sharing class UrnTest {
    @IsTest
    static void urnSetTest() {
        Test.startTest();
        Set<URN> urnSet = new Set<URN>();
        for (
            String urnString : new List<String>{
                'urn:va:visit:8B73:552153540:6422942?+rComp?=qComp#fComp',
                'urn:va:visit:8B73:552153540:6422942',
                'urn:va:document:8B73:552153540:5264159'
            }
        ) {
            urnSet.add(VCC_UrnService.instance.parseUrn(urnString));
        }

        // Equality only looks at the main body of the URN ie. not the
        // content that follows  "?=", "?+", or "#" sections
        System.assert(urnSet.size() == 2, 'Expected 2 elements in set.');

        Test.stopTest();
    }

    @IsTest
    static void urnEqualTest() {
        Test.startTest();
        URN urn1 = VCC_UrnService.instance.parseUrn('urn:va:visit:8B73:552153540:6422942?+rComp?=qComp#fComp');
        URN urn2 = VCC_UrnService.instance.parseUrn('urn:va:visit:8B73:552153540:6422942?+rComp?=qComp#fDIFFERENT');
        System.assert(!urn1.fullEquals(urn2), 'Expected inequality.');
        System.assert(urn1.equals(urn2), 'Expected equality.');
        urn2.fComponent = 'fComp';
        System.assert(urn1.fullEquals(urn2), 'Expected equality.');
        Test.stopTest();
    }

    @IsTest
    static void hashCodeTest() {
        Test.startTest();
        URN urn1 = VCC_UrnService.instance.parseUrn('urn:va:encounter-category:OV');
        System.assert(urn1.hashCode() != null, 'Expected non-null.');
        Test.stopTest();
    }

    @IsTest
    static void toStringTest() {
        Test.startTest();
        URN urn1 = VCC_UrnService.instance.parseUrn('urn:va:document:8B73:552153540:5264159?+r?=q#f');
        System.assert(urn1.toString() == 'urn:va:document:8B73:552153540:5264159', 'Expected string without r-,q-, or f-components.');
        System.assert(urn1.toFullString() == 'urn:va:document:8B73:552153540:5264159?+r?=q#f', 'Expected string with r-,q-, or f-components.');
        Test.stopTest();
    }
}
