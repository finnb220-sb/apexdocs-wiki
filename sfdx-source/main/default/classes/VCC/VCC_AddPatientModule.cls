/**
 * @author Patrick Skamarak
 * @description Stubbable module for 'add veteran' functionality with new MPI 3.0 package. Most of this is refactored out of VCC_PatientSearchController.
 */
public with sharing class VCC_AddPatientModule {
    public VCC_AccountSelector accountSelector {
        get {
            if (accountSelector == null) {
                accountSelector = new VCC_AccountSelector();
            }
            return accountSelector;
        }
        set;
    }

    public VCC_MpiPackageConnector mpiPackageConnector {
        get {
            if (mpiPackageConnector == null) {
                mpiPackageConnector = new VCC_MpiPackageConnector();
            }
            return mpiPackageConnector;
        }
        set;
    }

    public VCC_AddPatientModule() {
        return;
    }

    @SuppressWarnings('PMD.ExcessiveParameterList')
    public VCC_AddPatientModule(VCC_AccountSelector accountSelector, VCC_MpiPackageConnector mpiPackageConnector) {
        this.accountSelector = accountSelector;
        this.mpiPackageConnector = mpiPackageConnector;
    }

    /**
     * @description Service method.
     * @param mpiSearchResult the mpiSearchResult
     * @param resultTemplate the result template that handles the result
     */
    public AddVeteranResult addVeteran(Map<String, Object> mpiSearchResult, SavePoint savepoint) {
        try {
            //removing extraneous data - if you dont remove this, an exception will occur
            mpiSearchResult.remove('correlatedIds');
            mpiSearchResult.remove('relationships');

            //look for existing accounts with the provided ICN
            List<Account> accountList = this.accountSelector.selectByICN(new Set<String>{ (String) mpiSearchResult.get('icn') });

            //really, the number of accounts found should be 0, or 1 since the ICN field on account is unique
            if (accountList != null && accountList.size() >= 1) {
                return new AddVeteranResult(accountList[0], true);
            }

            //create person acct
            Account personAccount = new Account(
                RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId(),
                VCC_MVI_External_Id__pc = (String) mpiSearchResult.get('icn'),
                LastName = (String) mpiSearchResult.get('lastName'),
                FirstName = (String) mpiSearchResult.get('firstName')
            );
            Database.insert(personAccount, AccessLevel.SYSTEM_MODE); // intentional SYSTEM_MODE DML per Shirley

            //add contact id to map to VA_Identity__c record
            mpiSearchResult.put('personContactId', [SELECT PersonContactId FROM Account WHERE Id = :personAccount.Id WITH USER_MODE LIMIT 1].PersonContactId);

            String serializedInsertFieldMap = JSON.serialize(this.mpiPackageConnector.getIdentityFieldMapping().mpiSalesforceInsertFieldMap);
            String serializedMpiString = JSON.serialize(mpiSearchResult);

            VA_Identity__c vaId = (VA_Identity__c) this.mpiPackageConnector.saveForm(
                VA_Identity__c.class.getName(),
                serializedInsertFieldMap,
                serializedMpiString,
                UserInfo.getUserName()
            );

            this.mpiPackageConnector.setCorrelation(vaId, serializedInsertFieldMap, serializedMpiString, UserInfo.getUserId(), UserInfo.getUserName());

            return new AddVeteranResult(personAccount, false);
        } catch (Exception e) {
            Database.rollback(savepoint);
            if (e instanceof VCC_MpiPackageException) {
                throw e;
            }
            throw new ModuleException(e);
        }
    }

    public SearchCrmResult searchCrm(Map<String, Object> params) {
        try {
            this.accountSelector.addSObjectFields(
                new List<Schema.SObjectField>{ Account.HealthCloudGA__TaxId__c, Account.PersonBirthdate, Account.VCC_Birth_City__c, Account.VCC_Birth_State__c }
            );

            if (params.get('ssn') != null && String.isNotBlank((String) params.get('ssn'))) {
                List<Account> accountList = this.accountSelector.selectByTaxId((String) params.get('ssn'));
                if (accountList != null && accountList.size() >= 1) {
                    return new SearchCrmResult(this.accountSelector.selectByTaxId((String) params.get('ssn')));
                }
            }

            VCC_QueryParams searchParams = new VCC_QueryParams();
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.FirstName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('firstName'))
            );
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.MiddleName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('middleName'))
            );
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.LastName, VCC_QueryParam.QueryParamCondition.CONTAINS, VCC_QueryParam.QueryParamType.STRINGTYPE, (String) params.get('lastName'))
            );
            searchParams.queryParams.add(
                new VCC_QueryParam(Account.PersonBirthdate, VCC_QueryParam.QueryParamCondition.EQUALS, VCC_QueryParam.QueryParamType.DATETYPE, (String) params.get('dob'))
            );

            return new SearchCrmResult(this.accountSelector.selectAccountsBySearchQuery(searchParams));
        } catch (Exception e) {
            throw new ModuleException(e);
        }
    }

    public MPIDynamicPersonSearchController.ResponseWrap searchMpi(Map<String, Object> params) {
        try {
            params.put('userId', 'VAHC CRM');
            return this.mpiPackageConnector.mpiPatientSearch(JSON.serialize(params));
        } catch (VCC_MpiPackageException mpiPackageException) {
            throw mpiPackageException;
        } catch (Exception e) {
            throw new ModuleException(e);
        }
    }

    public class SearchCrmResult {
        public List<Account> accountList { get; set; }

        public SearchCrmResult(List<Account> accountList) {
            this.accountList = accountList;
        }

        @TestVisible
        private SearchCrmResult() {
            return;
        }
    }

    public class AddVeteranResult {
        public Boolean patientExists { get; set; }

        public Id accountId { get; set; }

        public AddVeteranResult(Account account, Boolean isExistingAccount) {
            this.patientExists = isExistingAccount;
            this.accountId = account.Id;
        }

        @TestVisible
        private AddVeteranResult() {
            return;
        }
    }

    public class ModuleException extends Exception {
        {
            // if the exception has a cause, display that - otherwise display the original message
            setMessage(
                String.format(
                    '({0}) {1}', // (transactionId) Exception message
                    new List<String>{ Logger.getTransactionId(), getCause() == null ? getMessage() : getCause().getMessage() }
                )
            );
        }
    }
}
