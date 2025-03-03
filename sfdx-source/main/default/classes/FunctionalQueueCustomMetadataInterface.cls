/**
 * @description       :
 * @author            : jonathon.schleicher@b3groupinc.com
 * @group             :
 * @last modified on  : 10-26-2021
 * @last modified by  : jonathon.schleicher@b3groupinc.com
 **/

public interface FunctionalQueueCustomMetadataInterface {
    List<FunctionalQueue_Supported_Objects_By_App__mdt> getAllFunctionalQueueSupportedObjectsForApp();
    FunctionalQueue_Supported_Objects_By_App__mdt getFunctionalQueueSupportedObjectsForAppByApplication(string associatedApplication);
    FunctionalQueue_Supported_Objects_By_App__mdt createFunctionalQueueSupportedObjects(FunctionalQueue_Supported_Objects_By_App__mdt functionalQueueSupportedObjectsByAppRecord);
}
