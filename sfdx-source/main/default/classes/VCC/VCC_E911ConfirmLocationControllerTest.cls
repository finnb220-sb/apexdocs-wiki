/**
 * @author Booz Allen
 * @date 04/2024
 * @description Test Class for the VCC_E911ConfirmLocationController methods
 */
@IsTest
public with sharing class VCC_E911ConfirmLocationControllerTest {
    /**
     * @description Test for getting an an active E911 record with the correct associated account/contact id passed in
     */
    @IsTest
    public static void unitTestGetActiveE911MetricsRecordPositive() {
        Id fakeContactId = VATEST_IdFactory.get(Contact.SObjectType);
        VCC_e911_Metrics__c testMetric = (VCC_e911_Metrics__c) VATEST_SObjectFactory.createSObject(
            new VCC_e911_Metrics__c(VCC_Patient_Account__c = fakeContactId)
        );

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(fakeContactId)
            .returning(new List<VCC_e911_Metrics__c>{ testMetric })
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        VCC_e911_Metrics__c testResult;
        Test.startTest();
        testResult = VCC_E911ConfirmLocationController.getActiveE911MetricsRecord(fakeContactId);
        Test.stopTest();

        Assert.isNotNull(testResult, 'Record was search returned null, expecting record to be retrieved');
        Assert.areEqual(
            testResult.VCC_Patient_Account__c,
            testMetric.VCC_Patient_Account__c,
            'Result record and test record do not match'
        );
    }

    /**
     * @description Test for retrieving no E911 records when none exist for the mutual account/contact id
     */
    @IsTest
    public static void unitTestGetActiveE911MetricsRecordNegative() {
        Id fakeContactId = VATEST_IdFactory.get(Contact.SObjectType);

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(fakeContactId)
            .returning(new List<VCC_e911_Metrics__c>())
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        VCC_e911_Metrics__c testResult;
        Test.startTest();
        testResult = VCC_E911ConfirmLocationController.getActiveE911MetricsRecord(fakeContactId);
        Test.stopTest();

        Assert.isNull(testResult, 'Record should have returned null');
    }

    /**
     * @description Test for retrieving the contact id from the passed in contact id
     */
    @IsTest
    public static void unitTestGetContactIdFromAccountIdPositive() {
        Id fakeAccountId = VATEST_IdFactory.get(Account.SObjectType);
        Id fakeContactId = VATEST_IdFactory.get(Contact.SObjectType);
        Contact tempContact = new Contact(Id = fakeContactId);

        VCR_ContactRepo stubContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ tempContact })
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedContactRepo = stubContactRepo;

        Id testResult;
        Test.startTest();
        testResult = VCC_E911ConfirmLocationController.getContactIdFromAccountId(fakeAccountId);
        Test.stopTest();

        Assert.areEqual(testResult, fakeContactId, 'Mock should have returned the test contact Id');
    }

    /**
     * @description Test setting the address fields of the metric object according to the json data passed in
     */
    @IsTest
    public static void unitTestSetE911MetricsDataWithAddrPositive() {
        VCC_e911_Metrics__c testMetricsRecord = new VCC_e911_Metrics__c();
        String testAddrSerialized = '{"street":"123 Test St",  "city":"Miami", "state":"FL", "country":"United States", "zipCode":"00000"}';

        Test.startTest();
        VCC_E911ConfirmLocationController.setE911MetricsData(testMetricsRecord, testAddrSerialized, null);
        Test.stopTest();

        Assert.areEqual(
            testMetricsRecord.VCC_Street__c,
            '123 Test St',
            'Metric record did not populate the street field correctly'
        );
        Assert.areEqual(
            testMetricsRecord.VCC_City__c,
            'Miami',
            'Metric record did not populate the city field correctly'
        );
        Assert.areEqual(
            testMetricsRecord.VCC_Country__c,
            'United States',
            'Metric record did not populate the country field correctly'
        );
        Assert.areEqual(
            testMetricsRecord.VCC_State__c,
            'FL',
            'Metric record did not populate the state field correctly'
        );
        Assert.areEqual(
            testMetricsRecord.VCC_Zip_Code__c,
            '00000',
            'Metric record did not populate the zip code field correctly'
        );
        Assert.areEqual(
            testMetricsRecord.VCC_Non_Address__c,
            '',
            'Metric record should not have populated the non address field'
        );
    }

    /**
     * @description Test the setting of the non address field whenever non address information is passed in
     */
    @IsTest
    public static void unitTestSetE911MetricsDataWithNonAddrPositive() {
        VCC_e911_Metrics__c testMetricsRecord = new VCC_e911_Metrics__c();
        String nonAddrInfo = 'test non address information';

        Test.startTest();
        VCC_E911ConfirmLocationController.setE911MetricsData(testMetricsRecord, null, nonAddrInfo);
        Test.stopTest();

        Assert.areEqual(
            testMetricsRecord.VCC_Street__c,
            '',
            'Metric record should not have populated the street field'
        );
        Assert.areEqual(testMetricsRecord.VCC_City__c, '', 'Metric record should not have populated the city field');
        Assert.areEqual(
            testMetricsRecord.VCC_Country__c,
            '',
            'Metric record should not have populated the country field'
        );
        Assert.areEqual(testMetricsRecord.VCC_State__c, '', 'Metric record should not have populated the state field');
        Assert.areEqual(
            testMetricsRecord.VCC_Zip_Code__c,
            '',
            'Metric record should not have populated the zip code field'
        );
        Assert.areEqual(
            testMetricsRecord.VCC_Non_Address__c,
            nonAddrInfo,
            'Metric record have populated the the non address field but did not correctly populate'
        );
    }

    /**
     * @description Tests the handling of E911 Metric record being retrieved, field setting, and upserting updates
     */
    @IsTest
    public static void funcTestHandleE911MetricsPositive() {
        Id fakeAccountId = VATEST_IdFactory.get(Account.SObjectType);
        Id fakeContactId = VATEST_IdFactory.get(Contact.SObjectType);
        Id fakeMetricId = VATEST_IdFactory.get(VCC_e911_Metrics__c.SObjectType);

        String testAddrSerialized = '{"street":"123 Test St",  "city":"Miami", "state":"FL", "country":"United States", "zipCode":"00000"}';

        //mocking needs exact param
        SObjectType objType = VCC_e911_Metrics__c.SObjectType;
        sObject sampleMetric = objType.newSObject();
        sampleMetric.put('VCC_Patient_Account__c', fakeContactId);
        sampleMetric.put('VCC_Street__c', '123 Test St');
        sampleMetric.put('VCC_City__c', 'Miami');
        sampleMetric.put('VCC_State__c', 'FL');
        sampleMetric.put('VCC_Country__c', 'United States');
        sampleMetric.put('VCC_Zip_Code__c', '00000');
        sampleMetric.put('VCC_Non_Address__c', '');

        Contact tempContact = new Contact(Id = fakeContactId);

        VCR_ContactRepo stubContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ tempContact })
            .defineStub();

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(fakeContactId)
            .returning(new List<VCC_e911_Metrics__c>())
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(sampleMetric)
            .returning(
                (Database.UpsertResult) JSON.deserialize(
                    '{"success":true,"id":"' + fakeMetricId + '"}',
                    Database.UpsertResult.class
                )
            )
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedContactRepo = stubContactRepo;
        VCC_E911ConfirmLocationController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        Test.startTest();
        Database.UpsertResult res = VCC_E911ConfirmLocationController.handleE911Metrics(
            null,
            fakeAccountId,
            testAddrSerialized,
            null
        );
        Test.stopTest();

        Assert.areEqual(res.isSuccess(), true, 'Mock did not return good upsert result');
    }

    /**
     * @description Tests the handling of E911 Metric record when E911 id is provided
     */
    @isTest
    public static void funcTestHandleE911MetricsWithRecordIdPositive() {
        Id fakeMetricId = VATEST_IdFactory.get(VCC_e911_Metrics__c.sObjectType);
        String testAddrSerialized = '{"street":"123 Test St",  "city":"Miami", "state":"FL", "country":"United States", "zipCode":"00000"}';

        //mocking needs exact param
        SobjectType objType = VCC_e911_Metrics__c.sObjectType;
        sObject sampleMetric = objType.newSObject();
        sampleMetric.put('VCC_Street__c', '123 Test St');
        sampleMetric.put('VCC_City__c', 'Miami');
        sampleMetric.put('VCC_State__c', 'FL');
        sampleMetric.put('VCC_Country__c', 'United States');
        sampleMetric.put('VCC_Zip_Code__c', '00000');
        sampleMetric.put('VCC_Non_Address__c', '');

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('fetchById', Id.class)
            .withParameterValues(fakeMetricId)
            .returning(new VCC_e911_Metrics__c())
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(sampleMetric)
            .returning(
                (Database.UpsertResult) JSON.deserialize(
                    '{"success":true,"id":"' + fakeMetricId + '"}',
                    Database.UpsertResult.class
                )
            )
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        Test.startTest();
        Database.UpsertResult res = VCC_E911ConfirmLocationController.handleE911Metrics(
            fakeMetricId,
            null,
            testAddrSerialized,
            null
        );
        Test.stopTest();

        Assert.areEqual(res.isSuccess(), true, 'Mock did not return good upsert result');
    }

    /**
     * @description Tests the handling of upserting an updated E911 record whenever there is an error from the upsert
     */
    @IsTest
    public static void funcTestHandleSubmitNegative() {
        Id fakeAccountId = VATEST_IdFactory.get(Account.SObjectType);
        Id fakeContactId = VATEST_IdFactory.get(Contact.SObjectType);

        String testAddrSerialized = '{"street":"123 Test St",  "city":"Miami", "state":"FL", "country":"United States", "zipCode":"00000"}';

        //mocking needs exact param
        SObjectType objType = VCC_e911_Metrics__c.SObjectType;
        sObject sampleMetric = objType.newSObject();
        sampleMetric.put('VCC_Patient_Account__c', fakeContactId);
        sampleMetric.put('VCC_Street__c', '123 Test St');
        sampleMetric.put('VCC_City__c', 'Miami');
        sampleMetric.put('VCC_State__c', 'FL');
        sampleMetric.put('VCC_Country__c', 'United States');
        sampleMetric.put('VCC_Zip_Code__c', '00000');
        sampleMetric.put('VCC_Non_Address__c', '');

        Contact tempContact = new Contact(Id = fakeContactId);

        VCR_ContactRepo stubContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ tempContact })
            .defineStub();

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(fakeContactId)
            .returning(new List<VCC_e911_Metrics__c>())
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(sampleMetric)
            .returning(
                (Database.UpsertResult) JSON.deserialize(
                    '{"success":false,"errors":[{"message":"test error","statusCode":"00"}]}',
                    Database.UpsertResult.class
                )
            )
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedContactRepo = stubContactRepo;
        VCC_E911ConfirmLocationController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        Test.startTest();
        String result = VCC_E911ConfirmLocationController.handleSubmit(null, fakeAccountId, testAddrSerialized, null);
        Test.stopTest();

        Assert.areEqual(
            result,
            'Errors: [{"statusCode":"00","message":"test error","fields":[]}]',
            'Expecting sample error message but returned something else: ' + result
        );
    }

    /**
     * @description Tests the handling of a submit action with proper parameters passed in expectantly. Top to bottom handlind of E911 record retrieval, creation/update, and upsert
     */
    @IsTest
    public static void funcTestHandleSubmitPositive() {
        Id fakeAccountId = VATEST_IdFactory.get(Account.SObjectType);
        Id fakeContactId = VATEST_IdFactory.get(Contact.SObjectType);
        Id fakeMetricId = VATEST_IdFactory.get(VCC_e911_Metrics__c.SObjectType);

        String testAddrSerialized = '{"street":"123 Test St",  "city":"Miami", "state":"FL", "country":"United States", "zipCode":"00000"}';

        //mocking needs exact param
        SObjectType objType = VCC_e911_Metrics__c.SObjectType;
        sObject sampleMetric = objType.newSObject();
        sampleMetric.put('VCC_Patient_Account__c', fakeContactId);
        sampleMetric.put('VCC_Street__c', '123 Test St');
        sampleMetric.put('VCC_City__c', 'Miami');
        sampleMetric.put('VCC_State__c', 'FL');
        sampleMetric.put('VCC_Country__c', 'United States');
        sampleMetric.put('VCC_Zip_Code__c', '00000');
        sampleMetric.put('VCC_Non_Address__c', '');

        Contact tempContact = new Contact(Id = fakeContactId);

        VCR_ContactRepo stubContactRepo = (VCR_ContactRepo) new VATEST_StubBuilder(VCR_ContactRepo.class)
            .mockingMethodCall('getContactFromAccountId', String.class)
            .withParameterValues(fakeAccountId)
            .returning(new List<Contact>{ tempContact })
            .defineStub();

        VCR_E911MetricsRepo stubE911MetricsRepo = (VCR_E911MetricsRepo) new VATEST_StubBuilder(
                VCR_E911MetricsRepo.class
            )
            .mockingMethodCall('getE911MetricsByContactId', String.class)
            .withParameterValues(fakeContactId)
            .returning(new List<VCC_e911_Metrics__c>())
            .mockingMethodCall('doUpsert', SObject.class)
            .withParameterValues(sampleMetric)
            .returning(
                (Database.UpsertResult) JSON.deserialize(
                    '{"success":true,"id":"' + fakeMetricId + '"}',
                    Database.UpsertResult.class
                )
            )
            .defineStub();

        VCC_E911ConfirmLocationController.memoizedContactRepo = stubContactRepo;
        VCC_E911ConfirmLocationController.memoizedE911MetricsRepo = stubE911MetricsRepo;

        Test.startTest();
        String result = VCC_E911ConfirmLocationController.handleSubmit(null, fakeAccountId, testAddrSerialized, null);
        Test.stopTest();

        Assert.areEqual(
            result,
            'Success ' + fakeMetricId,
            'Expecting success with id but returned something else: ' + result
        );
    }
}
