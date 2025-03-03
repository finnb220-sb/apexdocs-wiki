public with sharing class VCC_LongService {
    public static VCC_LongService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_LongService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_LongService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub longServiceStub = new VCC_Stub(VCC_LongService.class);
        VCC_LongService.privateInstance = (VCC_LongService) longServiceStub.instance;
        return longServiceStub;
    }

    public Long max(Long x, Long y) {
        if (x == null) {
            return y;
        }
        if (y == null) {
            return x;
        }
        if (x > y) {
            return x;
        }
        return y;
    }

    public Long min(Long x, Long y) {
        if (x == null) {
            return y;
        }
        if (y == null) {
            return x;
        }
        if (x < y) {
            return x;
        }
        return y;
    }

    public Long valueOf(String stringToLong) {
        if (String.isBlank(stringToLong)) {
            return null;
        }
        try {
            return Long.valueOf(stringToLong);
        } catch (TypeException e) {
            return null;
        }
    }

    public Integer intValue(Long l) {
        return l.intValue();
    }

    public String format(Long l) {
        return l.format();
    }
}
