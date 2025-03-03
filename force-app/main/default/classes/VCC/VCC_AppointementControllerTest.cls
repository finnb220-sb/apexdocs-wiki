@IsTest
private class VCC_AppointementControllerTest {
    @IsTest
    private static void getAppointments() {
        Account account = createAccount('Patient1', 'texrf123456st', false);
        insert account;

        Test.setMock(HttpCalloutMock.class, new VCC_HttpMock());
        Test.startTest();
        VCC_AppointmentLightningRequestWrp appointmentReqWrp = new VCC_AppointmentLightningRequestWrp();
        appointmentReqWrp.recordId = account.Id;
        appointmentReqWrp.facility = '613';
        appointmentReqWrp.startDate = '1950-01-01';
        appointmentReqWrp.endDate = '2050-01-01';
        //VCC_AppointmentService.enviornment = 'PROD';
        VCC_AppointmentResponseWrp appointmentResWrp = VCC_AppointementController.getAppointments(appointmentReqWrp);

        try {
            VCC_AppointementController.getAppointments(null);
        } catch (Exception ex) {
            Logger.debug('VCC_AppointmentsController Call Failure: ' + ex.getMessage());
            Logger.saveLog();
        }
        System.assertNotEquals(202, appointmentResWrp.statusCode);

        //VCC_AppointmentService.enviornment = 'TEST';
        appointmentResWrp = VCC_AppointementController.getAppointments(appointmentReqWrp);
        System.assertNotEquals(202, appointmentResWrp.statusCode);

        Test.stopTest();
    }

    @IsTest
    private static void getTrainingModeAppointments() {
        Account account = VCC_TrainingModeTestDataFactory.createMasterTrainingModeAccount('Get', 'Training');
        insert account;

        VCC_Training_Mode_Data__c trainingModeData = VCC_TrainingModeTestDataFactory.createTrainingModeData(
            account.Id,
            'Appointments',
            'Appointments',
            '{"appointmentsData":{"templateId":"AppointmentsRead1","requestId":"3fa7e3f5-6962-40a6-ac26-1ff87bd518e8","patients":{"patient":[{"requestedResolvedIdentifiers":{"requestedResolvedIdentifier":[{"identity":"29918","assigningFacility":"613","assigningAuthority":"USVHA"}]},"requestedExcludedIdentifiers":{"requestedExcludedIdentifier":[]},"resultantIdentifiers":{"resultantIdentifier":[{"identity":"29918","assigningFacility":"613","assigningAuthority":"USVHA"}]},"appointments":{"appointment":[{"recordIdentifier":{"identity":"2330414.083","namespaceId":"613_2.98"},"patient":{"identifier":{"identity":"29918","assigningFacility":"613"},"name":{}},"appointmentDateTime":{"literal":"202312011200"},"location":{"identifier":{"identity":"15","name":"A ADMN PROCESSING"},"telephone":"3627","institution":{"identifier":{"identity":"613","name":"AKRON CBOC"},"officialVAName":"AKRON CBOC"}},"clinicMeetsAtThisFacility":"YES","service":"SURGERY","division":"AKRON","providers":{"provider":[]},"other":"DR. MENON - COLONOSCOPY","appointmentStatus":{"code":"R","displayText":"SCHEDULED/KEPT"},"appointmentType":{"code":"9","displayText":"REGULAR"},"ekgDateTime":{},"xrayDateTime":{},"labDateTime":{},"status":{"code":"2","displayText":"CHECKED OUT"},"recordSource":{},"recordUpdateTime":{}},{"recordIdentifier":{"identity":"3211028.09","namespaceId":"613_2.98"},"patient":{"identifier":{"identity":"29918","assigningFacility":"613"},"name":{}},"appointmentDateTime":{"literal":"202110271055"},"location":{"identifier":{"identity":"108","name":"A PCM/HONG/WHITE"},"telephone":"3481 PAGE 633","institution":{"identifier":{"identity":"613","name":""},"officialVAName":""}},"clinicMeetsAtThisFacility":"YES","service":"MEDICINE","division":"AKRON","providers":{"provider":[{"nameGiven":"ASHOK","nameFamily":"KHATTRI","nameTitle":"PHYSICIAN","displayName":"KHATTRI,ASHOK"},{"nameGiven":"GABRIELLE","nameMiddle":"S","nameFamily":"VAUGHN","nameTitle":"IT SPECIALIST.","displayName":"VAUGHN,GABRIELLE S"},{"nameGiven":"MARJORIE","nameMiddle":"M","nameFamily":"CROMB","nameTitle":"RESPIRATORY THERAPIST","displayName":"CROMB,MARJORIE M"},{"nameGiven":"TERRI","nameMiddle":"A","nameFamily":"DANTZIC","nameTitle":"LICENSED PRACTICAL NURSE","displayName":"DANTZIC,TERRI A"},{"nameGiven":"DARICE","nameMiddle":"M","nameFamily":"SNYDER","nameTitle":"LICENSED PRACTICAL NURSE","displayName":"SNYDER,DARICE M"},{"nameGiven":"KRISTA","nameMiddle":"M","nameFamily":"DAVIDSON","nameTitle":"RESPIRATORY THERAPIST","displayName":"DAVIDSON,KRISTA M"},{"nameGiven":"LAURA","nameMiddle":"L","nameFamily":"PEARRELL","nameTitle":"RESPIRATORY THERAPIST","displayName":"PEARRELL,LAURA L"},{"nameGiven":"MITZI","nameMiddle":"G","nameFamily":"WILT","nameTitle":"RESPIRATORY THERAPIST","displayName":"WILT,MITZI G"},{"nameGiven":"TAMARA","nameMiddle":"L","nameFamily":"DONATO","nameTitle":"RESPIRATORY THERAPIST","displayName":"DONATO,TAMARA L"},{"nameGiven":"KATHY","nameMiddle":"M","nameFamily":"VANKIRK","nameTitle":"RESPIRATORY THERAPIST","displayName":"VANKIRK,KATHY M"},{"nameGiven":"KENT","nameMiddle":"E","nameFamily":"WAGONER","nameTitle":"RESPIRATORY THERAPIST","displayName":"WAGONER,KENT E"},{"nameGiven":"DEBORAH","nameMiddle":"D","nameFamily":"WILLIS","nameTitle":"RESPIRATORY THERAPIST","displayName":"WILLIS,DEBORAH D"},{"nameGiven":"SANDRA","nameMiddle":"L","nameFamily":"JOHNSTON","nameTitle":"RESPIRATORY THERAPIST","displayName":"JOHNSTON,SANDRA L"}]},"appointmentStatus":{"code":"NS","displayText":"SCHEDULED/KEPT"},"appointmentType":{"code":"9","displayText":"REGULAR"},"ekgDateTime":{},"xrayDateTime":{},"labDateTime":{},"status":{"code":"4","displayText":"NO-SHOW"},"recordSource":{},"recordUpdateTime":{}},{"recordIdentifier":{"identity":"3211026.1","namespaceId":"613_2.98"},"patient":{"identifier":{"identity":"29918","assigningFacility":"613"},"name":{}},"appointmentDateTime":{"literal":"202110261849"},"location":{"identifier":{"identity":"108","name":"B PODIATRY/MODIFIED"},"telephone":"3481 PAGE 633","institution":{"identifier":{"identity":"613","name":"BRECKSVILLE VANPH"},"officialVAName":"BRECKSVILLE VANPH"}},"clinicMeetsAtThisFacility":"YES","service":"MEDICINE","division":"BRECKSVILLE","providers":{"provider":[{"nameGiven":"ASHOK","nameFamily":"KHATTRI","nameTitle":"PHYSICIAN","displayName":"KHATTRI,ASHOK"},{"nameGiven":"GABRIELLE","nameMiddle":"S","nameFamily":"VAUGHN","nameTitle":"IT SPECIALIST.","displayName":"VAUGHN,GABRIELLE S"},{"nameGiven":"MARJORIE","nameMiddle":"M","nameFamily":"CROMB","nameTitle":"RESPIRATORY THERAPIST","displayName":"CROMB,MARJORIE M"},{"nameGiven":"TERRI","nameMiddle":"A","nameFamily":"DANTZIC","nameTitle":"LICENSED PRACTICAL NURSE","displayName":"DANTZIC,TERRI A"},{"nameGiven":"DARICE","nameMiddle":"M","nameFamily":"SNYDER","nameTitle":"LICENSED PRACTICAL NURSE","displayName":"SNYDER,DARICE M"},{"nameGiven":"KRISTA","nameMiddle":"M","nameFamily":"DAVIDSON","nameTitle":"RESPIRATORY THERAPIST","displayName":"DAVIDSON,KRISTA M"},{"nameGiven":"LAURA","nameMiddle":"L","nameFamily":"PEARRELL","nameTitle":"RESPIRATORY THERAPIST","displayName":"PEARRELL,LAURA L"},{"nameGiven":"MITZI","nameMiddle":"G","nameFamily":"WILT","nameTitle":"RESPIRATORY THERAPIST","displayName":"WILT,MITZI G"},{"nameGiven":"TAMARA","nameMiddle":"L","nameFamily":"DONATO","nameTitle":"RESPIRATORY THERAPIST","displayName":"DONATO,TAMARA L"},{"nameGiven":"KATHY","nameMiddle":"M","nameFamily":"VANKIRK","nameTitle":"RESPIRATORY THERAPIST","displayName":"VANKIRK,KATHY M"},{"nameGiven":"KENT","nameMiddle":"E","nameFamily":"WAGONER","nameTitle":"RESPIRATORY THERAPIST","displayName":"WAGONER,KENT E"},{"nameGiven":"DEBORAH","nameMiddle":"D","nameFamily":"WILLIS","nameTitle":"RESPIRATORY THERAPIST","displayName":"WILLIS,DEBORAH D"},{"nameGiven":"SANDRA","nameMiddle":"L","nameFamily":"JOHNSTON","nameTitle":"RESPIRATORY THERAPIST","displayName":"JOHNSTON,SANDRA L"}]},"appointmentStatus":{"code":"R","displayText":"SCHEDULED/KEPT"},"appointmentType":{"code":"9","displayText":"REGULAR"},"ekgDateTime":{},"xrayDateTime":{},"labDateTime":{},"status":{"code":"2","displayText":"CHECKED OUT"},"recordSource":{},"recordUpdateTime":{}}]}}]},"errorSection":{"errors":{"error":[]},"fatalErrors":{"fatalError":[]},"warnings":{"warning":[]}}}}'
        );
        insert trainingModeData;

        VCC_AppointmentLightningRequestWrp appointmentReqWrp = new VCC_AppointmentLightningRequestWrp();
        appointmentReqWrp.recordId = account.Id;
        appointmentReqWrp.facility = '613';
        //appointmentReqWrp.startDate = '1950-01-01';
        appointmentReqWrp.startDate = System.now().addYears(-1).addMonths(-4).format('yyyy-MM-dd');
        appointmentReqWrp.endDate = '2050-01-01';

        Test.startTest();
        VCC_AppointementController.getTrainingModeAppointments(appointmentReqWrp);
        Test.stopTest();
    }

    private static Account createAccount(String lastName, String mviId, Boolean isTrainingAccount) {
        RecordType personAccountRecordType = [
            SELECT Id
            FROM RecordType
            WHERE Name = 'Person Account' AND SobjectType = 'Account'
        ];

        return new Account(LastName = lastName, VCC_MVI_External_Id__pc = mviId, RecordTypeId = personAccountRecordType.Id, Is_Training_Account__c = isTrainingAccount);
    }

    private static VCC_Training_Mode_Data__c createTrainingModeData(String name, String type, Id accountId) {
        VCC_Training_Mode_Data__c trainingModeData = new VCC_Training_Mode_Data__c();
        trainingModeData.Account__c = accountId;
        trainingModeData.Name = name;
        trainingModeData.Data__c = '{"appointmentsData":null}';
        trainingModeData.Type__c = type;
        return trainingModeData;
    }
}
