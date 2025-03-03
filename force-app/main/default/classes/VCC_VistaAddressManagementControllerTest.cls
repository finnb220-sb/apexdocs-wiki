/**
 * @description        This class is to test the VCC_VistaAddressManagementController
 * @author             Booz Allen Hamilton
 *
 * @see VCC_VistaAddressManagementController
 **/
@IsTest
private with sharing class VCC_VistaAddressManagementControllerTest {
    private static final User PHARMACY_USER;
    private static final User SYS_ADMIN_USER;

    static {
        PHARMACY_USER = new VATEST_UserBuilder()
            .withUserProfile('VAVET Base Profile')
            .withPermissionSet('VCC_Pharmacy_I_User')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withStandardData()
            .build(true);
    }

    @IsTest
    static void unitGetRecentViewPositive() {
        VCC_VistaAddressManagementController.recentViewRepo = createRecentViewRepo(
            'getRecentViewFromUser',
            new List<VCC_Recent_View__c>()
        );
        List<VCC_Recent_View__c> recentViewList;
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            recentViewList = VCC_VistaAddressManagementController.getRecentView();
        }
        Test.stopTest();
        Assert.isNotNull(recentViewList, 'Expected class to be initialized');
    }

    /**
     * @description test getRecentView() negative
     */
    @IsTest
    static void unitGetRecentViewNegative() {
        System.runAs(PHARMACY_USER) {
            List<VCC_Recent_View__c> recentViewList = new List<VCC_Recent_View__c>();
            VCC_VistaAddressManagementController.recentViewRepo = createRecentViewRepo(
                'getRecentViewFromUser',
                recentViewList
            );
            Test.startTest();
            recentViewList = VCC_VistaAddressManagementController.getRecentView();
            Test.stopTest();
            Assert.isNotNull(recentViewList, 'Expected recentViewList to not be null');
            Assert.isTrue(recentViewList.size() == 0, 'Expected recentViewList to be null');
        }
    }

    @IsTest
    static void unitPopulateMailingAddressesPositive() {
        Map<String, Object> args = new Map<String, Object>();
        args.put('icn', '1012835497V805284');
        args.put('facilityIds', new List<String>{ '982' });
        VTC_DataModel model = new VTC_DataModel();
        VTC_Address address = new VTC_Address();
        address.street1 = 'A street';
        address.city = 'A city';
        address.state = 'A state';
        address.zip = 'A zip';

        VTC_Site site = new VTC_Site();
        site.Id = '982';
        site.records.add((VTC_Record) address);
        model.sites.add(site);

        VCC_VistaAddressManagementController.pharmacyRepo = createPharmacyRepo(args, 'getMailingAddresses', model);
        VTC_DataModel data = new VTC_DataModel();
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            data = VCC_VistaAddressManagementController.getMailingAddressesVTC(args);
        }
        Test.stopTest();
        Assert.areEqual(1, data.sites.size(), 'Expected 1, but got ' + data.sites.size());
        Assert.isTrue(String.isNotBlank(data.sites[0].id), 'Expected a value, but got an empty string.');
    }

    @IsTest
    static void unitPopulateMailingAddressesNegative() {
        Map<String, Object> args = new Map<String, Object>();
        VTC_DataModel data = new VTC_DataModel();
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            data = VCC_VistaAddressManagementController.getMailingAddressesVTC(args);
        }
        Test.stopTest();
        Assert.isNull(data, 'Expected data to be null');
    }

    @IsTest
    static void unitUpdateMailingAddressesPositive() {
        Map<Object, Object> address = new Map<Object, Object>();
        address.put('siteCode', '982');
        address.put('street1', '100 Main st');

        Map<String, Object> args = new Map<String, Object>();
        args.put('icn', '1012835497V805284');
        args.put('facilityIds', new List<String>{ '982' });
        args.put('newAddress', address);

        VTC_DataModel model = new VTC_DataModel();
        VTC_Site resultSite = new VTC_Site();
        resultSite.id = '982';
        model.sites.add(resultSite);

        VCC_VistaAddressManagementController.pharmacyRepo = createPharmacyRepo(args, 'updateMailingAddresses', model);
        VTC_DataModel result = new VTC_DataModel();
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            result = VCC_VistaAddressManagementController.updateMailingAddressesVTC(args);
        }
        Test.stopTest();
        Assert.areEqual(1, result.sites.size(), 'Expected 1, but got ' + result.sites.size());
        Assert.isTrue(String.isNotBlank(result.sites[0].Id), 'Expected a value, but got an empty string.');
    }

    @IsTest
    static void unitUpdateMailingAddressesNegative() {
        Map<String, Object> args = new Map<String, Object>();
        VTC_DataModel data = new VTC_DataModel();
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            data = VCC_VistaAddressManagementController.getMailingAddressesVTC(args);
        }
        Test.stopTest();
        Assert.isNull(data, 'Expected data to be null');
    }

    @IsTest
    static void unitPopulateTemporaryAddressesPositive() {
        Map<String, Object> args = new Map<String, Object>();
        args.put('icn', '1012835497V805284');
        args.put('facilityIds', new List<String>{ '982' });
        VTC_DataModel model = new VTC_DataModel();
        VTC_TempAddress tempAddress = new VTC_TempAddress();
        VTC_Address address = new VTC_Address();
        address.street1 = 'A street';
        address.city = 'A city';
        address.state = 'A state';
        address.zip = 'A zip';
        tempAddress.address = address;
        tempAddress.tempAddActive = 'inactive';

        VTC_Site site = new VTC_Site();
        site.Id = '982';
        site.records.add((VTC_Record) tempAddress);
        model.sites.add(site);

        VCC_VistaAddressManagementController.pharmacyRepo = createPharmacyRepo(args, 'getTemporaryAddresses', model);
        VTC_DataModel data = new VTC_DataModel();
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            data = VCC_VistaAddressManagementController.getTemporaryAddressesVTC(args);
        }
        Test.stopTest();
        Assert.areEqual(1, data.sites.size(), 'Expected 1, but got ' + data.sites.size());
        Assert.isTrue(String.isNotBlank(data.sites[0].id), 'Expected a value, but got an empty string.');
    }

    @IsTest
    static void unitPopulateTemporaryAddressesNegative() {
        Map<String, Object> args = new Map<String, Object>();
        VTC_DataModel data = new VTC_DataModel();
        Test.startTest();
        System.runAs(PHARMACY_USER) {
            data = VCC_VistaAddressManagementController.getTemporaryAddressesVTC(args);
        }
        Test.stopTest();
        Assert.isNull(data, 'Expected data to be null');
    }

    private static VCR_PharmacyRepo createPharmacyRepo(Map<String, Object> args, String mockCall, Object returnValue) {
        return (VCR_PharmacyRepo) new VATEST_StubBuilder(VCR_PharmacyRepo.class)
            .mockingMethodCall(mockCall)
            .withParameterTypes(Map<String, Object>.class)
            .withParameterValues(args)
            .returning(returnValue)
            .defineStub();
    }

    private static VCR_RecentViewRepo createRecentViewRepo(String mockCall, Object returnValue) {
        return (VCR_RecentViewRepo) new VATEST_StubBuilder(VCR_RecentViewRepo.class)
            .mockingMethodCall(mockCall)
            .withParameterTypes()
            .returning(returnValue)
            .defineStub();
    }
}
