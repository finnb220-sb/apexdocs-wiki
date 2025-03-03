@isTest
/**
 * @description Test class for VCC_UrnService
 *
 * @author Patrick Skamarak
 * @since 02/01/2023
 * updated 01/11/2024 by Lung Joe - PMD compliance
 */
public with sharing class VCC_UrnServiceTest {
    private static String usernameTestPrefix = 'urnTester';
    /**
     * @description creating test user to run test as
     */
    @TestSetup
    public static void makeData() {
        User testUser = VCC_TestDataFactory.insertUser('Standard User');
        testUser.Username = usernameTestPrefix + testUser.Username;
        update testUser;
    }

    /**
     * @description retrieves the test user from setup
     * @return  `User`
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE Username LIKE :usernameTestPrefix + '%' LIMIT 1];
    }

    @IsTest
    static void stubTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_Stub urnServiceStub = VCC_UrnService.stub();
            System.assert(VCC_UrnService.instance === urnServiceStub.instance, 'Expected stub.');
            Test.stopTest();
        }

    }

    @IsTest
    static void parseTestBulk() {
        System.runAs(getTestUser()) {
            Test.startTest();

            for (
                String urnString : new List<String>{
                    'urn:va:visit:8B73:552153540:6422942?+rCo??mp?=qCo??mp#fComp',
                    'urn:va:visit:8B73:552153540:6422942',
                    'urn:va:document:8B73:552153540:5264159',
                    'urn:va:encounter-category:OV',
                    'urn:10d:I85.01',
                    'urn:va:user:8B73:35658',
                    'urn:va:vuid:4693715',
                    //below are all URN's from https://en.wikipedia.org/wiki/Uniform_Resource_Name
                    'urn:isbn:0451450523',
                    'urn:isan:0000-0000-2CEA-0000-1-0000-0000-Y',
                    'urn:ISSN:0167-6423',
                    'urn:ietf:rfc:2648',
                    'urn:mpeg:mpeg7:schema:2001',
                    'urn:oid:2.16.840',
                    'urn:uuid:6e8bc430-9c3a-11d9-9669-0800200c9a66',
                    'urn:nbn:de:bvb:19-146642',
                    'urn:lex:eu:council:directive:2010-03-09;2010-19-UE',
                    'urn:lsid:zoobank.org:pub:CDC8D258-8F57-41DC-B560-247E17D3DC8C',
                    'urn:epc:class:lgtin:4012345.012345.998877',
                    'urn:epc:id:sgtin:0614141.112345.400',
                    'urn:epc:id:sscc:0614141.1234567890',
                    'urn:epc:id:sgln:0614141.12345.400',
                    'urn:epc:id:bic:CSQU3054383',
                    'urn:epc:id:imovn:9176187',
                    'urn:epc:id:gdti:0614141.12345.400',
                    'urn:mrn:iala:aton:us:1234.5',
                    'urn:mrn:iala:vts:ca:ecareg',
                    'urn:mrn:iala:wwy:us:atl:chba:potri',
                    'urn:mrn:iala:pub:g1143',
                    'urn:microsoft:adfs:claimsxray',
                    'urn:eic:10X1001A1001A450'
                }
            ) {
                VCC_UrnService.instance.parseUrn(urnString);
            }
            //implied because an exception was not thrown
            System.assert(true, 'Implied assert.');

            Test.stopTest();
        }

    }

    @IsTest
    static void parseUrnTestHappy() {
        System.runAs(getTestUser()) {
            Test.startTest();

            String urnString = 'urn:va:visit:8B73:552153540:6422942?+rComp?=qComp#fComp';

            URN parsedUrn = VCC_UrnService.instance.parseUrn(urnString);

            System.assert(parsedUrn.urnPrefix == 'urn', 'Expected the correct value.');
            System.assert(parsedUrn.namespaceId == 'va', 'Expected the correct value.');
            System.assert(parsedUrn.namespaceSpecificSection == 'visit:8B73:552153540:6422942', 'Expected the correct value.');
            System.assert(parsedUrn.rComponent == 'rComp', 'Expected the correct value.');
            System.assert(parsedUrn.qComponent == 'qComp', 'Expected the correct value.');
            System.assert(parsedUrn.fComponent == 'fComp', 'Expected the correct value.');

            Test.stopTest();
        }

    }

    @IsTest
    static void parseUrnTestSadNull() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_UrnService.VCC_UrnServiceException expectedException;
            try {
                VCC_UrnService.instance.parseUrn(null);
            } catch (VCC_UrnService.VCC_UrnServiceException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'expected an exception.');
            Test.stopTest();
        }
    }

    @IsTest
    static void parseUrnTestSadInvalidUrn() {
        System.runAs(getTestUser()) {
            Test.startTest();
            VCC_UrnService.VCC_UrnServiceException expectedException;
            try {
                VCC_UrnService.instance.parseUrn('u:test:fdiaopfjdasop');
            } catch (VCC_UrnService.VCC_UrnServiceException e) {
                expectedException = e;
            }
            System.assert(expectedException != null, 'expected an exception.');
            Test.stopTest();
        }
    }

    @IsTest
    static void isValidUrnTest() {
        System.runAs(getTestUser()) {
            Test.startTest();
            String urnString = 'urn:va:visit:8B73:552153540:6422942?+rComp?=qComp#fComp';
            URN testURN = VCC_UrnService.instance.parseUrn(urnString);
            System.assert(VCC_UrnService.instance.isValidUrn(testURN), 'Expected valid Urn.');
            Test.stopTest();
        }
    }
}
