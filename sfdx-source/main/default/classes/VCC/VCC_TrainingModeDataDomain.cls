/**
 * VCC_TrainingModeDataDomain
 * @description VCC domain class for VCC_Training_Mode_Data__c.
 * @author Liberty
 * @date 12/9/2021
 */

public with sharing class VCC_TrainingModeDataDomain {
    public List<VCC_Training_Mode_Data__c> createMasterTrainingModeData(VCC_TrainingModeAccount trainingModeAccount) {
        List<VCC_Training_Mode_Data__c> trainingModeDataList = new List<VCC_Training_Mode_Data__c>();
        for (VCC_TrainingModeData relatedData : trainingModeAccount.relatedData) {
            VCC_Training_Mode_Data__c trainingModeData = new VCC_Training_Mode_Data__c();
            trainingModeData.Name = String.format('{0} {1} - Master - {2}', new List<String>{ trainingModeAccount.firstName, trainingModeAccount.lastName, relatedData.type });
            trainingModeData.Type__c = relatedData.type;
            trainingModeData.Data__c = relatedData.data;
            trainingModeDataList.add(trainingModeData);
        }
        return trainingModeDataList;
    }

    public List<VCC_Training_Mode_Data__c> createTrainingModeData(User user, VCC_TrainingModeAccount trainingModeAccount) {
        List<VCC_Training_Mode_Data__c> trainingModeDataList = new List<VCC_Training_Mode_Data__c>();
        for (VCC_TrainingModeData relatedData : trainingModeAccount.relatedData) {
            if (relatedData.type == 'Vet Info' || relatedData.type == 'Medications') {
                VCC_Training_Mode_Data__c trainingModeData = new VCC_Training_Mode_Data__c();
                trainingModeData.Name = String.format(
                    '{0} {1} - {2} - ({3} {4})',
                    new List<String>{ trainingModeAccount.firstName, trainingModeAccount.lastName, relatedData.type, user.FirstName, user.LastName }
                );
                trainingModeData.Type__c = relatedData.type;
                trainingModeData.Data__c = relatedData.data;
                trainingModeDataList.add(trainingModeData);
            }
        }
        return trainingModeDataList;
    }

    public void refillMedications(VCC_Training_Mode_Data__c existingData, List<String> prescriptionIds) {
        VCC_MedicationsData medicationsDataObj = (VCC_MedicationsData) JSON.deserialize(existingData.Data__c, VCC_MedicationsData.class);
        for (VCC_MedicationsData.VCC_Med medicationsData : medicationsDataObj.sites[0].results.meds.med) {
            if (prescriptionIds.contains(medicationsData.prescription.value)) {
                medicationsData.status.value = 'suspended';
                medicationsData.vaStatus.value = 'SUSPENDED';
            }
        }
        existingData.Data__c = JSON.serialize(medicationsDataObj);
    }

    public void updateVetInfo(Account account, VCC_Training_Mode_Data__c trainingModeData, VCC_TrainingModeService.WriteVetInfoRQ writeVetInfoRQ) {
        // Convert the training data into an object so we can work with it
        VCC_MPIParser trainingModeDataObj = (VCC_MPIParser) JSON.deserialize(trainingModeData.Data__c, VCC_MPIParser.class);

        for (VCC_MPIParser.EEAssociation associatedPerson : writeVetInfoRQ.eeAssociations) {
            updateVetInfoAccount(account, associatedPerson);

            if (associatedPerson.contactType == 'Emergency Contact') {
                updateVetInfoEmergencyContact(trainingModeDataObj, associatedPerson);
            }

            if (associatedPerson.contactType == 'NextOfKin') {
                updateVetInfoNextOfKin(trainingModeDataObj, associatedPerson);
            }
        }

        // Update the training data with the new vetInfo
        trainingModeData.Data__c = JSON.serialize(trainingModeDataObj);
    }

    @TestVisible
    private void updateVetInfoAccount(Account account, VCC_MPIParser.EEAssociation associatedPerson) {
    }

    @TestVisible
    private void updateVetInfoEmergencyContact(VCC_MPIParser trainingModeDataObj, VCC_MPIParser.EEAssociation associatedPerson) {
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].givenName = associatedPerson.givenName;
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.postalCode = associatedPerson.address.postalCode;
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.zipCode = associatedPerson.address.zipCode;
    }

    @TestVisible
    private void updateVetInfoNextOfKin(VCC_MPIParser trainingModeDataObj, VCC_MPIParser.EEAssociation associatedPerson) {
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].givenName = associatedPerson.givenName;
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.postalCode = associatedPerson.address.postalCode;
        trainingModeDataObj.vetsV3[0].ee.eeExtendedResponse.associations[0].address.zipCode = associatedPerson.address.zipCode;
    }
}
