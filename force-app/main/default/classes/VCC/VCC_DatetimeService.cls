public with sharing class VCC_DatetimeService {
    public static VCC_DatetimeService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_DatetimeService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_DatetimeService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub datetimeServiceStub = new VCC_Stub(VCC_DatetimeService.class);
        VCC_DatetimeService.privateInstance = (VCC_DatetimeService) datetimeServiceStub.instance;
        return datetimeServiceStub;
    }

    // matches 2 digit 01 to 12
    public final String MONTH = '((?:1)(?:[0-2])|(?:0)(?:[1-9]))';

    // matches 2 digits 01 to 31
    public final String DAY = '((?:0)[1-9]|(?:1|2)[0-9]|(?:3)(?:0|1))';

    // matches 4 digits 1000 to 2999
    public final String YEAR = '((?:1)[0-9]{3}|(?:2)[0-9]{3})';

    //matches 2 digits 00 to 23
    public final String HOUR_24 = '((?:0)[0-9]|(?:1)[0-9]|(?:2)[0-3])';

    //matches 2 digits 00 to 59
    public final String MINUTES = '([0-5][0-9])';

    //matches 2 digits 00 to 59
    public final String SECONDS = '([0-5][0-9])';

    //matches 3 digits 000 to 999
    public final String MILISECONDS = '([0-9]{3})';

    //matches: "2000-12-01T05:00:00.000Z" or 2000-12-01T05:00:00.000Z (with or without double quotes)
    public final String SERIALIZED_DATETIME =
        '(?:"?)' +
        YEAR +
        '(?:-)' +
        MONTH +
        '(?:-)' +
        DAY +
        '(?:T)' +
        HOUR_24 +
        '(?:\\:)' +
        MINUTES +
        '(?:\\:)' +
        SECONDS +
        '(?:\\.)' +
        MILISECONDS +
        '(?:Z)(?:"?)';

    public final String YEAR_MONTH_DAY_HOUR_MINUTE_SECOND = YEAR + MONTH + DAY + HOUR_24 + '?' + MINUTES + '?' + SECONDS + '?';

    public Datetime min(Datetime dtx, Datetime dty) {
        if (dtx == null) {
            return dty;
        }
        if (dty == null) {
            return dtx;
        }
        if (dtx < dty) {
            return dtx;
        }
        return dty;
    }

    public Datetime max(Datetime dtx, Datetime dty) {
        if (dtx == null) {
            return dty;
        }
        if (dty == null) {
            return dtx;
        }
        if (dtx > dty) {
            return dtx;
        }
        return dty;
    }

    /**
     * Use this to parse datetimes that Datetime.parse does not like
     */
    public Datetime parse(String datetimeStr) {
        if (datetimeStr == null) {
            return null;
        }
        try {
            if (Pattern.matches(SERIALIZED_DATETIME, datetimeStr)) {
                return this.parseSerializedDatetime(datetimeStr);
            }

            if (Pattern.matches(YEAR_MONTH_DAY_HOUR_MINUTE_SECOND, datetimeStr)) {
                return this.parse_yyyyMMddhhmmss(datetimeStr);
            }

            // add more patterns as needed, be sure to check they dont collide

            return Datetime.parse(datetimeStr);
        } catch (Exception e) {
            return null;
        }
    }

    /**
     *                          ***WARNING***
     * IF YOU JSON.SERIALIZE A DATETIME IT IS AUTOMATICALLY CONVERTED TO GMT
     * AND PARSING IT WILL GET YOU A GMT DATETIME
     */
    public Datetime parseSerializedDatetime(String datetimeStr) {
        Pattern ptrn = Pattern.compile(SERIALIZED_DATETIME);
        Matcher mchr = ptrn.matcher(datetimeStr);
        if (mchr.find() == false) {
            return null;
        }
        return Datetime.newInstance(
            Integer.valueOf(mchr.group(1)),
            Integer.valueOf(mchr.group(2)),
            Integer.valueOf(mchr.group(3)),
            Integer.valueOf(mchr.group(4)),
            Integer.valueOf(mchr.group(5)),
            Integer.valueOf(mchr.group(6))
        );
    }

    public Datetime parse_yyyyMMddhhmmss(String datetimeStr) {
        Pattern ptrn = Pattern.compile(YEAR_MONTH_DAY_HOUR_MINUTE_SECOND);
        Matcher mchr = ptrn.matcher(datetimeStr);
        if (mchr.find() == false) {
            return null;
        }
        return Datetime.newInstance(
            (String.isBlank(mchr.group(1))) ? 0 : Integer.valueOf(mchr.group(1)),
            (String.isBlank(mchr.group(2))) ? 0 : Integer.valueOf(mchr.group(2)),
            (String.isBlank(mchr.group(3))) ? 0 : Integer.valueOf(mchr.group(3)),
            (String.isBlank(mchr.group(4))) ? 0 : Integer.valueOf(mchr.group(4)),
            (String.isBlank(mchr.group(5))) ? 0 : Integer.valueOf(mchr.group(5)),
            (String.isBlank(mchr.group(6))) ? 0 : Integer.valueOf(mchr.group(6))
        );
    }
}
