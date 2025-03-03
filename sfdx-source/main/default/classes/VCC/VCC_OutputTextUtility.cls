@SuppressWarnings('PMD.ApexDoc')
public without sharing class VCC_OutputTextUtility {
    @SuppressWarnings('PMD.ApexDoc,PMD.ApexCRUDViolation,PMD.AvoidSoqlWithoutLimits')
    public static void import() {
        // Query MP user with in VAHC Medical Providers
        User mpUser = [SELECT ID, NAME FROM USER WHERE ID IN (SELECT USERORGROUPID FROM GroupMember WHERE Group.Name = 'VAHC Medical Providers') AND IsActive = TRUE LIMIT 1];

        // Create Output Text records
        List<VCC_Output_Text__c> outPutTexts = new List<VCC_Output_Text__c>{
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Dosage and Administration',
                VCC_Display_Text__c = '- 800 mg (four 200 mg capsules) taken orally every 12 hours for 5 days, with or without food.- Not authorized for use for longer than 5 consecutive days.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#1
            new VCC_Output_Text__c(
                Name = 'Molnupiravir User Consent Disposition',
                VCC_Display_Text__c = 'Patient and/or caregiver is consenting to Molnupiravir use.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#2
            new VCC_Output_Text__c(
                Name = 'Treatment Disclaimer',
                VCC_Display_Text__c = 'Patient was informed that those with COVID-19 symptoms, and high-risk conditions, taking oral (by mouth) at home treatment can lower risk of severe symptoms or needing to be hospitalized. Treatments need to be started within five days from when you first started having symptoms and could be picked up at a local VHA or mailed to them.',
                OwnerId = mpUser.Id
            ), //#3
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Consent',
                VCC_Display_Text__c = 'The patient and/or caregiver is consenting to Molnupiravir use.  The patient and/or caregiver is aware of the EUA status and limitations of Molnupiravir and understands they have the right to decline treatment.  The patient and/or caregiver has been provided with and reviewed the FDA Emergency Use Authorization (EUA) Fact Sheet for Molnupiravir and was also informed of the known and potential risks and benefits of treatment with this product.  The patient and/or caregiver has also been informed of alternative treatments (and the risks and benefits of those), and that Molnupiravir is not an FDA approved product.',
                VCC_Link__c = 'https://www.fda.gov/media/155055/download',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#4
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Limitation of EUA',
                VCC_Display_Text__c = '-       Molnupiravir is NOT authorized for patients under 18 years of age-       Molnupiravir is NOT authorized for initiation of treatment in patients requiring hospitalization due to COVID-19-       Molnupiravir is NOT authorized for use for longer than 5 consecutive days-       Molnupiravir is NOT authorized as pre-exposure or post-exposure prophylaxis for prevention of COVID-19',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#5
            new VCC_Output_Text__c(
                Name = 'Patient Agrees to Participate in Pregnancy Surveillance Program',
                VCC_Display_Text__c = 'Patient agrees to participate in the pregnancy surveillance program and allows the prescribing healthcare provider to disclose patient specific information to Merck, the prescribing healthcare provider must provide the patient\'s name and contact information to Merck (at 1-877-888-4231 or pregnancyreporting.msd.com )',
                VCC_Link__c = 'https://pregnancyreporting.msd.com/',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#6
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Use Benefits and Risks During Pregnancy',
                VCC_Display_Text__c = 'Patient was counseled and made aware of the known and potential benefits and potential risks of Molnupiravir use during pregnancy.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#7
            new VCC_Output_Text__c(
                Name = 'Pregnancy Surveillance Program Awareness',
                VCC_Display_Text__c = 'The patient was made aware of the pregnancy surveillance program and was willing to have the provider report to Merck for enrollment.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#8
            new VCC_Output_Text__c(
                Name = 'Pregnancy Surveillance Program Awareness If Become Pregnant',
                VCC_Display_Text__c = 'Patient and their partner were made aware of the pregnancy surveillance program and were encouraged to participate should they become pregnant. They were told to notify their medical provider should that occur during treatment.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#9
            new VCC_Output_Text__c(
                Name = 'Patient Agrees To Participate in PSP If Become Pregnant',
                VCC_Display_Text__c = 'The patient agrees to participate in the program and patient specific information will be shared with Merck for enrollment.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#10
            new VCC_Output_Text__c(
                Name = 'Reviewed Contraception Requirements per Molnupiravir Providers Fact Sheet',
                VCC_Display_Text__c = 'Reviewed contraception requirements per Molnupiravir Providers Fact Sheet.',
                VCC_Link__c = 'https://www.fda.gov/media/155054/download',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#11
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Treatment Criteria',
                VCC_Display_Text__c = '* Not recommended for use during pregnancy* Age  > or = 18 years* Alternate COVID-19 treatment options authorized by FDA are not accessible or clinically appropriate as per the FDA EUA documents* Symptoms consistent with mild-moderate COVID-19* Not hospitalized due to COVID-19* Males of reproductive potential treated and if sexually active with females of childbearing potential, should use a reliable method of contraception correctly and consistently during treatment and for at least 3 months after the last dose* Assessment pregnancy and breastfeeding status (if applicable)* Patient was provided appropriate counseling * Females of childbearing potential treated: should use a reliable method of contraception correctly and consistently, as applicable, for the duration of treatment and for 4 days after the last dose of Molnupiravir* Breastfeeding is not recommended for the duration of treatment and for 4 days after the last dose of Molnupiravir* The patient has at least one high-risk criteria for progression to severe disease, as defined by the CDC',
                VCC_Link__c = 'https://www.cdc.gov/coronavirus/2019-ncov/need-extra-precautions/people-with-medical-conditions.html',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#12
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Treatment Enrollment',
                VCC_Display_Text__c = 'Patient has been enrolled in the follow up COVID -19 treatment program per VISN protocol.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#13
            new VCC_Output_Text__c(
                Name = 'Molnupiravir Patient Adverse Reaction Report Awareness',
                VCC_Display_Text__c = 'Patient was made aware to report any adverse reactions or events to their health care provider since the prescribing healthcare provider and/or the provider\'s designee must report all medication errors and serious adverse events potentially related to Molnupiravir within 7 calendar days from the healthcare provider\'s awareness of the event.',
                VCC_Treatment__c = 'Molnupiravir',
                OwnerId = mpUser.Id
            ), //#14
            new VCC_Output_Text__c(
                Name = 'Positive Test Confirmed',
                VCC_Display_Text__c = 'Patient has confirmed that they have reported a positive home COVID-19 test within the last 5 days from a verified FDA approved list to CCC CT RN.',
                OwnerId = mpUser.Id
            ), //#15
            new VCC_Output_Text__c(
                Name = 'Paxlovid Consent',
                VCC_Display_Text__c = 'The patient and/or caregiver is consenting to Paxlovid use.  The patient and/or caregiver is aware of the EUA status and limitations of Paxlovid and understands they have the right to decline treatment.  The patient and/or caregiver has been provided with and reviewed the FDA EUA Fact Sheet - Paxlovid for Paxlovid and was also informed of the known and potential risks and benefits of treatment with this product.  The patient and/or caregiver has also been informed of alternative treatments (and the risks and benefits of those), and that Paxlovid is not an FDA approved product.',
                VCC_Link__c = 'https://www.fda.gov/media/155051/download',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#16
            new VCC_Output_Text__c(
                Name = 'Paxlovid Patient Counseled',
                VCC_Display_Text__c = 'Patient counseled about the narrow window of time to start the medication ( 5 days from when symptoms started, and within 5  days of a positive COVID test) and to call back to the CCC if they wish to reconsider treatment options during this time frame.',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#17
            new VCC_Output_Text__c(
                Name = 'Paxlovid and or Molnupiravir Not Considered',
                VCC_Display_Text__c = 'Paxlovid and/or Molnupiravir will not be currently considered.',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#18
            new VCC_Output_Text__c(
                Name = 'Paxlovid Limitation of EUA',
                VCC_Display_Text__c = '-Paxlovid is NOT authorized for initiation of treatment in patients requiring hospitalization due to the severe or critical COVID-19.-Paxlovid is NOT authorized for pre-exposure or post-exposure prophylaxis for prevention of COVID-19.-Paxlovid is NOT authorized for use longer than 5 consecutive days.-Paxlovid is NOT currently recommended in patients with severe renal impairment (eGFR < 30 mL/min)-Paxlovid is NOT currently recommended in patients with severe hepatic impairment (Child-Pugh Class C)',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#19
            new VCC_Output_Text__c(
                Name = 'Paxlovid Contraindications',
                VCC_Display_Text__c = 'Paxlovid is contraindicated with drugs that are highly dependent on CYP3A for clearance and for which elevated concentrations are associated with serious and/or life-threatening reactions. For example, patient is not currently taking any of the following medications OR if taking, is unable to safely hold therapy during the duration of treatment with Paxlovid:Alpha-1-adrenoreceptor antagonist: AlfuzosinAnalgesics: Pethidine, Piroxicam, PropoxypheneAntianginal: RanolazineAntiarrhythmic: Amiodarone, Dronedarone, Flecainide, Propafenone, QuinidineAnti-gout: ColchicineAntipsychotics: Lurasidone, Pimozide, ClozapineErgot derivatives: Dihydroergotamine, Ergotamine, MethylergonovineHMG-CoA reductase inhibitors: Lovastatin, SimvastatinPDE5 inhibitor: Sildenafil (Revatior) when used for pulmonary arterial hypertension (PAH)Sedative/hypnotics: Triazolam, oral Midazolam""Paxlovid is contraindicated with drugs that are potent CYP3A inducers where significantly reduced Nirmatrelvir or Ritonavir plasma concentrations may be associated with the potential for loss of virologic response and possible resistance. Paxlovid cannot be started immediately after discontinuation of any of the following medications due to the delayed offset of the recently discontinued CYP3A inducer. For example, patient is not currently taking any of the following medications:Anticancer drugs: ApalutamideAnticonvulsant: Carbamazepine, Phenobarbital, PhenytoinAntimycrobacterials: RifampinHerbal products: St. John\'s Wort (hypericum perforatum)\"',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#20
            new VCC_Output_Text__c(
                Name = 'Paxlovid Review Completed',
                VCC_Display_Text__c = 'Prescriber has completed a comprehensive review of the patient\'s medication list for other drugs that may interact, and require adjustments to therapy or increased monitoring as outlined in the Fact Sheet for Health Care Providers, or by using a resource such as the Liverpool COVID-19 during interactions site:  Liverpool COVID-19 Interactions or',
                VCC_Link__c = 'https://covid19-druginteractions.org/',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#21
            new VCC_Output_Text__c(
                Name = 'Patient and or Caregiver Consents to Paxlovid Use',
                VCC_Display_Text__c = 'Patient and or Caregiver is consenting to Paxlovid use.  Patient told to make sure to call us if they have worsening symptoms from COVID-19. They were told if they experience severe symptoms, like trouble breathing, to please seek care at the nearest emergency department right away. It\'s also important that they call to let us know if they have any side effects (contact info given).',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#22
            new VCC_Output_Text__c(
                Name = 'Patient enrolled in follow-up Covid-19 Treatment',
                VCC_Display_Text__c = 'The patient has been enrolled in the follow up COVID -19 treatment program per VISN protocol.',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            ), //#23
            new VCC_Output_Text__c(
                Name = 'Medication adjustments needed',
                VCC_Display_Text__c = 'Medication adjustments needed as follows:',
                VCC_Treatment__c = 'Paxlovid',
                OwnerId = mpUser.Id
            )
        }; //#24

        insert outPutTexts;
    }
}
