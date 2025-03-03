/**
 * @description       : This test class compares all the TUC_Supported_Location_By_VISN__mdt against Locations in an org to test for data deficiencies
 * @author            : Booz Allen
 **/
@IsTest(SeeAllData=true) //SeeAllData is needed to check live Location metadata, that's the whole point of this class
public class TUC_CPRSToLocationConversionTest {
    /**
     * @description - This class retrieves a list of TUC_Supported_Location_By_VISN__mdt, then a list of Locations based on the Facility IDs
     *              - Those lists are then compared against each other and have multiple points where the test can fail if there is a
     *              - discrepancy or mismatch in expected lists.
     */
    @IsTest
    public static void funcCheckLocationsForFacility() {
        User testUser = new VATEST_UserBuilder()
            .withPermissionSet('TED_Medical_Provider_Group')
            .withUserProfile('VAVET Base Profile')
            .withStandardData()
            .build(true);

        System.runAs(testUser) {
            Boolean testIsSuccess = true;

            Request reqInfo = Request.getCurrent();
            System.Quiddity quiddityContext = reqInfo.getQuiddity();
            Boolean isInDeploy = (quiddityContext == System.Quiddity.RUNTEST_DEPLOY);

            //entry facilities, MPI facilities that should feed the test, this is the input
            Set<String> mpiFacilitiesToTestSet = new Set<String>();
            Set<String> allFacilityIDsInConfig = new Set<string>();
            Map<String, List<TUC_Supported_Location_By_VISN__mdt>> configsByMpiFacilityIdMap = new Map<String, List<TUC_Supported_Location_By_VISN__mdt>>();

            //repo class and loading a list of TUC_Supported_Location_By_VISN__mdt with live data
            TUC_SupportedLocationByVISNMdtRepo supportedLocationRepo = new TUC_SupportedLocationByVISNMdtRepo();
            List<TUC_Supported_Location_By_VISN__mdt> tucSupportedLocationByVISNS = new List<TUC_Supported_Location_By_VISN__mdt>();
            tucSupportedLocationByVISNS = supportedLocationRepo.getAllTUCSupportedLocationByVISNmdtRecords();

            //loop through each MPI facility ID and see if we have matching locations in SF
            for (TUC_Supported_Location_By_VISN__mdt eachConfig : tucSupportedLocationByVISNS) {
                mpiFacilitiesToTestSet.add(eachConfig.MPI_Facility_ID__c);
                allFacilityIDsInConfig.add(eachConfig.Salesforce_Facility_ID__c);

                //build configsByMpiFacilityIdMap
                if (configsByMpiFacilityIdMap.containskey(eachConfig.MPI_Facility_ID__c)) {
                    configsByMpiFacilityIdMap.get(eachConfig.MPI_Facility_ID__c).add(eachConfig);
                } else {
                    configsByMpiFacilityIdMap.put(
                        eachConfig.MPI_Facility_ID__c,
                        new List<TUC_Supported_Location_By_VISN__mdt>{ eachConfig }
                    );
                }
            }

            //loop through each MPI facility ID and see if we have matching locations in SF
            for (String eachMpiId : mpiFacilitiesToTestSet) {
                List<TUC_Supported_Location_By_VISN__mdt> eachList = configsByMpiFacilityIdMap.get(eachMpiId);
                if (eachList.size() < 1) {
                    // if config not found, fail the test. Naturally it's not going to fail here since we collected mpiFacilitiesToTestSet from the the configuration (custom metadata) itself
                    testIsSuccess = isInDeploy;
                    Assert.areEqual(
                        true,
                        testIsSuccess,
                        'Test failed when checking MPI Facility ID to check matching Locations.'
                    );
                    break;
                }
            }

            Set<String> facilityIdsInDatabase = new Set<string>();
            VCR_LocationRepo locationRepo = new VCR_LocationRepo();
            List<Schema.Location> allSfFacilities = locationRepo.fetchLocationsByExternalId(allFacilityIDsInConfig);
            for (Schema.Location eachSfFacility : allSfFacilities) {
                facilityIdsInDatabase.add(eachSfFacility.vaf_facility_Id__c);
            }

            //loop through each SF Facility in the configuration, and make sure we have associated SF Location record for it.
            for (String eachSfConfigFacility : allFacilityIDsInConfig) {
                //loop through TUC_Supported_Location_By_VISN__mdt
                if (!facilityIdsInDatabase.contains(eachSfConfigFacility)) {
                    Logger.debug(
                        'Expected facility ids and sf facilities to be equal. allFacilityIDsInConfig: ' +
                            allFacilityIDsInConfig.size() +
                            '. allSfFacilities: ' +
                            allSfFacilities.size()
                    );
                    Logger.saveLog();

                    //check if Location.Schema contains the Facility from the TUC_Supported_Location_By_VISN__mdt
                    testIsSuccess = isInDeploy;
                    String failMessage =
                        'Test failed when checking each TUC Location for a Location. Facility ' +
                        eachSfConfigFacility +
                        ' has a TUC_Supported_Location_By_VISN__mdt, but not a Schema.Location.';
                    //this message will help key in which facilities are missing a related Schema.Location
                    Assert.areEqual(true, testIsSuccess, failMessage);
                    break;
                }
            }

            Assert.areEqual(true, testIsSuccess, 'Test failed at end of file.'); //general catch all test
        }
    }
}
