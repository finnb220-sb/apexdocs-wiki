//Apex Script to insert time slot records for a given Clinic
//Instructions: Replace the VCC_Clinic__r.VCC_IEN__c field value in the query with the VCC_IEN__c of the clinic you want to insert time slot records for.
//Script will insert records starting at 8am until 4pm for 300 days
VCC_Clinic_Schedule__c clinicSchedule = [
    SELECT Id
    FROM VCC_Clinic_Schedule__c
    WHERE VCC_Clinic__r.VCC_IEN__c = '23157'
];
List<VCC_Clinic_Schedule_Slot__c> timeSlots = new List<VCC_Clinic_Schedule_Slot__c>();
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(8, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(9, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(10, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(11, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(12, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(13, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(14, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(15, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
for (Integer i = 0; i < 300; i++) {
    Datetime slotStart = Datetime.newInstance(Date.today().addDays(i), Time.newInstance(16, 0, 0, 0));
    Datetime slotEnd = slotStart.addHours(1);

    timeSlots.add(
        new VCC_Clinic_Schedule_Slot__c(
            Name = slotStart.toString(),
            VCC_Start__c = slotStart,
            VCC_End__c = slotEnd,
            VCC_Available__c = 1,
            VCC_Overbooked__c = false,
            VCC_Original__c = 1,
            VCC_Available_Raw__c = '1',
            VCC_Overbooked_Outside_Slot__c = false,
            VCC_Clinic_Schedule__c = clinicSchedule.Id,
            VCC_Cancelled__c = false,
            VCC_Number_Overbooked__c = 0
        )
    );
}
insert timeSlots;
