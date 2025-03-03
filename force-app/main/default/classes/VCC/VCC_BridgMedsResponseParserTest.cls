/**
 * @author Booz Allen
 * @description Test class for VCC_BridgMedsResponseParser.
 *              This class validates the functionality and behavior of the VCC_BridgMedsResponseParser class.
 * @see VCC_BridgMedsResponseParser
 */
@IsTest
public with sharing class VCC_BridgMedsResponseParserTest {
    private static final String JSON_RESPONSE_STRING;
    private static final User PHARM_I_USER;
    static {
        JSON_RESPONSE_STRING = '{"sites":[{"results":{"meds":{"total":"2","med":[{"expires":{"value":"2990924"},"doses":{"dose":[{"doseStart":"2980923","doseStop":"2990923"}]},"vaStatus":{"value":"DISCONTINUED"},"fillsAllowed":{"value":"2"},"medID":{"value":"4996848;O"},"pharmacist":{},"lastFilled":{"value":"2980923"},"type":{"value":"Prescription"},"products":{"product":[{"vaGeneric":{"code":"2105","name":"OCTREOTIDE","vuid":"4019864"},"code":"6218","role":"D","vaProduct":{"code":"8497","name":"OCTREOTIDE ACETATE 0.1MG/ML INJ","vuid":"4008958"},"name":"OCTREOTIDE 100 MCG/ML INJ 1ML AMP","concentration":"0.1 MG/ML","class":{"code":"GA208","name":"ANTIDIARRHEAL AGENTS","vuid":"4021619"},"ordItem":{}}]},"sig":{"content":"INJECT 75 MCG (0.75 ML) UNDER THE SKIN QAM - REFRIGERATE"},"routing":{"value":"W"},"fillsRemaining":{"value":"2", "formattedValue":"2991111"},"id":{"value":"12335346"},"fills":{"fill":[{"fillDate":"2980923","fillDaysSupply":"30","fillQuantity":"60","fillRouting":"W","releaseDate":"2980929"}]},"vaType":{"value":"O"},"ordered":{"value":"2980923.094631"},"orderingProvider":{"code":"101651","service":"UROLOGY","name":"TAN,BENG J","fax":"216.421.3038"},"quantity":{"value":"60"},"orderID":{"value":"12335346"},"daysSupply":{"value":"30"},"start":{"value":"2980923"},"fillCost":{"value":"349.32"},"form":{"value":"INJ"},"stop":{"value":"2980930"},"prescription":{"value":"10025440"},"name":{"value":"OCTREOTIDE INJ"},"location":{"code":"3068","name":"W41S"},"facility":{"code":"541","name":"CLEVELAND VAMC"},"currentProvider":{"code":"101651","service":"UROLOGY","name":"TAN,BENG J","fax":"216.421.3038"},"status":{"value":"not active"},"ptInstructions":{},"IMO":{},"parent":{},"ivLimit":{},"supplemental":{"outpatientRxFields":{"placerNumber": "ExpectedPlacerNumber","erxHubId": "ExpectedErxHubId","rxPatientStatus":{},"ecme":{},"providerComments":{"text":[]},"drug":{},"copayTransactionType":{}},"pendingMedFields":{"clinic":{},"orderableItem":{"dosageForm":{"nouns":{"noun":[]},"dispenseUnitsPerDose":{"unit":[]}}}},"nonVaMedFields":{"documentedBy":{},"comments":[],"disclaimers":[]}}},{"expires":{},"doses":{"dose":[{"route":"IV"}]},"vaStatus":{"value":"DISCONTINUED"},"fillsAllowed":{},"medID":{"value":"85V;I"},"pharmacist":{"code":"131773","name":"PUGACZ,ADAM M"},"lastFilled":{},"type":{},"products":{"product":[{"vaGeneric":{"code":"42","name":"SODIUM CHLORIDE","vuid":"4017444"},"code":"2673","role":"B","vaProduct":{"code":"451","name":"SODIUM CHLORIDE 0.9% INJ","vuid":"4001068"},"name":"SODIUM CHLORIDE 0.9% IVPB 100ML","concentration":"1000 ML","class":{"code":"TN102","name":"IV SOLUTIONS WITH ELECTROLYTES","vuid":"4021703"},"ordItem":{"code":"3401","name":"SODIUM CHLORIDE 0.9% IV INJ"}}]},"sig":{},"routing":{},"fillsRemaining":{},"id":{"value":"27600166"},"fills":{"fill":[]},"vaType":{"value":"V"},"ordered":{"value":"3041029.081"},"orderingProvider":{"code":"115975","service":"MEDICAL-(W)","name":"BLACK,JAMES","officePhone":"32802"},"quantity":{},"orderID":{"value":"27600166"},"daysSupply":{},"start":{"value":"3041029.081"},"fillCost":{},"form":{},"stop":{"value":"3041029.0945"},"prescription":{},"name":{"value":"SODIUM CHLORIDE 0.9% IV INJ"},"location":{"code":"892","name":"W42M"},"facility":{"code":"541","name":"CLEVELAND VAMC"},"currentProvider":{"code":"115975","service":"MEDICAL-(W)","name":"BLACK,JAMES","officePhone":"32802"},"status":{"value":"not active"},"ptInstructions":{},"IMO":{},"parent":{},"ivLimit":{},"supplemental":{"outpatientRxFields":{"rxPatientStatus":{},"ecme":{},"providerComments":{"text":[]},"drug":{},"copayTransactionType":{}},"pendingMedFields":{"clinic":{},"orderableItem":{"dosageForm":{"nouns":{"noun":[]},"dispenseUnitsPerDose":{"unit":[]}}}},"nonVaMedFields":{"documentedBy":{},"comments":[],"disclaimers":[]}}}]},"timeZone":"-0400","version":"1.13"},"errorSection":{"errors":[{"displayMessage":"Test Error"},{"displayMessage":"Test Error2"}],"fatalErrors":[],"warnings":[]},"siteSupplemental":{"serviceConnected":{"conditions":{"condition":[],"conditionPercentage":[]}},"eligibility":{}}}]}';
        PHARM_I_USER = new VATEST_UserBuilder()
            .withPermissionSet('VAHC_Write_Clinical_Triage_Progress_Note')
            .withPermissionSet('VCC_Pharmacy_I')
            .withPermissionSet('VAHC_Standard_VCC_User')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);
    }

    /**
     * @description Validates that the transformDate method correctly converts dates.
     */
    @IsTest
    public static void transformDateTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            Assert.areEqual(
                VCC_BridgMedsResponseParser.transformDate('2990216'),
                '1999-02-16',
                'Expected transformDate to convert "2990216" to "1999-02-16", but received a different value. Please check the transformDate logic.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates that transformDate handles invalid input gracefully by returning an empty string.
     */
    @IsTest
    public static void transformDateThrowExceptionTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            Assert.areEqual(
                '',
                VCC_BridgMedsResponseParser.transformDate('29$0216'),
                'Expected transformDate to return an empty string for invalid input "29$0216", but received a different value. Please check the transformDate logic.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates that the addMonthSearch method correctly identifies the month from a given date.
     */
    @IsTest
    public static void monthSearchTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            Assert.areEqual(
                VCC_BridgMedsResponseParser.addMonthSearch('2990216'),
                'February',
                'Expected addMonthSearch to return "February" for the input "2990216", but received a different value. Please check the addMonthSearch logic.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates that addMonthSearch handles invalid input gracefully by returning an empty string.
     */
    @IsTest
    public static void monthSearchThrowExceptionTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            Assert.areEqual(
                '',
                VCC_BridgMedsResponseParser.addMonthSearch('29$0216'),
                'Expected addMonthSearch to return an empty string for invalid input "29$0216", but received a different value. Please check the addMonthSearch logic.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Tests the deserialization and parsing functionality of VCC_BridgMedsResponseParser.
     */
    @IsTest
    public static void parseTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            VCC_BridgMedsResponseParser medsResponse = (VCC_BridgMedsResponseParser) JSON.deserialize(
                JSON_RESPONSE_STRING,
                VCC_BridgMedsResponseParser.class
            );
            Assert.isNotNull(
                medsResponse,
                'Expected JSON deserialization to produce a valid VCC_BridgMedsResponseParser object, but received null. Please check the JSON format or parsing logic.'
            );
            Assert.isNotNull(
                medsResponse.sites,
                'Expected the sites list in the deserialized response to be populated, but it was null. Please verify the JSON structure.'
            );
            Assert.areEqual(
                medsResponse.sites.size(),
                1,
                'Expected the sites list to contain exactly 1 element, but found a different count. Please check the parsing logic.'
            );

            Assert.isNotNull(
                medsResponse.sites[0].results,
                'Expected the results field in the first site to be populated, but it was null. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsResponse.sites[0].errorSection,
                'Expected the errorSection field in the first site to be populated, but it was null. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsResponse.sites[0].siteSupplemental,
                'Expected the siteSupplemental field in the first site to be populated, but it was null. Please verify the deserialization logic.'
            );

            Assert.areEqual(
                medsResponse.sites[0].results.meds.total,
                '2',
                'Expected the total field of meds in the first site\'s results to be "2", but received a different value. Please check the deserialization logic.'
            );
            Assert.areEqual(
                medsResponse.sites[0].results.meds.med.size(),
                2,
                'Expected meds.med list to have 2 entries in the first site, but found a different size. Please verify the JSON structure or parsing logic.'
            );
            Assert.areEqual(
                medsResponse.sites[0].results.meds.med[0].expires.value,
                '2990924',
                'Expected meds.med[0].expires.value to be "2990924", but found a different value. Please verify the deserialization logic.'
            );

            Assert.areEqual(
                medsResponse.sites[0].errorSection.errors.size(),
                2,
                'Expected errorSection.errors to have 2 entries in the first site, but found a different size. Please verify the error parsing logic.'
            );
            Assert.areEqual(
                medsResponse.sites[0].errorSection.errors[0].displayMessage,
                'Test Error',
                'Expected errorSection.errors[0].displayMessage to be "Test Error", but found a different value. Please verify the error message handling.'
            );

            VCC_BridgMedsResponseParser.OutpatientRxFields outpatientRxFields = medsResponse.sites[0]
                .results.meds.med[0]
                .supplemental.outpatientRxFields;
            Assert.areEqual(
                'ExpectedPlacerNumber',
                outpatientRxFields.placerNumber,
                'Expected outpatientRxFields.placerNumber to be "ExpectedPlacerNumber", but found a different value. Please verify the field mapping.'
            );
            Assert.areEqual(
                'ExpectedErxHubId',
                outpatientRxFields.erxHubId,
                'Expected outpatientRxFields.erxHubId to be "ExpectedErxHubId", but found a different value. Please verify the field mapping.'
            );

            VCC_BridgMedsResponseParser.MedsFillsRemaining medsFillsRemaining = medsResponse.sites[0]
                .results.meds.med[0]
                .fillsRemaining;
            Assert.areEqual(
                '2',
                medsFillsRemaining.value,
                'Expected medsFillsRemaining.value to be "2", but found a different value. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsFillsRemaining.formattedValue,
                'Expected medsFillsRemaining.formattedValue to be not null, but found null. Please verify the field initialization.'
            );

            VCC_BridgMedsResponseParser.MedsOrdered medsOrdered = medsResponse.sites[0].results.meds.med[0].ordered;
            Assert.areEqual(
                '2980923.094631',
                medsOrdered.value,
                'Expected medsOrdered.value to be "2980923.094631", but found a different value. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsOrdered.formattedValue,
                'Expected medsOrdered.formattedValue to be not null, but found null. Please verify the field initialization.'
            );

            VCC_BridgMedsResponseParser.MedsQuantity medsQuantity = medsResponse.sites[0].results.meds.med[0].quantity;
            Assert.areEqual(
                '60',
                medsQuantity.value,
                'Expected medsQuantity.value to be "60", but found a different value. Please verify the field mapping.'
            );
            Assert.isNotNull(
                medsQuantity.formattedValue,
                'Expected medsQuantity.formattedValue to be not null, but found null. Please verify the field initialization.'
            );

            VCC_BridgMedsResponseParser.MedsQuantity medsQuantity1 = medsResponse.sites[0].results.meds.med[1].quantity;
            Assert.isNull(
                medsQuantity1.value,
                'Expected medsQuantity1.value to be null, but found a value. Please verify the field mapping.'
            );
            Assert.areEqual(
                0,
                medsQuantity1.formattedValue,
                'Expected medsQuantity1.formattedValue to be "0", but found a different value. Please verify the field mapping.'
            );

            VCC_BridgMedsResponseParser.MedsStart medsStart = medsResponse.sites[0].results.meds.med[0].start;
            Assert.areEqual(
                '2980923',
                medsStart.value,
                'Expected medsStart.value to be "2980923", but found a different value. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsStart.valueMonth,
                'Expected medsStart.valueMonth to be not null, but found null. Please verify the field initialization.'
            );
            Assert.isNotNull(
                medsStart.formattedValue,
                'Expected medsStart.formattedValue to be not null, but found null. Please verify the field initialization.'
            );

            VCC_BridgMedsResponseParser.MedsStop medsStop = medsResponse.sites[0].results.meds.med[0].stop;
            Assert.areEqual(
                '2980930',
                medsStop.value,
                'Expected medsStop.value to be "2980930", but found a different value. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsStop.formattedValue,
                'Expected medsStop.formattedValue to be not null, but found null. Please verify the field initialization.'
            );

            VCC_BridgMedsResponseParser.MedsFill medsFill = medsResponse.sites[0].results.meds.med[0].fills.fill[0];
            Assert.areEqual(
                '2980923',
                medsFill.fillDate,
                'Expected medsFill.fillDate to be "2980923", but found a different value. Please verify the deserialization logic.'
            );
            Assert.isNotNull(
                medsFill.formattedFillDate,
                'Expected medsFill.formattedFillDate to be not null, but found null. Please verify the field initialization.'
            );
            Assert.isNotNull(
                medsFill.releaseDateMonth,
                'Expected medsFill.releaseDateMonth to be not null, but found null. Please verify the field initialization.'
            );
            Assert.isNotNull(
                medsFill.formattedReleaseDate,
                'Expected medsFill.formattedReleaseDate to be not null, but found null. Please verify the field initialization.'
            );

            VCC_BridgMedsResponseParser.Dose medsDose = medsResponse.sites[0].results.meds.med[0].doses.dose[0];
            Assert.areEqual(
                '2990923',
                medsDose.doseStop,
                'Expected medsDose.doseStop to be "2990923", but found a different value. Please verify the field mapping.'
            );
            Assert.areEqual(
                '2980923',
                medsDose.doseStart,
                'Expected medsDose.doseStart to be "2980923", but found a different value. Please verify the field mapping.'
            );
            Assert.isNotNull(
                medsDose.formattedDoseStop,
                'Expected medsDose.formattedDoseStop to be not null, but found null. Please verify the field initialization.'
            );
            Assert.isNotNull(
                medsDose.formattedDoseStart,
                'Expected medsDose.formattedDoseStart to be not null, but found null. Please verify the field initialization.'
            );

            Test.stopTest();
        }
    }

    /**
     * @description Validates the behavior of the Meds class.
     */
    @IsTest
    public static void medsClassTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            VCC_BridgMedsResponseParser.Meds meds = new VCC_BridgMedsResponseParser.Meds();
            Assert.isNull(
                meds.total,
                'Expected Meds.total to be null on initialization, but found a value. Please verify the Meds constructor.'
            );
            Assert.areEqual(
                meds.med.size(),
                0,
                'Expected Meds.med list to be empty on initialization, but found elements. Please verify the Meds constructor.'
            );
            Assert.isNull(
                meds.formattedMed,
                'Expected Meds.formattedMed to be null on initialization, but found a value. Please verify the Meds constructor.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates the behavior of the MedsExpires class.
     */
    @IsTest
    public static void medsExpiresClassTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            VCC_BridgMedsResponseParser.MedsExpires medsExpires = new VCC_BridgMedsResponseParser.MedsExpires();
            Assert.isNull(
                medsExpires.value,
                'Expected MedsExpires.value to be null on initialization, but found a value. Please verify the MedsExpires constructor.'
            );
            Assert.isNotNull(
                medsExpires.expiresMonthValue,
                'Expected MedsExpires.expiresMonthValue to be initialized, but found it to be null. Please verify the MedsExpires constructor.'
            );
            Assert.isNotNull(
                medsExpires.formattedValue,
                'Expected MedsExpires.formattedValue to be initialized, but found it to be null. Please verify the MedsExpires constructor.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates the behavior of the MedsLastFilled class.
     */
    @IsTest
    public static void medsLastFilledClassTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            VCC_BridgMedsResponseParser.MedsLastFilled medsLastFilled = new VCC_BridgMedsResponseParser.MedsLastFilled();
            Assert.isNull(
                medsLastFilled.value,
                'Expected MedsLastFilled.value to be null on initialization, but found a value. Please verify the MedsLastFilled constructor.'
            );
            Assert.areEqual(
                '',
                medsLastFilled.valueMonth,
                'Expected MedsLastFilled.valueMonth to be an empty string on initialization, but found a different value. Please verify the MedsLastFilled constructor.'
            );
            Assert.areEqual(
                '',
                medsLastFilled.formattedValue,
                'Expected MedsLastFilled.formattedValue to be an empty string on initialization, but found a different value. Please verify the MedsLastFilled constructor.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates the behavior of the MedsFillsRemaining class.
     */
    @IsTest
    public static void medsFillsRemainingClassTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            VCC_BridgMedsResponseParser.MedsFillsRemaining medsFillsRemaining = new VCC_BridgMedsResponseParser.MedsFillsRemaining();
            Assert.isNull(
                medsFillsRemaining.value,
                'Expected MedsFillsRemaining.value to be null on initialization, but found a value. Please verify the MedsFillsRemaining constructor.'
            );
            Assert.isNotNull(
                medsFillsRemaining.formattedValue,
                'Expected MedsFillsRemaining.formattedValue to be initialized, but found it to be null. Please verify the MedsFillsRemaining constructor.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates the behavior of the Error and ErrorSection classes.
     */
    @IsTest
    public static void errorClassTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            VCC_BridgMedsResponseParser.Error error = new VCC_BridgMedsResponseParser.Error('error');
            VCC_BridgMedsResponseParser.ErrorSection es1 = new VCC_BridgMedsResponseParser.ErrorSection(
                new List<VCC_BridgMedsResponseParser.Error>{ error }
            );
            Assert.areEqual(
                1,
                es1.errors.size(),
                'Expected ErrorSection.errors to contain 1 error, but found a different count. Please verify the ErrorSection logic.'
            );
            Assert.areEqual(
                'error',
                es1.errors[0].displayMessage,
                'Expected ErrorSection.errors[0].displayMessage to be "error", but found a different value. Please verify the Error constructor.'
            );
            Test.stopTest();
        }
    }

    /**
     * @description Validates the transformLiteral method for date transformation.
     */
    @IsTest
    public static void transformLiteralTest() {
        System.runAs(PHARM_I_USER) {
            Test.startTest();
            String dateString = VCC_BridgMedsResponseParser.transformLiteral('19990216');
            Assert.areEqual(
                dateString,
                '1999-02-16',
                'Expected transformLiteral to convert "2990216" to "1999-02-16", but received a different value. Please check the transformLiteral logic.'
            );
            Test.stopTest();
        }
    }
}
