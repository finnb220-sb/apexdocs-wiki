@IsTest
public with sharing class VCC_DatetimeServiceTest {
    public static void initDates(Datetime dt1, Datetime dt2, Datetime dt3, Datetime dt4) {
        dt1 = Datetime.newInstance(2022, 1, 22);
        dt2 = Datetime.newInstance(2022, 2, 22);
        dt3 = Datetime.newInstance(1980, 12, 22);
        dt4 = null;
    }

    public static void initSerializedDateTime(Datetime parsedDoubleQuotes, Datetime parsedNoDoubleQuotes) {
        String dateTimeStringWithDoubleQuotes = '"2022-11-01T02:30:53.000Z"';
        String dateTimeStringNoDoubleQuotes = '2022-11-01T02:30:53.000Z';

        parsedDoubleQuotes = VCC_DatetimeService.instance.parse(dateTimeStringWithDoubleQuotes);
        parsedNoDoubleQuotes = VCC_DatetimeService.instance.parse(dateTimeStringNoDoubleQuotes);
    }

    public static void initYyyyMmDd(Datetime startDt, Datetime parsedDt) {
        startDt = Datetime.newInstance(1999, 5, 1);
        String yyyyMMdd = startDt.format('yyyyMMdd');
        parsedDt = VCC_DatetimeService.instance.parse(yyyyMMdd);
    }

    @IsTest
    static void stubTest() {
        Test.startTest();
        VCC_Stub datetimeSerivceStub = VCC_DatetimeService.stub();
        Assert.isTrue(datetimeSerivceStub.instance === VCC_DatetimeService.instance, 'Expected stub instance and service instance to be the same.');
        Test.stopTest();
    }

    @IsTest
    static void minTest() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;

        Assert.isTrue(VCC_DatetimeService.instance.min(dt1, dt2) == dt1, 'Extected the minimum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void minTest2() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;
        Assert.isTrue(VCC_DatetimeService.instance.min(dt2, dt1) == dt1, 'Extected the minimum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void minTest3() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;
        Assert.isTrue(VCC_DatetimeService.instance.min(dt4, dt3) == dt3, 'Extected the minimum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void minTest4() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;
        Assert.isTrue(VCC_DatetimeService.instance.min(dt3, dt4) == dt3, 'Extected the minimum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void maxTest() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;

        System.assert(VCC_DatetimeService.instance.max(dt1, dt2) == dt2, 'Extected the maximum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void FuncMaxTestNegative() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;

        System.assert(VCC_DatetimeService.instance.max(dt1, null) == dt1, 'Extected the maximum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void maxTest2() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;

        System.assert(VCC_DatetimeService.instance.max(dt2, dt1) == dt2, 'Extected the maximum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void maxTest3() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;

        System.assert(VCC_DatetimeService.instance.max(dt4, dt3) == dt3, 'Extected the maximum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void maxTest4() {
        Test.startTest();
        Datetime dt1 = Datetime.newInstance(2022, 1, 22);
        Datetime dt2 = Datetime.newInstance(2022, 2, 22);
        Datetime dt3 = Datetime.newInstance(1980, 12, 22);
        Datetime dt4 = null;

        System.assert(VCC_DatetimeService.instance.max(dt3, dt4) == dt3, 'Extected the maximum of the two datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void FuncParseTestSerializedDatetimeDayPositive() {
        Test.startTest();

        Datetime parsedDoubleQuotes, parsedNoDoubleQuotes;
        initSerializedDateTime(parsedDoubleQuotes, parsedNoDoubleQuotes);

        Assert.isTrue(parsedDoubleQuotes.day() == 1 && parsedNoDoubleQuotes.day() == 1, 'Expected correct value.');

        Test.stopTest();
    }
    @IsTest
    static void FuncParseTestSerializedDatetimeMonthPositive() {
        Test.startTest();

        Datetime parsedDoubleQuotes, parsedNoDoubleQuotes;
        initSerializedDateTime(parsedDoubleQuotes, parsedNoDoubleQuotes);

        Assert.isTrue(parsedDoubleQuotes.month() == 11 && parsedNoDoubleQuotes.month() == 11, 'Expected correct value.');

        Test.stopTest();
    }
    @IsTest
    static void FuncParseTestSerializedDatetimeYearPositive() {
        Test.startTest();

        Datetime parsedDoubleQuotes, parsedNoDoubleQuotes;
        initSerializedDateTime(parsedDoubleQuotes, parsedNoDoubleQuotes);

        Assert.isTrue(parsedDoubleQuotes.year() == 2022 && parsedNoDoubleQuotes.year() == 2022, 'Expected correct value.');

        Test.stopTest();
    }
    @IsTest
    static void FuncParseTestSerializedDatetimeHourPositive() {
        Test.startTest();

        Datetime parsedDoubleQuotes, parsedNoDoubleQuotes;
        initSerializedDateTime(parsedDoubleQuotes, parsedNoDoubleQuotes);

        Assert.isTrue(parsedDoubleQuotes.hour() == 2 && parsedNoDoubleQuotes.hour() == 2, 'Expected correct value.');

        Test.stopTest();
    }
    @IsTest
    static void FuncParseTestSerializedDatetimeMinutePositive() {
        Test.startTest();

        Datetime parsedDoubleQuotes, parsedNoDoubleQuotes;
        initSerializedDateTime(parsedDoubleQuotes, parsedNoDoubleQuotes);

        Assert.isTrue(parsedDoubleQuotes.minute() == 30 && parsedNoDoubleQuotes.minute() == 30, 'Expected correct value.');

        Test.stopTest();
    }
    @IsTest
    static void FuncParseTestSerializedDatetimeSecondPositive() {
        Test.startTest();

        Datetime parsedDoubleQuotes, parsedNoDoubleQuotes;
        initSerializedDateTime(parsedDoubleQuotes, parsedNoDoubleQuotes);

        Assert.isTrue(parsedDoubleQuotes.second() == 53 && parsedNoDoubleQuotes.second() == 53, 'Expected correct value.');

        Test.stopTest();
    }

    @IsTest
    static void UnitParseTestYyyyMmDdDayPositive() {
        Test.startTest();
        Datetime startDt, parsedDt;
        initYyyyMmDd(startDt, parsedDt);
        Assert.isTrue(parsedDt.day() == 1, 'Expected day as 1');
        Test.stopTest();
    }
    @IsTest
    static void UnitParseTestYyyyMmDdMonthPositive() {
        Test.startTest();
        Datetime startDt, parsedDt;
        initYyyyMmDd(startDt, parsedDt);
        Assert.isTrue(parsedDt.month() == 5, 'Expected day as 5');
        Test.stopTest();
    }
    @IsTest
    static void UnitParseTestYyyyMmDdYearPositive() {
        Test.startTest();
        Datetime startDt, parsedDt;
        initYyyyMmDd(startDt, parsedDt);
        Assert.isTrue(parsedDt.year() == 1999, 'Expected day as 1999');
        Test.stopTest();
    }
    @IsTest
    static void UnitParseTestYyyyMmDdDatePositive() {
        Test.startTest();
        Datetime startDt, parsedDt;
        initYyyyMmDd(startDt, parsedDt);
        Assert.isTrue(startDt == parsedDt, 'Expected equivalent datetimes.');
        Test.stopTest();
    }

    @IsTest
    static void UnitParseTestNegative() {
        Test.startTest();
        Assert.isTrue(VCC_DatetimeService.instance.parse('arg0') == null, 'Expected null.');
        Test.stopTest();
    }
}
