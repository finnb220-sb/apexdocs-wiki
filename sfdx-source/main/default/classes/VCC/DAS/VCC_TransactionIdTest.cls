/**
 * @description Test class for VCC_TransactionId Apex Class
 * @author      Booz Allen
 * @see         VCC_TransactionId
 */
@IsTest
private class VCC_TransactionIdTest {
    /**
     * @description Creates progress note record
     * @return      `Id` record Id
     */
    private static Id createProgressNoteId() {
        VCC_Progress_Note__c testProgressNote = (VCC_Progress_Note__c) VATEST_SObjectFactory.createSObject(
            new VCC_Progress_Note__c(
                RecordTypeId = VCC_Progress_Note__c.SObjectType.getDescribe(SObjectDescribeOptions.DEFERRED)
                    .getRecordTypeInfosByDeveloperName()
                    .get('VCC_Clinical_Triage_Note_Progress_Note')
                    .getRecordTypeId()
            )
        );
        return testProgressNote.Id;
    }

    /**
     * @description Creates addednum record
     * @return      `Id` record Id
     */
    private static Id createAddendumId() {
        VCC_Addendum__c testAddendum = (VCC_Addendum__c) VATEST_SObjectFactory.createSObject(new VCC_Addendum__c());
        return testAddendum.Id;
    }

    /**
     * @description Creates an admin test user
     * @return      `User`
     */
    private static User createTestAdminUser() {
        return (new VATEST_UserBuilder())
            .withStandardData()
            .withUserProfile('System Administrator')
            .withPermissionSets(
                new Set<String>(
                    new List<String>{
                        'VAHC_RN_User',
                        'VAHC_Write_Clinical_Triage_Progress_Note',
                        'VAHC_Read_Progress_Notes',
                        'VAHC_Write_Virtual_Clinic_Visit_Progress_Note',
                        'VAHC_MP_User'
                    }
                )
            )
            .build(true);
    }

    @IsTest
    private static void unitVDIFConstructorPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            Id progressNoteId = createProgressNoteId();
            VCC_TransactionId transactionId = new VCC_TransactionId('vccVdifIsValidEsig', progressNoteId);
            Assert.areEqual(progressNoteId, transactionId.recordId, 'Expected record id to match.');
            Assert.areEqual('IsValidEsig', transactionId.prefix, 'Expected prefix to match endpoint name.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitVDIFConstructorFirstParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            String testString;
            try {
                new VCC_TransactionId(testString, createProgressNoteId());
                Assert.fail('Expected an exception to be thrown when endpoint string is null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitVDIFConstructorSecondParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                new VCC_TransactionId('vccVdifIsValidEsig', null);
                Assert.fail('Expected an exception to be thrown when recordId is null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitVDIFConstructorBothParamsNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            String endpointString;
            Id recordId;
            try {
                new VCC_TransactionId(endpointString, recordId);
                Assert.fail('Expected an exception to be thrown when recordId is null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitDASConstructorPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            Id progressNoteId = createProgressNoteId();
            VCC_TransactionId transactionId = new VCC_TransactionId(VCC_DAS.Endpoint.IS_VALID_ESIG, progressNoteId);
            Assert.areEqual(progressNoteId, transactionId.recordId, 'Expected record id to match.');
            Assert.areEqual('IsValidESig', transactionId.prefix, 'Expected prefix to match endpoint name.');
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitDASConstructorFirstParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.remove(VCC_DAS.Endpoint.CREATE_ADDENDUM);
                new VCC_TransactionId(VCC_DAS.Endpoint.CREATE_ADDENDUM, createProgressNoteId());
                Assert.fail(
                    'Expected an exception to be thrown when VCC_DAS.Endpoint does not have a key/value pair in the DAS_ENDPOINT_TO_STRING_MAP map.'
                );
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.UNMAPPED_ENDPOINT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.UNMAPPED_ENDPOINT_EXCEPTION'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitDASConstructorSecondParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                new VCC_TransactionId(VCC_DAS.Endpoint.CREATE_ADDENDUM, null);
                Assert.fail('Expected an exception to be thrown when recordId is null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitDASConstructorBothParamsNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.remove(VCC_DAS.Endpoint.CREATE_ADDENDUM);
                new VCC_TransactionId(VCC_DAS.Endpoint.CREATE_ADDENDUM, null);
                Assert.fail('Expected an exception to be thrown when both params are null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.UNMAPPED_ENDPOINT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.UNMAPPED_ENDPOINT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitServiceNameToEndpointNamePositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            Assert.areEqual(
                'IsValidEsig',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifIsValidEsig'),
                'Expected serviceNameToEndpointName method to return IsValidEsig.'
            );
            Assert.areEqual(
                'SelectPatient',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifSelectPatient'),
                'Expected serviceNameToEndpointName method to return SelectPatient.'
            );
            Assert.areEqual(
                'WriteNote',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifWriteNote'),
                'Expected serviceNameToEndpointName method to return WriteNote.'
            );
            Assert.areEqual(
                'SignNote',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifSignNote'),
                'Expected serviceNameToEndpointName method to return SignNote.'
            );
            Assert.areEqual(
                'GetAdditionalSigners',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifGetAdditionalSigners'),
                'Expected serviceNameToEndpointName method to return GetAdditionalSigners.'
            );
            Assert.areEqual(
                'CreateAddendum',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifCreateAddendum'),
                'Expected serviceNameToEndpointName method to return CreateAddendum.'
            );
            Assert.areEqual(
                'SaveNoteAndEncounter',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifSaveNoteAndEncounter'),
                'Expected serviceNameToEndpointName method to return SaveNoteAndEncounter.'
            );
            Assert.areEqual(
                'GetProvidersBySite',
                new VCC_TransactionId().serviceNameToEndpointName('vccVdifGetProvidersBySite'),
                'Expected serviceNameToEndpointName method to return GetProvidersBySite.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitServiceNameToEndpointNameNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            Assert.isNull(
                new VCC_TransactionId().serviceNameToEndpointName(null),
                'Expected enumToString method to return null.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitToStringPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_TransactionId transactionId = new VCC_TransactionId();
            transactionId.currentDateAndTime = Datetime.newInstance(2024, 12, 22, 9, 30, 30);
            transactionId.recordId = createProgressNoteId();
            transactionId.prefix = 'test';
            String transactionIdString = transactionId.toString();
            Assert.areEqual(
                String.join(
                    new List<String>{ transactionId.prefix, '241222;09:30:30:000', transactionId.recordId },
                    ';'
                ),
                transactionIdString,
                'Expected to find matching transactionId composed of prefix \'test\', properly formatted Datetime, and a record Id.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitDASEndpointToStringMapPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            Assert.areEqual(
                'IsValidESig',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.IS_VALID_ESIG),
                'Expected IsValidESig'
            );
            Assert.areEqual(
                'Select',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.SELECT_PATIENT),
                'Expected Select'
            );
            Assert.areEqual(
                'WriteNote',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.WRITE_NOTE),
                'Expected WriteNote'
            );
            Assert.areEqual(
                'SignNote',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.SIGN_NOTE),
                'Expected SignNote'
            );
            Assert.areEqual(
                'GetAdditionalSigners',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.GET_ADDITIONAL_SIGNERS),
                'Expected GetAdditionalSigners'
            );
            Assert.areEqual(
                'SaveNoteAndEncounter',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.SAVE_NOTE_AND_ENCOUNTER),
                'Expected SaveNoteAndEncounter'
            );
            Assert.areEqual(
                'WriteNoteAndSign',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN),
                'Expected WriteNoteAndSign'
            );
            Assert.areEqual(
                'CreateAddendumAndSign',
                VCC_TransactionId.DAS_ENDPOINT_TO_STRING_MAP.get(VCC_DAS.Endpoint.CREATE_ADDENDUM_AND_SIGN),
                'Expected CreateAddendumAndSign'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitValidateConstructorInputPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                new VCC_TransactionId().validateConstructorInput('Select', createProgressNoteId());
                new VCC_TransactionId().validateConstructorInput('SignNote', createAddendumId());
            } catch (Exception thrownException) {
                Assert.fail(
                    thrownException.getTypeName() +
                        ' was unexpectedly thrown. Expected no exception. Stack trace: ' +
                        thrownException.getStackTraceString()
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitValidateConstructorInputFirstParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                new VCC_TransactionId().validateConstructorInput(null, createProgressNoteId());
                Assert.fail('Expected an exception when one of the validateConstructorInput args are null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitValidateConstructorInputSecondParamNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                new VCC_TransactionId().validateConstructorInput('GetAdditionalSigners', null);
                Assert.fail('Expected an exception when one of the validateConstructorInput args are null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitValidateConstructorInputBothParamsNullNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                new VCC_TransactionId().validateConstructorInput(null, null);
                Assert.fail('Expected an exception when both validateConstructorInput args are null.');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransactionId.NULL_INPUT_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void unitValidateConstructorInputValidateIdNegative() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            try {
                Account testAccount = (Account) VATEST_SObjectFactory.createSObject(new Account());
                new VCC_TransactionId().validateConstructorInput('Select', testAccount.Id);
                Assert.fail('Expected an exception when validateConstructorInput receives an unsupported SObject Id');
            } catch (VCC_TransactionId.InstantiationException thrownException) {
                Assert.isTrue(
                    thrownException.getMessage().contains(VCC_TransactionId.BAD_ID_TYPE_EXCEPTION_MESSAGE),
                    'Expected exception message to contain string defined in VCC_TransationId.BAD_ID_TYPE_EXCEPTION_MESSAGE'
                );
            }
        }
        Test.stopTest();
    }

    @IsTest
    private static void funcVDIFTransactionIdPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_TransactionId vdifTransactionId = new VCC_TransactionId(
                'vccVdifGetProvidersBySite',
                createProgressNoteId()
            );
            Assert.areEqual(
                String.join(
                    new List<String>{
                        vdifTransactionId.prefix,
                        vdifTransactionId.currentDateAndTime.format(VCC_TransactionId.YEAR_MONTH_DAY_FORMAT),
                        vdifTransactionId.currentDateAndTime.format(
                            VCC_TransactionId.HOUR_MINUTE_SECOND_MILLISECONDS_FORMAT
                        ),
                        vdifTransactionId.recordId
                    },
                    ';'
                ),
                vdifTransactionId.toString(),
                'Expected to find matching transactionId composed of prefix \'test\', properly formatted Datetime, and a record Id.'
            );
        }
        Test.stopTest();
    }

    @IsTest
    private static void funcDASTransactionIdPositive() {
        Test.startTest();
        System.runAs(createTestAdminUser()) {
            VCC_TransactionId dasTransactionId = new VCC_TransactionId(
                VCC_DAS.Endpoint.WRITE_NOTE_AND_SIGN,
                createProgressNoteId()
            );
            Assert.isNotNull(dasTransactionId.toString(), 'Expected non-null value');
            Assert.areEqual(
                String.join(
                    new List<String>{
                        dasTransactionId.prefix,
                        dasTransactionId.currentDateAndTime.format(VCC_TransactionId.YEAR_MONTH_DAY_FORMAT),
                        dasTransactionId.currentDateAndTime.format(
                            VCC_TransactionId.HOUR_MINUTE_SECOND_MILLISECONDS_FORMAT
                        ),
                        dasTransactionId.recordId
                    },
                    ';'
                ),
                dasTransactionId.toString(),
                'Expected to find matching transactionId composed of prefix \'test\', properly formatted Datetime, and a record Id.'
            );
        }
        Test.stopTest();
    }
}
