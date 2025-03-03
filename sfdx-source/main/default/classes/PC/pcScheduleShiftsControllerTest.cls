@isTest
@SuppressWarnings('PMD.ApexDoc, PMD.ClassNamingConventions')
public class pcScheduleShiftsControllerTest {
    @testSetup
    public static void makeData() {
        User manager = PC_TestDataFactory.createManager('TestPCManager55');
        User specialist = PC_TestDataFactory.createSpecialist('TestPCSpecialist');
        System.runAs(manager) {
            ServiceResource sr = PC_TestDataFactory.createServiceResource(specialist.Id, 'TestPCSpecialist', 'Cardiology');
            PC_Service__c pcService = new PC_Service__c(PC_Specialty__c = 'Cardiology', Active__c = true);
            insert pcService;
            PC_Service_Team_Member__c pcstm = new PC_Service_Team_Member__c(
                PC_Service_Team_Member_Role__c = 'Specialist',
                PC_Service__c = pcService.Id,
                PC_Service_Resource__c = sr.Id
            );
            insert pcstm;
            Date shiftDate = Date.newInstance(2023, 2, 15);
            PC_Specialist_Availability__c avail = new PC_Specialist_Availability__c(PC_Week_Ending_Date__c = shiftDate, PC_Service_Resource__c = sr.Id);
            insert avail;
        }
    }
    @isTest
    public static void testPCScheduleShifts() {
        User manager = [SELECT Id FROM User WHERE LastName = 'TestPCManager55' LIMIT 1];

        System.runAs(manager) {
            PC_Service__c pcService = [SELECT Id FROM PC_Service__c LIMIT 1];
            PC_Service_Team_Member__c pcstm = [SELECT Id FROM PC_Service_Team_Member__c LIMIT 1];
            Date shiftDate = Date.newInstance(2023, 2, 15);
            pcScheduleShiftsController.insertShift(pcService.Id, pcstm.Id, '05:00', '12:00', shiftDate, '2/16/2023');
            List<PC_Shift__c> shift = [SELECT Id FROM PC_Shift__c LIMIT 1];
            System.assertEquals(1, shift.size(), 'Expected values to match');
            pcScheduleShiftsController.updateShift(shift[0].Id, '07:00', '11:00', shiftDate, '2/16/2023', pcService.Id);
            Map<Id, List<pcScheduleShiftsController.ShiftStatus>> shiftStatus = pcScheduleShiftsController.getNext7DaysShifts('2/15/2023', pcService.Id);
            System.assert(!shiftStatus.isEmpty(), 'Expected values to match');
            try {
                pcScheduleShiftsController.getSpecialistAvailability(pcstm.Id);
                System.assert(false, 'Expected values to match');
            } catch (Exception e) {
                System.assert(true, 'Expected values to match');
            }
            pcScheduleShiftsController.deleteShift(shift[0].Id, '2/16/2023', pcService.Id);
            List<PC_Shift__c> shiftsPostDelete = [SELECT Id FROM PC_Shift__c LIMIT 1];
            System.assert(shiftsPostDelete.isEmpty(), 'Expected values to match');
        }
    }

    @isTest
    public static void testGetSpecialities() {
        List<ServiceResource> serviceResources = [
            SELECT Id, PC_Assigned_Specialty__c
            FROM ServiceResource
        ];
        List<String> servResIds = new List<String>();
        for (ServiceResource sr : serviceResources) {
            servResIds.add(sr.Id);
        }
        User manager = [SELECT Id FROM User WHERE LastName = 'TestPCManager55' LIMIT 1];
        System.runAs(manager) {
            Map<Id, String> specialistMap = pcScheduleShiftsController.getSpecialities(servResIds);
            System.assertEquals(servResIds.size(), specialistMap.size());
        }
    }
}
