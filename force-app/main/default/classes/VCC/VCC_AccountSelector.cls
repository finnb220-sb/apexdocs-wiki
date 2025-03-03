public with sharing virtual class VCC_AccountSelector extends fflib_SObjectSelector {
    private List<Schema.SObjectField> sObjectFields = new List<Schema.SObjectField>{
        Account.Id,
        Account.FirstName,
        Account.LastName,
        Account.MiddleName,
        Account.Name,
        Account.OwnerId,
        Account.PersonContactId,
        Account.VCC_MVI_External_Id__pc
    };

    public Schema.SObjectType getSObjectType() {
        return Account.SObjectType;
    }

    public List<Schema.SObjectField> getSObjectFieldList() {
        return this.sObjectFields;
    }

    public void addSObjectFields(List<Schema.SObjectField> sObjectFields) {
        if (sObjectFields != null && !sObjectFields.isEmpty()) {
            for (Schema.SObjectField field : sObjectFields) {
                if (!this.sObjectFields.contains(field)) {
                    this.sObjectFields.add(field);
                }
            }
        }
    }

    public List<Account> selectById(Set<Id> ids) {
        return (List<Account>) selectSObjectsById(ids);
    }

    public List<Account> selectByTaxId(String taxId) {
        if (taxId?.length() > 0) {
            String query = 'Find :taxId IN ALL FIELDS returning account(HealthCloudGA__TaxId__c, middleName, firstName, lastName, PersonBirthdate)';
            List<List<SObject>> searchResults = Search.query(query);
            return (List<Account>) searchResults[0];
        }
        return new List<Account>();
    }

    public List<Account> selectAccountsBySearchQuery(VCC_QueryParams queryParams) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition(queryParams.toQueryString());
        return (List<Account>) Database.query(query.toSOQL());
    }

    public List<Account> selectByICN(Set<String> icns) {
        fflib_QueryFactory query = newQueryFactory();
        query.setCondition('VCC_MVI_External_Id__pc IN :icns');
        return (List<Account>) Database.query(query.toSOQL());
    }
}
