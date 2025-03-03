/**
 * @description Repo class holding SOQL and DML logic for the ServiceChannel object.
 * @author      Booz Allen
 * @since       2024
 */
public inherited sharing class VCR_ServiceChannelRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_ServiceChannelRepo. Calls super constructor which sets this.sObjectType to 'ServiceChannel'
     */
    public VCR_ServiceChannelRepo() {
        super(ServiceChannel.sObjectType);
    }

    /**
     * @description         fetches Service Channel(s) with the given developer name
     * @param developerName the DeveloperName of the Service Channel
     * @return              `List<ServiceChannel>` list of Service Channel(s) with the given developer name
     */
    public List<ServiceChannel> fetchByDeveloperName(String developerName) {
        return fetch(
            'SELECT Id, DeveloperName FROM ServiceChannel WHERE DeveloperName = :developerName',
            new Map<String, Object>{ 'developerName' => developerName }
        );
    }
}
