/**
 * @description test class for PC_AvailabilityGanttChart
 * @author      Booz Allen
 * @since       2024
 * @see         PC_AvailabilityGanttChart
 **/
@IsTest
public with sharing class PC_AvailabilityGanttChart_Test {
    /**
     * @description       : Creates test setup data
     **/
    @testSetup
    public static void makeData() {
        List<String> channels = new List<String>{ 'Chat', 'Teams', 'Phone' };
        List<Skill> lsChannelSKills = [SELECT Id FROM Skill WHERE MasterLabel IN :channels LIMIT 3];
        ServiceResource pcSR = null;

        User pcManager = generateUserWithAccess('PrC_Specialist_Manager_Users', 'Test Manager');
        User specialistUser = generateUserWithAccess('PrC_Specialist_Users', 'Test PC Specialist');

        System.runAs(pcManager) {
            pcSR = PC_TestDataFactory.createServiceResource(specialistUser.Id, specialistUser.LastName, 'Cardiology');
            PC_TestDataFactory.createServiceResourceSkill(pcSR.Id, lsChannelSKills[0].Id);
        }

        System.runAs(pcManager) {
            PC_Service__c pcService = new PC_Service__c(PC_Specialty__c = 'Cardiology', Active__c = true);
            insert pcService;
            PC_Service_Team_Member__c pcstm = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService.Id,
                PC_Service_Resource__c = pcSR.Id
            );
            insert pcstm;
            Date shiftDate = Date.newInstance(2023, 9, 10);
            PC_Specialist_Availability__c avail = new PC_Specialist_Availability__c(
                PC_Week_Ending_Date__c = shiftDate,
                PC_Service_Resource__c = pcSR.Id
            );
            insert avail;
            pcScheduleShiftsController.insertShift(pcService.Id, pcstm.Id, '05:00', '12:00', shiftDate, '9/10/2023');
            pcScheduleShiftsController.insertShift(pcService.Id, pcstm.Id, '05:30', '14:00', shiftDate, '9/10/2023');
            pcScheduleShiftsController.insertShift(pcService.Id, pcstm.Id, '06:30', '13:00', shiftDate, '9/10/2023');
        }
    }
    /**
     * @description       : Tests the main chart. Verifies times are producing the correct intervals for the bars
     **/
    @IsTest
    public static void unitGetChartDataTest() {
        ServiceResource serviceRes = [SELECT Id FROM ServiceResource WHERE Name = 'Test PC Specialist' LIMIT 1];
        User provider = generateUserWithAccess('PrC_FLP_Users', 'flp User');
        System.runAs(provider) {
            Map<String, Object> chartData = PC_AvailabilityGanttChart.getChartData('9/10/2023');
            List<Object> chartDataStruct = (List<Object>) chartData.get('skills');
            for (Object skills : chartDataStruct) {
                Map<String, Object> skill = (Map<String, Object>) skills;
                if (skill.get('shiftsByServiceResource') != null) {
                    Map<String, Object> shiftsByServiceResource = (Map<String, Object>) skill.get(
                        'shiftsByServiceResource'
                    );
                    if (!shiftsByServiceResource.isEmpty()) {
                        if (shiftsByServiceResource.containsKey(serviceRes.Id)) {
                            Map<String, Object> shifts = (Map<String, Object>) shiftsByServiceResource.get(
                                serviceRes.Id
                            );
                            System.assertEquals(shifts.get('left'), 5, 'Incorrect Gantt Calculation');
                            System.assertEquals(shifts.get('right'), 14, 'Incorrect Gantt Calculation');
                        }
                    }
                }
            }
        }
    }

    /**
     * @description helper method to generate an test user with the specified permission set groupfor use in test methods
     * @param       permissionSetGroupName api name of the permission set group to give the user
     * @param       lastName Controller class executes with last name = 'Test PC Manager'
     * @return      `User` Salesforce user with the appropriate permission set group
     */
    private static User generateUserWithAccess(String permissionSetGroupName, String lastName) {
        VATEST_UserBuilder pcTestUser = new VATEST_UserBuilder();
        pcTestUser.withPermissionSet(permissionSetGroupName).withUserProfile('VAVET Base Profile').withStandardData();
        pcTestUser.resultingUser.LastName = lastName;
        return pcTestUser.build(true);
    }
}
