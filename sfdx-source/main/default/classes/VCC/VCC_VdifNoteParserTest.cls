@isTest
public with sharing class VCC_VdifNoteParserTest {
    //NoteLine Test

    @IsTest
    static void noteLineRemovePartialWordTestNoSpaces() {
        VCC_VdifNoteParser.VCC_NoteLine noteLine;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new List<Integer>{
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64
            };
            for (Integer characterCode : characterCodeList) {
                noteLine.addCharacterCode(characterCode);
            }
        }
        Assert.isNull(noteLine.removePartialWord(), 'Expected null.');
        Test.stopTest();
    }

    @IsTest
    static void noteLineRemovePartialWordTestWithSpaces() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new List<Integer>{
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                32,
                64,
                64,
                64,
                64,
                64,
                32,
                64,
                64,
                64
            };
            for (Integer characterCode : characterCodeList) {
                noteLine.addCharacterCode(characterCode);
            }
            List<Integer> removedCharacterCodes = noteLine.removePartialWord();
            Assert.isNotNull(removedCharacterCodes, 'Expected list of integers.');
            Assert.areEqual(3, removedCharacterCodes.size(), 'Expected 3 characters to be removed.');
            Assert.areEqual(6, noteLine.removePartialWord().size(), 'Expected 6 characters to be removed.');
            Test.stopTest();
        }
    }

    @IsTest
    static void noteLineAddCharOneSpaceAtEnd() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new Integer[78];
            for (Integer characterCode : characterCodeList) {
                Assert.isTrue(noteLine.addCharacterCode(characterCode), 'Expected true.');
            }
            noteLine.addCharacterCode(32);
            List<Integer> removedCharacterCodes = noteLine.removePartialWord();
            Assert.isNull(removedCharacterCodes, 'Expected null, because no character were removed.');
            Test.stopTest();
        }
    }

    @IsTest
    static void noteLineAddCharHappy() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new List<Integer>{
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                32,
                64,
                64,
                64,
                64,
                64,
                32,
                64,
                64,
                64
            };
            for (Integer characterCode : characterCodeList) {
                Assert.isTrue(noteLine.addCharacterCode(characterCode), 'Expected true.');
            }
            Test.stopTest();
        }
    }

    @IsTest
    static void noteLineAddCharSad() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new Integer[80];
            Boolean hasFalse = false;
            for (Integer characterCode : characterCodeList) {
                if (noteLine.addCharacterCode(characterCode) == false) {
                    hasFalse = true;
                }
            }
            Assert.isTrue(hasFalse, 'Expected a false.');
            Test.stopTest();
        }
    }

    @IsTest
    static void noteLineMaxWithSpace() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new Integer[79];
            characterCodeList[50] = 32;
            for (Integer characterCode : characterCodeList) {
                noteLine.addCharacterCode(characterCode);
            }
            Assert.isFalse(noteLine.doBreakWord(), 'Expected false.');
            Test.stopTest();
        }
    }

    @IsTest
    static void noteLineMaxNoSpaces() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new Integer[79];
            for (Integer characterCode : characterCodeList) {
                noteLine.addCharacterCode(characterCode);
            }
            Assert.isTrue(noteLine.doBreakWord(), 'Expected true.');
            Test.stopTest();
        }

    }

    @IsTest
    static void noteLineToString() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NoteLine noteLine = new VCC_VdifNoteParser.VCC_NoteLine();
            List<Integer> characterCodeList = new List<Integer>{
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64,
                64
            };
            for (Integer characterCode : characterCodeList) {
                noteLine.addCharacterCode(characterCode);
            }
            Assert.areEqual('@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@', noteLine.toString(), 'Expected correct string.');
            Test.stopTest();
        }
    }

    // NotePage Tests

    @IsTest
    static void notePageCurrentLineTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            Assert.isTrue(notePage.lines[0] === notePage.currentLine, 'Expected current line to be the only line on the page.');
            Test.stopTest();
        }
    }

    @IsTest
    static void notePageHasMaxLinesFalseTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            Assert.isFalse(notePage.hasMaximumLines(), 'Expected false.');
            Test.stopTest();
        }

    }

    @IsTest
    static void notePageHasMaxLinesTrueTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            notePage.lines.addAll(new VCC_VdifNoteParser.VCC_NoteLine[299]);
            Assert.isTrue(notePage.hasMaximumLines(), 'Expected true.');
            Test.stopTest();
        }

    }

    @IsTest
    static void notePageAddLineMaxLinesTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            notePage.lines.addAll(new VCC_VdifNoteParser.VCC_NoteLine[299]);
            Assert.isTrue(notePage.hasMaximumLines(), 'Expected true.');
            Assert.isFalse(notePage.newLine(), 'Expected false.');
            Test.stopTest();
        }

    }

    @IsTest
    static void notePageAddLineSuccessTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            Assert.isTrue(notePage.newLine(), 'Expected true.');
            Assert.isFalse(notePage.hasMaximumLines(), 'Expected false.');
            Test.stopTest();
        }

    }

    @IsTest
    static void notePageToStringOneLineTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            Assert.areEqual('', notePage.toString(), 'Expected correctly formatted string.');
            Test.stopTest();
        }

    }

    @IsTest
    static void notePageToStringTwoLineTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser.VCC_NotePage notePage = new VCC_VdifNoteParser.VCC_NotePage();
            notePage.newLine();
            Assert.areEqual('|', notePage.toString(), 'Expected correctly formatted string.');
            Test.stopTest();
        }

    }

    @IsTest
    static void getTextEmptyTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser vdifNoteParser = new VCC_VdifNoteParser();
            Assert.areEqual('', vdifNoteParser.getText(), 'expected to be equal but was not');
            Test.stopTest();
        }
    }

    @IsTest
    static void getTextNotEmptyTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser vdifNoteParser = new VCC_VdifNoteParser();
            vdifNoteParser.currentPage.currentLine.addCharacterCode(36);
            Assert.areEqual('$', vdifNoteParser.getText(), 'expected to be equal but was not');
            Test.stopTest();
        }

    }

    @IsTest
    static void getTextMultipleLinesTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser vdifNoteParser = new VCC_VdifNoteParser();
            vdifNoteParser.currentPage.currentLine.addCharacterCode(36);
            vdifNoteParser.currentPage.newLine();
            vdifNoteParser.currentPage.currentLine.addCharacterCode(36);
            Assert.areEqual('$|$', vdifNoteParser.getText(), 'expected to be equal but was not');
            Test.stopTest();
        }
    }

    @IsTest
    static void newPageTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_VdifNoteParser vdifNoteParser = new VCC_VdifNoteParser();
            Assert.isTrue(vdifNoteParser.pages.size() == 1, 'Expected one page.');
            Assert.isInstanceOfType(vdifNoteParser.newPage(), VCC_VdifNoteParser.VCC_NotePage.class, 'Expected instance of VCC_VdifNoteParser.VCC_NotePage');
            Assert.isTrue(vdifNoteParser.pages.size() == 2, 'Expected two pages.');
            Test.stopTest();
        }

    }

    @IsTest
    static void sectionStateMetadataLayoutSectionTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            Metadata.LayoutSection layoutSection = new Metadata.LayoutSection();
            layoutSection.label = 'test';
            layoutSection.detailHeading = false;
            VCC_VdifNoteParser.VCC_SectionState sectionState = new VCC_VdifNoteParser.VCC_SectionState(layoutSection);
            Assert.areEqual(layoutSection.detailHeading, sectionState.shouldPrintName, 'Expected shouldPrintName to match layoutSection.detailHeading');
            Assert.areEqual(layoutSection.label, sectionState.sectionName, 'Expected sectionName to match the layoutSection label.');
            Test.stopTest();
        }

    }

    @IsTest
    static void sectionStateCustomSectionTest() {
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Test.startTest();
            VCC_Progress_Note_Custom_Section__mdt customSection = new VCC_Progress_Note_Custom_Section__mdt(VCC_Display_Section_Name__c = true, MasterLabel = 'test');
            VCC_VdifNoteParser.VCC_SectionState sectionState = new VCC_VdifNoteParser.VCC_SectionState(customSection);
            Assert.areEqual(customSection.VCC_Display_Section_Name__c, sectionState.shouldPrintName, 'Expected shouldPrintName to match layoutSection.detailHeading');
            Assert.areEqual(customSection.MasterLabel, sectionState.sectionName, 'Expected sectionName to match the layoutSection label.');
            Test.stopTest();
        }

    }

    @isTest
    public static void endToEnd() {
        String outputString;
        User testuser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        VCC_TestDataFactory.addPermSetGroupToUser('VAHC_Super_User', testUser);
        System.runAs(testuser) {
            Case newCase = new Case();
            insert newCase;
            VCC_Progress_Note__c progressNote = new VCC_Progress_Note__c(
                VCC_Nurse_Summary__c = 'test \n Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. \n\nDuis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                VCC_Case__c = newCase.Id,
                VCC_Triage_Complete__c = true,
                VCC_Triage_Date__c = Date.today(),
                VCC_Triage_Note__c = 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nunc purus nulla, gravida nec maximus sit amet, tincidunt non elit. Maecenas tristique mauris eleifend justo scelerisque ullamcorper. Phasellus tristique turpis nec erat pellentesque consequat. Vestibulum et lectus vitae libero efficitur luctus. Aliquam enim eros, venenatis vel imperdiet non, pharetra quis purus. Cras vulputate aliquet felis, et faucibus diam varius sed. Integer vel vulputate lorem. Proin pulvinar faucibus metus eget lacinia. Nam nec dolor viverra, sollicitudin odio non, sollicitudin urna. Quisque ornare et leo quis iaculis. Etiam dignissim id mauris quis ultricies. Nullam ac purus sit amet ex fringilla vestibulum. Etiam ut consequat diam. Cras metus tortor, porta pharetra metus ut, ultrices interdum lacus. Vestibulum pulvinar massa at mattis malesuada. Etiam et ullamcorper felis. Nam mattis, mi at mollis ullamcorper, enim urna blandit dui, ut elementum nisl nibh vel nisi. Sed vitae purus sit amet ipsum feugiat pulvinar id vel mi. Morbi fermentum elit sit amet eros elementum ornare. Nulla facilisi. Nam porta ornare ex a posuere. Duis tellus quam, pulvinar et velit ac, placerat venenatis neque. Sed placerat tortor ac dignissim rhoncus.'
            );

            insert progressNote;
            VCC_VdifNoteParser vdifNoteParser = new VCC_VdifNoteParser(progressNote);
            VCC_Progress_Note_Configuration__mdt config = new VCC_ProgressNoteConfigSelector().selectByRecordTypeApiName('VCC_Clinical_Triage_Note_Progress_Note');
            VCC_LayoutService.LayoutInfo layoutInfo = VCC_AdapterUtils_Note.getLayoutInfo(VCC_Progress_Note__c.SObjectType, config);

            Test.startTest();
            outputString = vdifNoteParser.parse(
                layoutInfo.sectionHashToSectionMap.values(),
                [
                    SELECT Id, VCC_Display_Section_Name__c, VCC_Fields__c, MasterLabel
                    FROM VCC_Progress_Note_Custom_Section__mdt
                    WHERE MasterLabel = 'TXCC'
                    LIMIT 1
                ]
            );
            Test.stopTest();
        }

        Assert.isNotNull(outputString, 'Expected String output, got null');
        Assert.isTrue(outputString.contains('Nurse Summary:'), 'Expected to find string.');
        Assert.isTrue(outputString.contains('test |'), 'Expected to find string.');
    }
}
