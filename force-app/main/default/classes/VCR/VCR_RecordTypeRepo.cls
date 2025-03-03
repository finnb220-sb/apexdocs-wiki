/**
 * @description This repository is for record types
 * @author Booz Allen
 * @since 05/2024
 */
public virtual inherited sharing class VCR_RecordTypeRepo extends VTC_BaseRepo {
    /**
     * @description Constructor function for VCR_RecordTypeRepo. Calls super constructor which sets this.sObjectType to
     * RecordType
     */
    public VCR_RecordTypeRepo() {
        super(RecordType.getSObjectType());
    }

    /**
     * @description retrieves the record type that matches the developer name
     * @param developerName - api name of the record type
     * @return List<RecordType> - record type that matches criteria in list
     */
    public List<RecordType> getRecordTypesByName(String developerName) {
        String selectClause = 'SELECT DeveloperName ';
        String fromClause = 'FROM RecordType ';
        String whereClause = 'WHERE DeveloperName = \'' + developerName + '\'';
        String query = selectClause + fromClause + whereClause;

        return this.fetch(query);
    }
}
