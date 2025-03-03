@IsTest
public with sharing class VCC_DirectivesServiceTest {
    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub directivesServiceStub = VCC_DirectivesService.stub();
        Assert.isTrue(
            directivesServiceStub.instance === VCC_DirectivesService.instance,
            'Expected stub and service instance to be same.'
        );
        Test.stopTest();
    }

    @IsTest
    static void siteConstructorTest() {
        Test.startTest();
        Assert.isTrue(new Site() != null, 'Site constructed.');
        Test.stopTest();
    }

    @IsTest
    static void siteAddDirectiveTest() {
        VCC_Stub facilityServiceStub = VCC_FacilityService.stub();
        VCC_FacilityService.FacilityId facilityId = new VCC_FacilityService.FacilityId();
        facilityId.facilityNumber = '123';
        facilityServiceStub.setReturnValue('parseFacilityId', facilityId);

        Test.startTest();
        VCC_DirectivesService.Site site = new VCC_DirectivesService.Site();
        Assert.isTrue(site.facilityIdToDirectivesMap.isEmpty(), 'Expected empty map.');
        VCC_BridgNotesRS.DocumentItem item = new VCC_BridgNotesRS.DocumentItem();
        item.documentTypeName = 'Advanced Directive';
        site.addDirective(VCC_FacilityService.instance.parseFacilityId('123'), item);
        Assert.isTrue(!site.facilityIdToDirectivesMap.isEmpty(), 'Expected non-empty map.');
        Assert.isTrue(
            site.facilityIdToDirectivesMap.containsKey(facilityId.toString().toLowerCase()),
            'Expected to find key.'
        );
        Assert.isTrue(
            !site.facilityIdToDirectivesMap.get(facilityId.toString().toLowerCase()).isEmpty(),
            'Expected to find non-empty list.'
        );
        Test.stopTest();
    }

    @IsTest
    static void isDirectiveTest() {
        VCC_BridgNotesRS.DocumentItem docItem1 = new VCC_BridgNotesRS.DocumentItem();
        VCC_BridgNotesRS.DocumentItem docItem2 = new VCC_BridgNotesRS.DocumentItem();
        docItem2.documentTypeName = 'Advanced Directive';
        VCC_BridgNotesRS.DocumentItem docItem3 = null;
        VCC_BridgNotesRS.DocumentItem docItem4 = new VCC_BridgNotesRS.DocumentItem();
        docItem4.localTitle = 'release';
        VCC_BridgNotesRS.DocumentItem docItem5 = new VCC_BridgNotesRS.DocumentItem();
        docItem5.localTitle = 'other value';

        Test.startTest();

        Assert.isTrue(VCC_DirectivesService.instance.isDirective(docItem1) == false, 'Expected false.');
        Assert.isTrue(VCC_DirectivesService.instance.isDirective(docItem2) == true, 'Expected true.');
        Assert.isTrue(VCC_DirectivesService.instance.isDirective(docItem3) == false, 'Expected false.');
        Assert.isTrue(VCC_DirectivesService.instance.isDirective(docItem4) == true, 'Expected true.');
        Assert.isTrue(VCC_DirectivesService.instance.isDirective(docItem5) == false, 'Expected false.');

        Test.stopTest();
    }

    @IsTest
    static void getDirectivesTestBadHttp() {
        VCC_Stub bridgClientStub = new VCC_Stub(VCC_BridgClient.class);
        VCC_BaseClient.BaseResponse notesRsBase = new VCC_BaseClient.BaseResponse();
        notesRsBase.statusCode = 404;
        notesRsBase.httpResponse = new HttpResponse();
        notesRsBase.httpResponse.setBody('test');
        bridgClientStub.setReturnValue('notesBase', notesRsBase);

        VCC_DirectivesService.DirectivesServiceException expectedException;

        Test.startTest();
        try {
            VCC_DirectivesService.instance.getDirectives(
                new VCC_BridgNotesRQ(),
                (VCC_BridgClient) bridgClientStub.instance
            );
        } catch (VCC_DirectivesService.DirectivesServiceException e) {
            expectedException = e;
        }
        Assert.isTrue(expectedException != null, 'Expected error.');
        Test.stopTest();
    }

    @IsTest
    static void getDirectivesTestNoSites() {
        VCC_Stub bridgClientStub = new VCC_Stub(VCC_BridgClient.class);
        VCC_BaseClient.BaseResponse notesRsBase = new VCC_BaseClient.BaseResponse();
        notesRsBase.statusCode = 200;
        notesRsBase.httpResponse = new HttpResponse();
        notesRsBase.httpResponse.setBody(JSON.serialize(new VCC_BridgNotesRS()));
        bridgClientStub.setReturnValue('notesBase', notesRsBase);

        Test.startTest();
        Assert.isTrue(
            VCC_DirectivesService.instance.getDirectives(
                    new VCC_BridgNotesRQ(),
                    (VCC_BridgClient) bridgClientStub.instance
                )
                .size() == 0,
            'Expected an empty list.'
        );
        Test.stopTest();
    }

    @IsTest
    static void getDirectivesTestNoItems() {
        VCC_Stub bridgClientStub = new VCC_Stub(VCC_BridgClient.class);

        VCC_BridgNotesRQ notesRq = new VCC_BridgNotesRQ();
        notesRq.max = '1000';

        VCC_BridgNotesRS.DocumentSite documentSite1 = new VCC_BridgNotesRS.DocumentSite();
        documentSite1.data.totalItems = '100';

        VCC_BaseClient.BaseResponse notesRsBase = new VCC_BaseClient.BaseResponse();
        notesRsBase.statusCode = 200;
        notesRsBase.httpResponse = new HttpResponse();
        bridgClientStub.setReturnValue('notesBase', notesRsBase);

        VCC_BridgNotesRS notesRs = new VCC_BridgNotesRS();
        notesRs.sites.add(documentSite1);

        notesRsBase.httpResponse.setBody(JSON.serialize(notesRs));

        Test.startTest();
        List<VCC_DirectivesService.Site> siteList = VCC_DirectivesService.instance.getDirectives(
            notesRq,
            (VCC_BridgClient) bridgClientStub.instance
        );
        Assert.isTrue(siteList.size() == 1, 'Expected one site.');
        Assert.isTrue(
            siteList[0].facilityIdToDirectivesMap.isEmpty() == true,
            'Expected empty facilityToDirectivesMap.'
        );
        Assert.isTrue(siteList[0].maxRequested == 1000, 'Expected correct value.');
        Assert.isTrue(siteList[0].totalItems == 100, 'Expected correct value.');
        Assert.isTrue(siteList[0].hasMore == false, 'Expected correct value.');
        Test.stopTest();
    }

    @IsTest
    static void getDirectivesTestNoDirectives() {
        VCC_Stub bridgClientStub = new VCC_Stub(VCC_BridgClient.class);

        VCC_BridgNotesRQ notesRq = new VCC_BridgNotesRQ();
        VCC_BridgNotesRS.DocumentSite documentSite1 = new VCC_BridgNotesRS.DocumentSite();

        VCC_BaseClient.BaseResponse notesRsBase = new VCC_BaseClient.BaseResponse();
        notesRsBase.statusCode = 200;
        notesRsBase.httpResponse = new HttpResponse();
        bridgClientStub.setReturnValue('notesBase', notesRsBase);

        VCC_BridgNotesRS notesRs = new VCC_BridgNotesRS();
        notesRs.sites.add(documentSite1);

        VCC_BridgNotesRS.DocumentItem docItem1 = new VCC_BridgNotesRS.DocumentItem();
        docItem1.referenceDateTime = '19900207';
        documentSite1.data.items.add(docItem1);

        notesRsBase.httpResponse.setBody(JSON.serialize(notesRs));

        Test.startTest();
        List<VCC_DirectivesService.Site> siteList = VCC_DirectivesService.instance.getDirectives(
            notesRq,
            (VCC_BridgClient) bridgClientStub.instance
        );
        Assert.isTrue(siteList.size() == 1, 'Expected one site.');
        Assert.isTrue(
            siteList[0].minDate == VCC_DatetimeService.instance.parse(docItem1.referenceDateTime),
            'Expected matching values.'
        );
        Assert.isTrue(
            siteList[0].facilityIdToDirectivesMap.isEmpty() == true,
            'Expected empty facilityToDirectivesMap.'
        );
        Test.stopTest();
    }

    @IsTest
    static void getDirectivesTestHappy() {
        VCC_Stub bridgClientStub = new VCC_Stub(VCC_BridgClient.class);

        VCC_BridgNotesRQ notesRq = new VCC_BridgNotesRQ();
        VCC_BridgNotesRS.DocumentSite documentSite1 = new VCC_BridgNotesRS.DocumentSite();

        VCC_BaseClient.BaseResponse notesRsBase = new VCC_BaseClient.BaseResponse();
        notesRsBase.statusCode = 200;
        notesRsBase.httpResponse = new HttpResponse();
        bridgClientStub.setReturnValue('notesBase', notesRsBase);

        VCC_BridgNotesRS notesRs = new VCC_BridgNotesRS();
        notesRs.sites.add(documentSite1);

        VCC_BridgNotesRS.DocumentItem docItem1 = new VCC_BridgNotesRS.DocumentItem();
        docItem1.documentTypeName = 'Advanced Directive';
        docItem1.facilityCode = '983GG';
        documentSite1.data.items.add(docItem1);

        notesRsBase.httpResponse.setBody(JSON.serialize(notesRs));

        Test.startTest();
        List<VCC_DirectivesService.Site> siteList = VCC_DirectivesService.instance.getDirectives(
            notesRq,
            (VCC_BridgClient) bridgClientStub.instance
        );
        Assert.isTrue(siteList.size() == 1, 'Expected one site.');
        Assert.isTrue(
            siteList[0].facilityIdToDirectivesMap.isEmpty() == false,
            'Expected non-empty facilityToDirectivesMap.'
        );
        Assert.isTrue(
            siteList[0]
                .facilityIdToDirectivesMap.containsKey(
                    VCC_FacilityService.instance.parseFacilityId(docItem1.facilityCode).toString().toLowerCase()
                ),
            'Expected key.'
        );
        Test.stopTest();
    }
}
