/**
 * @description Test class for VCC_DASServiceParser to verify parsing functionality under various conditions.
 * It includes tests for successful parsing, handling null values, and throwing exceptions.
 *
 * @author Booz Allen.
 */
@IsTest
public with sharing class VCC_DASServiceParserTest {
    private static final User RN_USER;

    static {
        RN_USER = new VATEST_UserBuilder()
            .withPermissionSets(
                new Set<String>{ 'VAHC_Write_Clinical_Triage_Progress_Note', 'VAHC_RN_User', 'VAHC_Standard_VCC_User' }
            )
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Provides a mocked method signature for the parse method.
     * @return VATEST_MockedMethod for parse.
     */
    @TestVisible
    private static VATEST_MockedMethod getMockedMethodParse() {
        return new VATEST_MockedMethod(new VATEST_MethodSignature('parse', new List<System.Type>{ SObject.class }));
    }

    /**
     * @description Tests successful parsing of a progress note with expected values.
     */
    @IsTest
    static void parseSObjectTestHappy() {
        VCC_DASStub metadataServiceStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DASStub utilitiesServiceStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataServiceStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesServiceStub.instance;

        utilitiesServiceStub.setReturnValue('getRecordTypeApiName', null);
        metadataServiceStub.setReturnValue('getConfiguration', null);
        metadataServiceStub.setReturnValue('getCustomSections', null);

        VCC_Progress_Note__c progressNoteForMockParse = new VCC_Progress_Note__c();

        Test.startTest();
        System.runAs(RN_USER) {
            Assert.areEqual(
                'test',
                VCC_DAS.SERVICES.PARSER.parse((SObject) progressNoteForMockParse),
                'Expected to receive value of \'test\''
            );
        }
        Test.stopTest();

        utilitiesServiceStub.assertInvoked('getRecordTypeApiName');
        metadataServiceStub.assertInvoked('getConfiguration');
        metadataServiceStub.assertNotInvoked('getCustomSections');
    }

    /**
     * @description Tests parser handling when an exception is thrown by a utility method.
     */
    @IsTest
    static void parseSObjectTestSad() {
        VCC_DASStub metadataServiceStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DASStub utilitiesServiceStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataServiceStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesServiceStub.instance;

        utilitiesServiceStub.setException('getRecordTypeApiName', new NullPointerException());
        metadataServiceStub.setReturnValue('getConfiguration', null);
        metadataServiceStub.setReturnValue('getCustomSections', null);

        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c();

        Test.startTest();
        System.runAs(RN_USER) {
            try {
                VCC_DAS.SERVICES.PARSER.parse((SObject) progressNote);
                Assert.fail('Expected an exception.');
            } catch (Exception exc) {
                Assert.isInstanceOfType(exc, VCC_DASException.class, 'Expected a VCC_DASException');
            }
        }
        utilitiesServiceStub.assertInvoked('getRecordTypeApiName');
        metadataServiceStub.assertNotInvoked('getConfiguration');
        metadataServiceStub.assertNotInvoked('getCustomSections');
        Test.stopTest();
    }

    /**
     * @description Tests parser handling of custom exception from utility method.
     */
    @IsTest
    static void parseSObjectTestSad2() {
        VCC_DASStub metadataServiceStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DASStub utilitiesServiceStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataServiceStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesServiceStub.instance;

        utilitiesServiceStub.setException(
            'getRecordTypeApiName',
            new VCC_DASServiceUtilities.GetRecordTypeApiNameException('test')
        );
        metadataServiceStub.setReturnValue('getConfiguration', null);
        metadataServiceStub.setReturnValue('getCustomSections', null);

        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c();

        Test.startTest();
        System.runAs(RN_USER) {
            try {
                VCC_DAS.SERVICES.PARSER.parse((SObject) progressNote);
                Assert.fail('Expected an exception.');
            } catch (Exception exc) {
                Assert.isInstanceOfType(exc, VCC_DASException.class, 'Expected a VCC_DASException');
            }
        }
        utilitiesServiceStub.assertInvoked('getRecordTypeApiName');
        metadataServiceStub.assertNotInvoked('getConfiguration');
        metadataServiceStub.assertNotInvoked('getCustomSections');
        Test.stopTest();
    }

    /**
     * @description Tests parser with an empty progress note, expecting an exception.
     */
    @IsTest
    static void unitParseSObjectEmptyProgressNoteNegative() {
        VCC_DASStub metadataServiceStub = new VCC_DASStub(VCC_DASServiceMetadata.class);
        VCC_DASStub utilitiesServiceStub = new VCC_DASStub(VCC_DASServiceUtilities.class);

        VCC_DAS.SERVICES.metadataService = (VCC_DASServiceMetadata) metadataServiceStub.instance;
        VCC_DAS.SERVICES.utilitiesService = (VCC_DASServiceUtilities) utilitiesServiceStub.instance;

        VCC_DAS.SERVICES.PARSER.stubParser = false;

        utilitiesServiceStub.setReturnValue('getRecordTypeApiName', null);
        metadataServiceStub.setReturnValue('getConfiguration', null);

        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c();

        Test.startTest();
        System.runAs(RN_USER) {
            try {
                VCC_DAS.SERVICES.PARSER.parse((SObject) progressNote);
                Assert.fail('Expected an exception.');
            } catch (Exception exc) {
                Assert.isInstanceOfType(exc, VCC_DASException.class, 'Expected a VCC_DASException');
            }
        }
        utilitiesServiceStub.assertInvoked('getRecordTypeApiName');
        metadataServiceStub.assertInvoked('getConfiguration');
        Test.stopTest();
    }
}
