/**
 * VCC_TrainingModeDataDomainTest
 * @description Unit test for VCC_TrainingModeDataDomain class.
 * @author Liberty
 * @date 12/9/2021
 */
@IsTest
public with sharing class VCC_TrainingModeDataDomainTest {
    @IsTest
    private static void ctor() {
        //User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        VCC_TrainingModeDataDomain trainingModeDataDomain;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeDataDomain = new VCC_TrainingModeDataDomain();
            Test.stopTest();
        }
        System.assert(trainingModeDataDomain != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void createTrainingModeData() {
        User user = [SELECT Id, FirstName, LastName, Username, EmployeeNumber FROM User WHERE Id = :UserInfo.getUserId() LIMIT 1];
        VCC_TrainingModeAccount trainingModeAccount = new VCC_TrainingModeAccount('Unit', 'Test', '1234567', '000-86-132', 'Male', Date.today(), 'test@test.com');
        trainingModeAccount.relatedData.add(new VCC_TrainingModeData('Vet Info', 'Some data'));

        List<VCC_Training_Mode_Data__c> trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeDataDomain().createTrainingModeData(user, trainingModeAccount);
            Test.stopTest();
        }
        System.assert(trainingModeData != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void createMasterTrainingModeData() {
        VCC_TrainingModeAccount trainingModeAccount = new VCC_TrainingModeAccount('Unit', 'Test', '1234567', '000-86-132', 'Male', Date.today(), 'test@test.com');
        trainingModeAccount.relatedData.add(new VCC_TrainingModeData('Allergies', 'Some data'));
        List<VCC_Training_Mode_Data__c> trainingModeData;
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            trainingModeData = new VCC_TrainingModeDataDomain().createMasterTrainingModeData(trainingModeAccount);
            Test.stopTest();
        }
        System.assert(trainingModeData != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void refillMedications() {
        VCC_TrainingModeDataDomain trainingModeDataDomain = new VCC_TrainingModeDataDomain();

        Account account = new Account(
            FirstName = 'refillMedications',
            LastName = 'Test',
            RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Person Account').getRecordTypeId()
        );
        insert account;

        // Create test Meds training data.
        VCC_Training_Mode_Data__c trainingModeData = new VCC_Training_Mode_Data__c();
        trainingModeData.Account__c = account.Id;
        trainingModeData.Name = 'refillMedications';
        trainingModeData.Data__c = '{"sites":[{"results":{"meds":{"total":"1","med":[{"expires":{"value":"3221028"},"doses":{"dose":[{"schedule":"BID","dose":"20","doseStop":"3221028","noun":"CAPSULE","unitsPerDose":"1","units":"MG","doseStart":"3211027"}]},"vaStatus":{"value":"ACTIVE"},"fillsAllowed":{"value":"3"},"medID":{"value":"9546794;O"},"pharmacist":{"code":"520824712","name":"GEDGE,LYDSE I"},"lastFilled":{"value":"3220412"},"type":{"value":"Prescription"},"products":{"product":[{"vaGeneric":{"code":"1996","name":"FLUOXETINE","vuid":"4019761"},"code":"1082","role":"D","vaProduct":{"code":"8147","name":"FLUOXETINE HCL 20MG CAP","vuid":"4008621"},"name":"FLUOXETINE HCL 20MG CAP","concentration":"20 MG","class":{"code":"CN609","name":"ANTIDEPRESSANTS,OTHER","vuid":"4021872"},"ordItem":{}}]},"sig":{"content":"TAKE ONE CAPSULE TWICE A DAY"},"routing":{"value":"W"},"fillsRemaining":{"value":"1"},"id":{"value":"28025523"},"fills":{"fill":[{"fillDate":"3211027","fillDaysSupply":"30","fillQuantity":"60","fillRouting":"W"},{"fillDate":"3211210","fillDaysSupply":"30","fillQuantity":"60","fillRouting":"W"},{"fillDate":"3220412","fillDaysSupply":"30","fillQuantity":"60","fillRouting":"M"}]},"vaType":{"value":"O"},"ordered":{"value":"3211027.161322"},"orderingProvider":{"code":"520824671","service":"BAY PINES TEST LAB","name":"CPRSPROVIDER,EIGHTY","taxonomyCode":"203BX0901N","providerType":"Physicians (M.D. and D.O.)","classification":"Physician/Osteopath","specialization":"Otology &amp; Neurotology"},"quantity":{"value":"60"},"orderID":{"value":"28025523"},"daysSupply":{"value":"30"},"start":{"value":"3211027"},"fillCost":{"value":"1.86"},"form":{"value":"CAP,ORAL"},"stop":{"value":"3221028"},"prescription":{"value":"10951281"},"name":{"value":"FLUOXETINE CAP,ORAL"},"location":{},"facility":{"code":"982","name":"CLE13 TEST LAB"},"currentProvider":{"code":"520824671","service":"BAY PINES TEST LAB","name":"CPRSPROVIDER,EIGHTY","taxonomyCode":"203BX0901N","providerType":"Physicians (M.D. and D.O.)","classification":"Physician/Osteopath","specialization":"Otology &amp; Neurotology"},"status":{"value":"active"},"ptInstructions":{},"IMO":{},"parent":{},"ivLimit":{}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[],"fatalErrors":[],"warnings":[]}}]}';
        trainingModeData.Type__c = 'Medications';
        insert trainingModeData;

        List<String> prescriptionIds = new List<String>();
        prescriptionIds.add('10951281');
        User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testUser) {
            Test.startTest();
            trainingModeDataDomain.refillMedications(trainingModeData, prescriptionIds);
            Test.stopTest();
        }
        System.assert(trainingModeData.Data__c.contains('SUSPENDED'), 'Expected medication status to be suspended');
    }

    @IsTest
    private static void updateVetInfo() {
        Account account = VCC_TrainingModeTestDataFactory.createMasterTrainingModeAccount('updateVetInfo', 'Test');
        insert account;

        VCC_Training_Mode_Data__c trainingModeData = VCC_TrainingModeTestDataFactory.createTrainingModeData(
            account.Id,
            'updateVetInfo',
            'Vet Info',
            '{"vetsV3":[{"mviResult":"FOUND","eeResult":"FOUND","emisResult":"NO_REQUEST","vets360Result":"NOT_FOUND","bgsResult":"NO_REQUEST","mvi":{"icn":"1011117086V539813","salesforceId":"null","corpId":"null","edipi":"2110226791","esrId":"null","brlsFilenumber":"null","mviIipt":"V3","mviToken":"WSDOC2210032038239121516204377","personType":"PAT","vet360Id":"1184631","prefixName":"null","suffixName":"null","firstName":"ZLUSXYH","lastName":"AUSWLSDHYS","middleName":"G","mothersMaidenName":"MPIMMN","cityOfBirth":"EDEN","stateOfBirth":"CO","dob":"19840630","dod":"null","ssn":"101653457","itin":"null","gender":"F","sigi":"null","queryMatchObservation":"null","address":{"streetAddress":"89 Ohio St","streetAddress2":"null","streetAddress3":"null","city":"Columbia","state":"SC","postalCode":"29201","country":"USA","addressTypeCode":"PHYS"},"phoneNumber":[],"medicalCenterFacilities":[{"facilityId":"613","personId":"103704"},{"facilityId":"982","personId":"450780"},{"facilityId":"983","personId":"7223872"},{"facilityId":"984","personId":"7223872"}],"correlatedIds":[{"shortId":"1011117086V539813","longId":"1011117086V539813^NI^200M^USVHA^P","idType":"ICN_ID","idStatus":"ACTIVE"},{"shortId":"103704","longId":"103704^PI^613^USVHA^A","idType":"VHA_CORRELATED_SYSTEMS_ID","idStatus":"ACTIVE"},{"shortId":"450780","longId":"450780^PI^982^USVHA^A","idType":"VHA_CORRELATED_SYSTEMS_ID","idStatus":"ACTIVE"},{"shortId":"7223872","longId":"7223872^PI^983^USVHA^A","idType":"VHA_CORRELATED_SYSTEMS_ID","idStatus":"ACTIVE"},{"shortId":"2110226791","longId":"2110226791^NI^200DOD^USDOD^A","idType":"DOD_EDIPI_ID","idStatus":"ACTIVE"},{"shortId":"1184631","longId":"1184631^PI^200VETS^USDVA^A","idType":"OTHER","idStatus":"ACTIVE"}],"relationships":[]},"ee":{"eeVeteranStatus":"false","serviceConnectedPercentage":"null","eligibleForMedicaid":"null","priorityGroup":"null","monetaryBenefits":[],"ratedDisabilities":[],"serviceBranches":[],"eeExtendedResponse":{"associations":[{"address":{"city":"GAITHERSBURG","country":"USA","county":"USA","line1":"431 GAITHER ST","line2":"null","line3":"null","postalCode":"null","provinceCode":"null","state":"MD","zipCode":"20877","zipPlus4":"null"},"alternatePhone":"null","contactType":"Emergency Contact","familyName":"SIMPSON","givenName":"ALEX","lastUpdateDate":"20221003","middleName":"null","organizationName":"null","prefix":"null","primaryPhone":"(803) 4236321","relationship":"SPOUSE","suffix":"null"}],"demographics":{"preferredFacility":"983 - CHYSHR","assignmentDate":"20211028","unassignmentDate":"null","preferredFacilities":[{"preferredFacility":"983 - CHYSHR","assignmentDate":"20211028","unassignmentDate":"null"}]},"eligibilityVerification":{},"enrollmentDetermination":{"effectiveDate":"20211028","eligibleForMedicaid":"null","endDate":"20211028","enrollmentDate":"null","enrollmentStatus":"Not Applicable","enrollmentCategoryName":"Not Enrolled","monetaryBenefits":[],"otherEligibilities":[],"primaryEligibility":{"indicator":"P","type":"HUMANITARIAN EMERGENCY","eligibilityReportDate":"20190916"},"priorityGroup":"null","prioritySubGroup":"null","secondaryEligibilities":[],"serviceConnectionAward":{"awardDate":"null","combinedServiceConnectedPercentageEffectiveDate":"null","permanentAndTotal":"null","permanentAndTotalEffectiveDate":"null","serviceConnectedIndicator":"false","serviceConnectedPercentage":"null","unemployable":"null","scReportDate":"20190916"},"veteran":"false"},"insuranceList":[],"relations":[],"person":{},"healthBenefitPlans":[{"planName":"Humanitarian","effectiveDate":"20190916","description":"null","planCode":"null","coverageCode":"null"}]}},"vaProfileV2":{"vaProfileContactInfo":{"createDate":"2019-02-23T21:56:50Z","sourceDate":"2019-02-23T15:55:37Z","sourceSystem":"VADIR","txAuditId":"3645f343-4645-429c-a5f2-9686306e707c","updateDate":"2019-02-23T21:56:50Z","vet360Id":62783,"addresses":[{"addressId":122879,"addressLine1":"89 Ohio St","addressPurposeOfUse":"CORRESPONDENCE","addressType":"Domestic","cityName":"Columbia","confidenceScore":"0","countryCodeFips":"US","countryCodeIso2":"US","countryCodeIso3":"USA","countryName":"United States","createDate":"2020-01-10T16:39:20Z","effectiveStartDate":"2022-09-20T21:40:34Z","geocodeDate":"2022-09-20T21:40:36Z","latitude":"39.7720","longitude":"-86.1560","overrideIndicator":true,"sourceDate":"2022-09-20T21:40:34Z","sourceSystem":"VAHC","sourceSystemUser":"VAHC CRM","stateCode":"SC","txAuditId":"7753a700-45ca-4ac4-af59-c707c90ad568","updateDate":"2022-09-20T21:40:36Z","vet360Id":62783,"zipCode5":"29201"},{"addressId":122877,"addressLine1":"89 Ohio St","addressPurposeOfUse":"RESIDENCE","addressType":"Domestic","cityName":"Columbia","confidenceScore":"95","countryCodeFips":"US","countryCodeIso2":"US","countryCodeIso3":"USA","countryName":"United States","createDate":"2020-01-10T16:24:28Z","effectiveStartDate":"2022-09-08T16:33:37Z","geocodeDate":"2022-09-08T16:33:40Z","geocodePrecision":"31","latitude":"28.3638","longitude":"-81.2751","sourceDate":"2022-09-08T16:33:37Z","sourceSystem":"VAHC","sourceSystemUser":"VAHC CRM","stateCode":"SC","txAuditId":"26fc0a94-6dfb-4304-986b-125c4ccc4754","updateDate":"2022-09-08T16:33:40Z","vet360Id":62783,"zipCode5":"29201"}],"emails":[{"createDate":"2021-09-23T03:51:36Z","effectiveStartDate":"2022-09-08T15:02:07Z","emailAddressText":"asimpson@emailtest.com","emailId":192921,"sourceDate":"2022-09-08T15:02:07Z","sourceSystem":"VAHC","sourceSystemUser":"VAHC CRM","txAuditId":"9b5cf95c-96f6-401d-9da2-364d13e0e6c5","updateDate":"2022-09-08T15:02:09Z","vet360Id":62783}],"telephones":[{"areaCode":"803","countryCode":"1","createDate":"2021-09-20T06:26:33Z","effectiveStartDate":"2022-09-29T22:03:53Z","internationalIndicator":false,"phoneNumber":"4238111","phoneType":"MOBILE","sourceDate":"2022-09-29T22:03:53Z","sourceSystem":"VAHC","sourceSystemUser":"VAHC CRM","telephoneId":258848,"txAuditId":"67acee40-1cdb-4997-8a31-c0882f19057e","updateDate":"2022-09-29T22:03:56Z","vet360Id":62783},{"areaCode":"803","countryCode":"1","createDate":"2020-01-10T17:09:34Z","effectiveStartDate":"2022-09-27T22:25:47Z","internationalIndicator":false,"phoneNumber":"4236321","phoneType":"HOME","sourceDate":"2022-09-27T22:25:47Z","sourceSystem":"VAHC","sourceSystemUser":"VAHC CRM","telephoneId":97339,"txAuditId":"189ec21f-d4cd-4a7e-9112-d190ca262f1d","updateDate":"2022-09-27T22:25:50Z","vet360Id":62783},{"areaCode":"803","countryCode":"1","createDate":"2020-01-03T21:12:26Z","effectiveStartDate":"2022-09-29T01:50:45Z","internationalIndicator":false,"phoneNumber":"4232535","phoneType":"WORK","sourceDate":"2022-09-29T01:50:45Z","sourceSystem":"VAHC","sourceSystemUser":"VAHC CRM","telephoneId":95733,"txAuditId":"7deca712-f00a-4a5b-93a3-03922ddbb7b4","updateDate":"2022-09-29T01:50:48Z","vet360Id":62783}]},"vaProfilePersonAttributes":{"activePrescriptionBio":{"activePrescriptionIndicator":false}},"vaProfileIdentity":{"sensitivityInformation":{"sensitivityFlag":false}},"vaProfileAssociatedPersons":[{"givenName":"CHEYSHRECONFIRS","familyName":"CHEYSHRECONLAST","addressLine1":"555 TEST EDIT ST","city":"GREENVILLE","state":"FL","county":"USA","postalCode":"90210","country":"USA","primaryPhone":"(888) 4006677","contactType":"Emergency Contact","relationship":"UNRELATED FRIEND"},{"givenName":"CHEYSHREC","familyName":"CHEYSHRECONLAST","addressLine1":"555 MY EDIT","city":"ARLINGTON","state":"OH","county":"USA","zipCode":"22304","postalCode":"45044","country":"USA","primaryPhone":"(777) 8886664","contactType":"Primary Next of Kin","relationship":"UNRELATED FRIEND"},{"givenName":"CHEYSHRNOKFIRST","familyName":"CHEYSHRNOKLAST","addressLine1":"3333 ANYWHERE STREET","addressLine2":"HELENA","city":"HELENA","state":"AL","zipCode":"35080","country":"USA","contactType":"Other Next of Kin","relationship":"BROTHER"},{"givenName":"CHEYSHRECONFIRST","familyName":"CHEYSHRECONLAST","addressLine1":"333 ANYWHERE STREET","city":"HELENA","state":"AL","zipCode":"35080","country":"USA","contactType":"Other emergency contact","relationship":"SISTER"}]}}]}'
        );
        insert trainingModeData;

        VCC_MPIParser.EEAssociation eeAssociationEmergencyContact = new VCC_MPIParser.EEAssociation();
        eeAssociationEmergencyContact.contactType = 'Emergency Contact';

        VCC_MPIParser.EEAssociation eeAssociationNextOfKin = new VCC_MPIParser.EEAssociation();
        eeAssociationNextOfKin.contactType = 'NextOfKin';

        VCC_TrainingModeService.WriteVetInfoRQ trainingModeService = new VCC_TrainingModeService.WriteVetInfoRQ();
        trainingModeService.eeAssociations.add(eeAssociationEmergencyContact);
        trainingModeService.eeAssociations.add(eeAssociationNextOfKin);

        User testUser = VCC_TestDataFactory.insertUser('System Administrator');
        System.runAs(testUser) {
            Test.startTest();
            new VCC_TrainingModeDataDomain().updateVetInfo(account, trainingModeData, trainingModeService);
            Test.stopTest();
        }
        Assert.isNotNull(trainingModeService, 'not null');
    }

    @IsTest
    private static void updateVetInfoAccount() {
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            new VCC_TrainingModeDataDomain().updateVetInfoAccount(new Account(), new VCC_MPIParser.EEAssociation());
            Test.stopTest();
        }
    }

    @IsTest
    private static void updateVetInfoEmergencyContact() {
        // Arrange
        VCC_MPIParser trainingModeDataObj = new VCC_MPIParser();
        VCC_MPIParser.EEAssociation associatedPerson = new VCC_MPIParser.EEAssociation();
        associatedPerson.givenName = 'John';
        associatedPerson.address.postalCode = '12345';
        associatedPerson.address.zipCode = '67890';
        trainingModeDataObj.vetsV3.add(new VCC_MPIParser.VetDetails());
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations.add(associatedPerson);
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            // Act
            new VCC_TrainingModeDataDomain().updateVetInfoEmergencyContact(trainingModeDataObj, associatedPerson);
            Test.stopTest();
        }
        // Assert
        System.assertEquals('John', trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].givenName);
        System.assertEquals('12345', trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.postalCode);
        System.assertEquals('67890', trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.zipCode);
    }

    @IsTest
    private static void updateVetInfoNextOfKin() {
        // Arrange
        VCC_MPIParser trainingModeDataObj = new VCC_MPIParser();
        VCC_MPIParser.EEAssociation associatedPerson = new VCC_MPIParser.EEAssociation();
        associatedPerson.givenName = 'John';
        associatedPerson.address.postalCode = '12345';
        associatedPerson.address.zipCode = '67890';
        trainingModeDataObj.vetsV3.add(new VCC_MPIParser.VetDetails());
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations.add(associatedPerson);
        User testUser = VCC_TestDataFactory.insertUser('VAVET Base Profile');
        List<String> permissionSets = new List<String>{ 'VCC_Trainee', 'VCC_Trainer' };
        DTCTestUtil.addPermSetsToUser(testUser, permissionSets);
        System.runAs(testUser) {
            Test.startTest();
            // Act
            new VCC_TrainingModeDataDomain().updateVetInfoNextOfKin(trainingModeDataObj, associatedPerson);
        }
        // Assert
        System.assertEquals('John', trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].givenName);
        System.assertEquals('12345', trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.postalCode);
        System.assertEquals('67890', trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.zipCode);
    }
}
