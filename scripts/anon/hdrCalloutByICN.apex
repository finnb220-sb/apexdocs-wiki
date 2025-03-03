String icn = '1012583253V766897'; //icn also known as mvi external id on account patient record - EHLSEHU Z AAAHY
VCR_HealthDataRepo.Model healthDataModel = VCC_DischargeSummaryController.fetchHealthDataConfig(icn);

//String to Date to Datetime back to String in yyyy-MM-dd format
Date endDateFormattedDate = Date.parse(healthDataModel.workstreamSettings.endDate);
Date startDateFormattedDate = Date.parse(healthDataModel.workstreamSettings.startDate);

Datetime endDateFormattedDatetime = Datetime.newInstance(
    endDateFormattedDate.year(),
    endDateFormattedDate.month(),
    endDateFormattedDate.day()
);
Datetime startDateFormattedDatetime = Datetime.newInstance(
    startDateFormattedDate.year(),
    startDateFormattedDate.month(),
    startDateFormattedDate.day()
);

String endDate = endDateFormattedDatetime.format('yyyy-MM-dd');
String startDate = startDateFormattedDatetime.format('yyyy-MM-dd');
Integer max = healthDataModel.workstreamSettings.max;
System.debug('HealthDataModel: ' + healthDataModel);
System.debug('endDate: ' + endDate);
System.debug('startDate: ' + startDate);
System.debug('max: ' + max);

Map<String, Object> args = new Map<String, Object>{
    'icn' => icn,
    'startDate' => startDate,
    'stopDate' => endDate,
    'max' => max
};

System.debug(VCC_DischargeSummaryController.getDischargeSummary(args));
