public with sharing class VCC_SignersService {
    public static VCC_SignersService instance {
        get {
            if (privateInstance != null) {
                return privateInstance;
            }
            privateInstance = new VCC_SignersService();
            return privateInstance;
        }
    }

    @TestVisible
    private static VCC_SignersService privateInstance;

    @TestVisible
    private static VCC_Stub stub() {
        VCC_Stub signersServiceStub = new VCC_Stub(VCC_SignersService.class);
        VCC_SignersService.privateInstance = (VCC_SignersService) signersServiceStub.instance;
        return signersServiceStub;
    }

    public List<VCC_Signers__c> getSignersForRecord(Id recordId) {
        if (String.isBlank((String) recordId)) {
            return new List<VCC_Signers__c>();
        }
        return getSignersForRecord(recordId, new VCC_SignersSelector());
    }

    @TestVisible
    private List<VCC_Signers__c> getSignersForRecord(Id recordId, VCC_SignersSelector signersSelector) {
        try {
            SObjectType sObjectType = recordId.getSobjectType();

            if (sObjectType === VCC_Progress_Note__c.SObjectType) {
                return signersSelector.selectSignersByProgressNoteId(recordId);
            } else if (sObjectType === VCC_Addendum__c.SObjectType) {
                return signersSelector.selectSignersByAddendumId(recordId);
            }
        } catch (Exception e) {
            Logger.error('VCC_SignersService.getSignersForRecord exception', e);
            Logger.saveLog();
        }

        return new List<VCC_Signers__c>();
    }

    public List<String> getSignerDuzListForCallout(Id recordId) {
        List<String> duzList = new List<String>();
        for (VCC_Signers__c signer : this.getSignersForRecord(recordId)) {
            duzList.add(signer.VCC_DUZ__c);
        }
        return duzList;
    }
}
