/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 10-26-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/

public without sharing class FunctionalQueueCustomMetadataService implements FunctionalQueueCustomMetadataInterface {
    public static List<FunctionalQueue_Supported_Objects_By_App__mdt> getAllFunctionalQueueSupportedObjectsForApp() {
        return new List<FunctionalQueue_Supported_Objects_By_App__mdt>();
    }

    public static FunctionalQueue_Supported_Objects_By_App__mdt getFunctionalQueueSupportedObjectsForAppByApplication(string associatedApplication) {
        return new FunctionalQueue_Supported_Objects_By_App__mdt();
    }

    public static FunctionalQueue_Supported_Objects_By_App__mdt createFunctionalQueueSupportedObjects(
        FunctionalQueue_Supported_Objects_By_App__mdt customMetadataFuncQSupportedObjectsByAppRecord
    ) {
        Metadata.DeployContainer customMetadatContainer = new Metadata.DeployContainer();

        string associatedApplication = '';
        string supportedObjects = '';
        string customFunqMetadataRecordName = '';
        String fullAPIName = 'FunctionalQueue_Supported_Objects_By_App__mdt';

        associatedApplication = customMetadataFuncQSupportedObjectsByAppRecord.Application_Name__c;
        supportedObjects = customMetadataFuncQSupportedObjectsByAppRecord.Supported_Objects__c;
        customFunqMetadataRecordName = customMetadataFuncQSupportedObjectsByAppRecord.DeveloperName;

        Metadata.CustomMetadata funqSupportedObjectsByAppRecordMetadata = new Metadata.CustomMetadata();

        funqSupportedObjectsByAppRecordMetadata.fullName = customFunqMetadataRecordName;

        Metadata.CustomMetadataValue associatedApplicationValue = new Metadata.CustomMetadataValue();
        associatedApplicationValue.field = 'Application_Name__c';
        associatedApplicationValue.value = associatedApplication;
        funqSupportedObjectsByAppRecordMetadata.values.add(associatedApplicationValue);

        Metadata.CustomMetadataValue supportedObjectsValue = new Metadata.CustomMetadataValue();
        supportedObjectsValue.field = 'Supported_Objects__c';
        supportedObjectsValue.value = supportedObjects;
        funqSupportedObjectsByAppRecordMetadata.values.add(supportedObjectsValue);

        customMetadatContainer.addMetadata(funqSupportedObjectsByAppRecordMetadata);

        try {
            system.debug('mdContainer**' + customMetadatContainer);
            // Enqueue custom metadata deployment
            // jobId is the deployment ID
            Id jobId = Metadata.Operations.enqueueDeployment(customMetadatContainer, null);
            system.debug('jobId***' + jobId);
        } catch (Exception ex) {
            System.debug('here is the error: ' + ex.getMessage());
        }

        return new FunctionalQueue_Supported_Objects_By_App__mdt();
    }
}
