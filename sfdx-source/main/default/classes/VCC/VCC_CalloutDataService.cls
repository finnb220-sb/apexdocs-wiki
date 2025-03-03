public with sharing class VCC_CalloutDataService {
    public static VCC_CalloutDataService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_CalloutDataService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_CalloutDataService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub calloutDataServiceStub = new VCC_Stub(VCC_CalloutDataService.class);
        VCC_CalloutDataService.privateInstance = (VCC_CalloutDataService) calloutDataServiceStub.instance;
        return calloutDataServiceStub;
    }

    public VCC_Callout_Data__c insertNewCalloutData(VCC_HttpIntercept_Observer.HttpData httpData) {
        return this.insertNewCalloutData(httpData, new VCC_CalloutDataDomain());
    }

    public VCC_Callout_Data__c insertNewCalloutData(VCC_HttpIntercept_Observer.HttpData httpData, VCC_CalloutDataDomain calloutDataDomain) {
        VCC_Callout_Data__c calloutData = calloutDataDomain.convertHttpDataToCalloutData(httpData);

        fflib_ISObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(new List<Schema.SObjectType>{ VCC_Callout_Data__c.SObjectType });
        uow.registerNew(calloutData);
        uow.commitWork();

        return calloutData;
    }
}
