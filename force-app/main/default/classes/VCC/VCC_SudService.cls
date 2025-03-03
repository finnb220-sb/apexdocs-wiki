/**
 * @description This service is a helper
 * @author VAHC CRM Development Team
 * @since 10/28/2022
 */

public with sharing class VCC_SudService {
    private static List<String> loincCodes = getLoincCodes(); //TODO: move to custom metadata
    // drives the order of rendering
    private static Map<Integer, String> indexMap = new Map<Integer, String>{
        0 => 'Test',
        1 => 'DateTestVCC',
        2 => 'Status',
        3 => 'Interpretation',
        4 => 'Result',
        5 => 'Sample',
        6 => 'Provider',
        7 => 'Loinc'
    };

    List<VCC_Lab> suds;

    /**
     * @description Static method that returns the sud panel of a list of formatted labs
     * @param flattenedLabs
     * @return  `List<VCC_Lab>`
     */
    VCC_SudService extractSudsFromLabList(List<VCC_LabModal.Lab> flattenedLabs) {
        List<VCC_Lab> suds = new List<VCC_Lab>();

        for (VCC_LabModal.lab lab : flattenedLabs) {
            // if loinc code is not a match for this lab, go to the next iteration of loop
            if (loincCodes.contains(lab.loinc?.value)) {
                suds.add(
                    new VCC_Lab(
                        null,
                        String.valueOf(lab.collected?.collectedDate),
                        lab.interpretation?.value,
                        lab.loinc?.value,
                        lab.provider?.name,
                        lab.result?.value,
                        lab.sample?.value,
                        lab.status?.value,
                        lab.test?.value
                    )
                );
            }
        }

        this.suds = suds;
        return this;
    }

    public VCC_SudService(List<VCC_LabModal.Lab> flattenedLabs) {
        this.validate(flattenedLabs); // throws an error if invalid, catch on parent service
        this.extractSudsFromLabList(flattenedLabs);
    }

    //TODO: enable this method to validate against different constructors

    /**
     * @description Validates that the constructor is built from a valid list of labs
     * @param flattenedLabs
     * @return  `Boolean`
     * @exception VCC_InternalException
     */
    Boolean validate(List<VCC_LabModal.Lab> flattenedLabs) {
        if (flattenedLabs == null || flattenedLabs.size() < 1) {
            Logger.debug('VCC_SudService: Invalid constructor input ' + JSON.serialize(flattenedLabs));
            /**
             * STOP - before you change the following line:
             * VCC_PatientLabService.updateProgressNoteWithSUDInformation depends on it to determine
             * if no Recent SUD Labs exist.
             */
            throw new VCC_InternalException('VCC_SudService: Constructor invalid, please pass in a valid list of labs.');
        }
        return true;
    }

    /**
     * @description Stringifies the sud panel so it can be saved to a long text area field on a record
     * @return  `String` Stringifed SUD Panel
     */
    public String toSudString() {
        List<String> sudStrings = new List<String>();
        Set<String> setHeader = new Set<String>();
        String sudStringsData = '';
        for (VCC_Lab sud : this.suds) {
            // iterating through list of sud objects
            Map<String, Object> untypedSud = (Map<String, Object>) JSON.deserializeUntyped(JSON.serialize(sud)); // converting object to map so we can iterate through the keys
            List<String> keys = new List<String>(untypedSud.keySet());

            for (Integer i = 0; i < keys.size(); i++) {
                // iterating through each property of sud object
                setHeader.add(indexMap.get(i) + ' - ');
                sudStringsData += (/* + ': ' +*/ untypedSud.get(indexMap.get(i)) + ' - ') /*+ (i == keys.size() - 1 ? '\n\n' : '\n')*/;
            }
            sudStringsData.removeEnd('-');
            sudStringsData += ' \n\n ';
        }
        setHeader.add('\n\n');
        sudStrings.addAll(setHeader);
        sudStrings.add(sudStringsData);

        return String.join(sudStrings, '  ').replace('DateTestVCC', 'Date').replace('null', '\u2014').removeEnd('\n'); // chopping off trailing carriage return
    }

    static List<String> getLoincCodes() {
        List<VCC_Loinc__mdt> loincRecs = new VCC_LoincCodeSelector().selectAll();
        Set<String> loincCodes = new Set<String>();

        for (VCC_Loinc__mdt rec : loincRecs) {
            loincCodes.add(rec.VCC_Loinc_Code__c);
        }

        return new List<String>(loincCodes);
    }
}
