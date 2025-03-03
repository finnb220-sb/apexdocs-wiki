@isTest
public with sharing class VCC_NoteParserTest {
    //adding small change here so it gets deployed to stage3 - again

    private static String username = 'npt';

    @TestSetup
    /**
     * @description test method
     */
    public static void makeData() {
        List<String> psgNames = new List<String>{
            'VCC_Registered_Nurse',
            'VCC_Medical_Provider',
            'VCC_Advanced_Medical_Support_Assistant',
            'VCC_Pharmacy_I',
            'VCC_Pharmacy_II',
            'VCC_Pharmacy_III',
            'TED_Medical_Provider_Group',
            'TED_Registered_Nurse_Group'
        };
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser(psgNames[0], testUser);
        VCC_TestDataFactory.assignPermissionSetByName(testUser, 'HealthCloudFoundation');
        update testUser;
    }

    /**
     * @description test method
     * @return A test user
     */
    public static User getTestUser() {
        return [SELECT Id FROM User WHERE LastName = 'Testing' LIMIT 1];
    }
    /**
     * @description test class implementing the receiver
     */
    public class VCC_NoteParserTestReciever implements VCC_NoteParser.Receiver {
        public Boolean onCharacterCalled = false;
        public Boolean onSectionCalled = false;
        public Boolean onLayoutItemCalled = false;

        List<Integer> characterCodeList = new List<Integer>();
        /**
         * @description initializes the string variable
         * @return String
         */
        public String getString() {
            return String.fromCharArray(this.characterCodeList);
        }

        /**
         * @description marks character called value
         */
        public void onCharacter(VCC_NoteParser.StringParsingContext stringParsingContext) {
            this.onCharacterCalled = true;
            if (stringParsingContext.getReplacementCharacterCode() == null) {
                return;
            }
            this.characterCodeList.add(stringParsingContext.getReplacementCharacterCode());
        }
        /**
         * @description marks onsectioncalled value
         */
        public void onSection(Object section) {
            this.onSectionCalled = true;
        }
        /**
         * @description marks onlayoutItemCalled value
         */
        public void onLayoutItem(Metadata.LayoutItem layoutItem) {
            this.onLayoutItemCalled = true;
        }
    }

    @isTest
    static void parseTestOneColumn() {
        Metadata.LayoutSection layoutSection = new Metadata.LayoutSection();
        layoutSection.style = Metadata.LayoutSectionStyle.OneColumn;
        layoutSection.layoutColumns = new List<Metadata.LayoutColumn>{ new Metadata.LayoutColumn() };
        layoutSection.layoutColumns[0].layoutItems = new List<Metadata.LayoutItem>{ new Metadata.LayoutItem(), new Metadata.LayoutItem() };
        System.runAs(getTestUser()) {
            VCC_NoteParserTestReciever testReciever = new VCC_NoteParserTestReciever();
            Test.startTest();
            try {
                VCC_NoteParser noteParser = new VCC_NoteParser();
                noteParser.receiver = testReciever;
                noteParser.parse(new List<Metadata.LayoutSection>{ layoutSection }, new List<VCC_Progress_Note_Custom_Section__mdt>());
            } catch (Exception e) {
                Assert.fail('Unexpected exception.');
            }
            Assert.isTrue(testReciever.onSectionCalled, 'Expected onSection to be called.');
            Assert.isTrue(testReciever.onLayoutItemCalled, 'Expected onLayout to be called.');
            Assert.isFalse(testReciever.onCharacterCalled, 'onCharacter unexpectedly called');
            Test.stopTest();
        }
    }

    @isTest
    static void parseTestTwoColumnTopBottom() {
        Metadata.LayoutSection layoutSection = new Metadata.LayoutSection();
        layoutSection.style = Metadata.LayoutSectionStyle.TwoColumnsTopToBottom;
        layoutSection.layoutColumns = new List<Metadata.LayoutColumn>{ new Metadata.LayoutColumn(), new Metadata.LayoutColumn() };
        layoutSection.layoutColumns[0].layoutItems = new List<Metadata.LayoutItem>{ new Metadata.LayoutItem(), new Metadata.LayoutItem() };
        layoutSection.layoutColumns[1].layoutItems = new List<Metadata.LayoutItem>{ new Metadata.LayoutItem(), new Metadata.LayoutItem() };
        System.runAs(getTestUser()) {
            VCC_NoteParserTestReciever testReciever = new VCC_NoteParserTestReciever();
            Test.startTest();
            try {
                VCC_NoteParser noteParser = new VCC_NoteParser();
                noteParser.receiver = testReciever;
                noteParser.parse(new List<Metadata.LayoutSection>{ layoutSection }, new List<VCC_Progress_Note_Custom_Section__mdt>());
            } catch (Exception e) {
                Assert.fail('Unexpected exception.');
            }
            Assert.isTrue(testReciever.onSectionCalled, 'Expected onSection to be called.');
            Assert.isTrue(testReciever.onLayoutItemCalled, 'Expected onLayout to be called.');
            Assert.isFalse(testReciever.onCharacterCalled, 'onCharacter unexpectedly called');
            Test.stopTest();
        }

    }

    @isTest
    static void parseTestTwoColumnLeftRight() {
        Metadata.LayoutSection layoutSection = new Metadata.LayoutSection();
        layoutSection.style = Metadata.LayoutSectionStyle.TwoColumnsLeftToRight;
        layoutSection.layoutColumns = new List<Metadata.LayoutColumn>{ new Metadata.LayoutColumn(), new Metadata.LayoutColumn() };
        layoutSection.layoutColumns[0].layoutItems = new List<Metadata.LayoutItem>{ new Metadata.LayoutItem(), new Metadata.LayoutItem() };
        layoutSection.layoutColumns[1].layoutItems = new List<Metadata.LayoutItem>{ new Metadata.LayoutItem(), new Metadata.LayoutItem() };
        System.runAs(getTestUser()) {
            VCC_NoteParserTestReciever testReciever = new VCC_NoteParserTestReciever();
            Test.startTest();
            try {
                VCC_NoteParser noteParser = new VCC_NoteParser();
                noteParser.receiver = testReciever;
                noteParser.parse(new List<Metadata.LayoutSection>{ layoutSection }, new List<VCC_Progress_Note_Custom_Section__mdt>());
            } catch (Exception e) {
                Assert.fail('Unexpected exception.');
            }
            Assert.isTrue(testReciever.onSectionCalled, 'Expected onSection to be called.');
            Assert.isTrue(testReciever.onLayoutItemCalled, 'Expected onLayout to be called.');
            Assert.isFalse(testReciever.onCharacterCalled, 'onCharacter unexpectedly called');
            Test.stopTest();
        }

    }

    @IsTest
    static void parseStringTest() {
        Test.startTest();
        System.runAs(getTestUser()) {
            try {
                VCC_NoteParserTestReciever testReciever = new VCC_NoteParserTestReciever();
                String testString = 'testing \t \n \b \r 🤵🏿‍♀️ 👩🏻‍🌾🧞“';
                VCC_NoteParser parser = new VCC_NoteParser();
                parser.receiver = testReciever;

                parser.parseString(testString);
                parser.parseString('');
                parser.parseString(null);

                System.AssertEquals('testing      "', testReciever.getString(), 'Expected test string to be parsed');
                Assert.isTrue(testReciever.getString().isAsciiPrintable(), 'Expected ascii printable string.');
                Assert.isFalse(testReciever.onSectionCalled, 'Expected onSection to not be called.');
                Assert.isFalse(testReciever.onLayoutItemCalled, 'Expected onLayout to not be called.');
                Assert.isTrue(testReciever.onCharacterCalled, 'Expected onCharacter to be called');
            } catch (Exception e) {
                Assert.fail('Unexpected exception.');
            }
        }
        Test.stopTest();
    }

    @IsTest
    static void noteParserFullTest() {
        Case c = new Case();
        insert c;
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
            VCC_Nurse_Summary__c = 'test \n',
            VCC_Referred_patient_to_facility_MS__c = true,
            VCC_Referred_patient_for_CCC_VCV__c = true,
            VCC_Triage_Note__c = 'triagennnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn' +
                'oooooooooooooooooooooooooooooooooooooooooooootttttt|ttttttttttttttttttttttttteeeeeeeeeeeeeeeeeeeeeeeeeeeee',
            VCC_Transferred_patient_Sched_Admin_appt__c = true,
            VCC_Case__c = c.Id
        );
        insert progressNote;
        VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');
        VCC_LayoutService.LayoutInfo layoutInfo = VCC_AdapterUtils_Note.getLayoutInfo(VCC_Progress_Note__c.SObjectType, config);
        List<VCC_Progress_Note_Custom_Section__mdt> customSectionList = [
            SELECT Id, VCC_Display_Section_Name__c, VCC_Fields__c, MasterLabel
            FROM VCC_Progress_Note_Custom_Section__mdt
            WHERE MasterLabel = 'TXCC'
            LIMIT 1
        ];
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_NoteParserTestReciever testReceiver = new VCC_NoteParserTestReciever();
            VCC_NoteParser noteParser = new VCC_NoteParser(progressNote, testReceiver);

            VCC_NoteParserTestReciever unParsedReceiver = (VCC_NoteParserTestReciever) noteParser.receiver;
            System.assertEquals(unParsedReceiver.onLayoutItemCalled, false, 'onlayoutitem should not be called before parse');
            System.assertEquals(unParsedReceiver.onSectionCalled, false, 'onSectionCalled should not be called before parse');

            noteParser.parse(layoutInfo.sectionHashToSectionMap.values(), customSectionList);
            VCC_NoteParserTestReciever parsedReceiver = (VCC_NoteParserTestReciever) noteParser.receiver;
            System.assertEquals(parsedReceiver.onLayoutItemCalled, true, 'onlayoutitem should be called after parse');
            System.assertEquals(parsedReceiver.onSectionCalled, true, 'onSectionCalled should not be called after parse');
        }
        Test.stopTest();
    }

    @IsTest
    static void getValueFromSObjectTest() {
        Case c = new Case();
        insert c;
        VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
            VCC_Nurse_Summary__c = 'test \n',
            VCC_Referred_patient_to_facility_MS__c = true,
            VCC_Referred_patient_for_CCC_VCV__c = true,
            VCC_Triage_Note__c = 'triagennnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnnn' +
                'oooooooooooooooooooooooooooooooooooooooooooootttttt|ttttttttttttttttttttttttteeeeeeeeeeeeeeeeeeeeeeeeeeeee',
            VCC_Transferred_patient_Sched_Admin_appt__c = true,
            VCC_Case__c = c.Id
        );
        insert progressNote;
        Test.startTest();
        System.runAs(getTestUser()) {
            VCC_NoteParserTestReciever testReceiver = new VCC_NoteParserTestReciever();
            VCC_NoteParser noteParser = new VCC_NoteParser(progressNote, testReceiver);
            Assert.areEqual(progressNote.VCC_Nurse_Summary__c, noteParser.getValueFromSObject(VCC_Progress_Note__c.VCC_Nurse_Summary__c.getDescribe()), 'Expected same value.');
        }
        Test.stopTest();
    }
}
