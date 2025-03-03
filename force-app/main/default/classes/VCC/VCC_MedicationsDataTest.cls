/**
 * VCC_MedicationsDataTest
 * @description Test for VCC_MedicationsData class.
 * @author Liberty
 * @date 12/20/2021
 */
@IsTest
public with sharing class VCC_MedicationsDataTest {
    @IsTest
    private static void ctor() {
        Test.startTest();
        VCC_MedicationsData medicationsData = new VCC_MedicationsData();
        Test.stopTest();

        System.assert(medicationsData != null, 'Expected the class to be initialized.');
    }

    @IsTest
    private static void properties() {
        Test.startTest();
        VCC_MedicationsData medicationsData = new VCC_MedicationsData();
        System.assertEquals(0, medicationsData.sites.size(), 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Site site = new VCC_MedicationsData.VCC_Site();
        System.assert(site.results != null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Meds meds = new VCC_MedicationsData.VCC_Meds();
        System.assertEquals(0, meds.med.size(), 'Expected the property to be initialized.');
        System.assert(meds.total == null, 'Expected the property to be initialized.');
        System.assert(meds.timeZone == null, 'Expected the property to be initialized.');
        System.assert(meds.version == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Med med = new VCC_MedicationsData.VCC_Med();
        System.assert(med.expires != null, 'Expected the property to be initialized.');
        System.assert(med.doses != null, 'Expected the property to be initialized.');
        System.assert(med.vaStatus != null, 'Expected the property to be initialized.');
        System.assert(med.fillsAllowed != null, 'Expected the property to be initialized.');
        System.assert(med.medID != null, 'Expected the property to be initialized.');
        System.assert(med.pharmacist != null, 'Expected the property to be initialized.');
        System.assert(med.lastFilled != null, 'Expected the property to be initialized.');
        System.assert(med.type != null, 'Expected the property to be initialized.');
        System.assert(med.products != null, 'Expected the property to be initialized.');
        System.assert(med.sig != null, 'Expected the property to be initialized.');
        System.assert(med.routing != null, 'Expected the property to be initialized.');
        System.assert(med.fillsRemaining != null, 'Expected the property to be initialized.');
        System.assert(med.id != null, 'Expected the property to be initialized.');
        System.assert(med.fills != null, 'Expected the property to be initialized.');
        System.assert(med.vaType != null, 'Expected the property to be initialized.');
        System.assert(med.ordered != null, 'Expected the property to be initialized.');
        System.assert(med.orderingProvider != null, 'Expected the property to be initialized.');
        System.assert(med.quantity != null, 'Expected the property to be initialized.');
        System.assert(med.orderID != null, 'Expected the property to be initialized.');
        System.assert(med.daysSupply != null, 'Expected the property to be initialized.');
        System.assert(med.start != null, 'Expected the property to be initialized.');
        System.assert(med.fillCost != null, 'Expected the property to be initialized.');
        System.assert(med.form != null, 'Expected the property to be initialized.');
        System.assert(med.stop != null, 'Expected the property to be initialized.');
        System.assert(med.prescription != null, 'Expected the property to be initialized.');
        System.assert(med.name != null, 'Expected the property to be initialized.');
        System.assert(med.location != null, 'Expected the property to be initialized.');
        System.assert(med.facility != null, 'Expected the property to be initialized.');
        System.assert(med.currentProvider != null, 'Expected the property to be initialized.');
        System.assert(med.status != null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Provider provider = new VCC_MedicationsData.VCC_Provider();
        System.assert(provider.content == null, 'Expected the property to be initialized.');
        System.assert(provider.service == null, 'Expected the property to be initialized.');
        System.assert(provider.email == null, 'Expected the property to be initialized.');
        System.assert(provider.vuid == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Doses doses = new VCC_MedicationsData.VCC_Doses();
        System.assertEquals(0, doses.dose.size(), 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Dose dose = new VCC_MedicationsData.VCC_Dose();
        System.assert(dose.schedule == null, 'Expected the property to be initialized.');
        System.assert(dose.dose == null, 'Expected the property to be initialized.');
        System.assert(dose.doseStop == null, 'Expected the property to be initialized.');
        System.assert(dose.route == null, 'Expected the property to be initialized.');
        System.assert(dose.noun == null, 'Expected the property to be initialized.');
        System.assert(dose.unitsPerDose == null, 'Expected the property to be initialized.');
        System.assert(dose.units == null, 'Expected the property to be initialized.');
        System.assert(dose.doseStart == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Fills fills = new VCC_MedicationsData.VCC_Fills();
        System.assertEquals(0, fills.fill.size(), 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Fill fill = new VCC_MedicationsData.VCC_Fill();
        System.assert(fill.fillDate == null, 'Expected the property to be initialized.');
        System.assert(fill.fillDaysSupply == null, 'Expected the property to be initialized.');
        System.assert(fill.fillQuantity == null, 'Expected the property to be initialized.');
        System.assert(fill.fillRouting == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Products products = new VCC_MedicationsData.VCC_Products();
        System.assertEquals(0, products.product.size(), 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_Product product = new VCC_MedicationsData.VCC_Product();
        System.assert(product.vaGeneric != null, 'Expected the property to be initialized.');
        System.assert(product.vaProduct != null, 'Expected the property to be initialized.');
        System.assert(product.x_class != null, 'Expected the property to be initialized.');
        System.assert(product.code == null, 'Expected the property to be initialized.');
        System.assert(product.role == null, 'Expected the property to be initialized.');
        System.assert(product.name == null, 'Expected the property to be initialized.');
        System.assert(product.concentration == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_ContentType contentType = new VCC_MedicationsData.VCC_ContentType();
        System.assert(contentType.content == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_CodeNameType codeNameType = new VCC_MedicationsData.VCC_CodeNameType();
        System.assert(codeNameType.code == null, 'Expected the property to be initialized.');
        System.assert(codeNameType.name == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_CodeNameVuidType codeNameVuidType = new VCC_MedicationsData.VCC_CodeNameVuidType();
        System.assert(codeNameVuidType.code == null, 'Expected the property to be initialized.');
        System.assert(codeNameVuidType.name == null, 'Expected the property to be initialized.');
        System.assert(codeNameVuidType.vuid == null, 'Expected the property to be initialized.');

        VCC_MedicationsData.VCC_ValueType valueType = new VCC_MedicationsData.VCC_ValueType();
        System.assert(valueType.value == null, 'Expected the property to be initialized.');

        Test.stopTest();
    }
}
