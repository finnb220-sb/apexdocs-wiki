/**
 * @description  Controller class for the VCC_DeceasedPatient LWC. This controller is used to return deceased patient information to the LWC.
 * @author 10/15/2024 - By Jakob Orkin and Ian McNicoll
 * @see VCC_DeceasedPatientControllerTest.cls & VCR_AccountRepo.cls
 */
public with sharing class VCC_DeceasedPatientController {
    /**
     * @description retrieve deceased info for a patient
     * @param accountId The deceased patient's account Id, which is passed to the Account Selector
     * @return DeceasedInfo class
     */
    @AuraEnabled
    public static DeceasedInfo getDeceasedInfo(Id accountId) {
        List<Account> accts = new VCR_AccountRepo().fetchDeceasedPersonAccounts(new Set<String>{ accountId });
        return accts.isEmpty() ? new DeceasedInfo(null) : new DeceasedInfo(accts[0]);
    }

    /**
     * @description class for deceased info
     */
    public class DeceasedInfo {
        /**
         * @description the name of the patient
         */
        @AuraEnabled
        public String patientName { get; set; }

        /**
         * @description Date patient was deceased
         */
        @AuraEnabled
        public Date deceasedDate { get; set; }

        /**
         * @description returns a concatonated string of the patients birth and deceased dates formatted as  'MM/dd/yyyy'
         * example: '10/10/2000 - 11/11/2011'
         */
        @AuraEnabled
        public String birthWithDeceasedDateFormatted {
            get {
                return (this.deceasedDate != null)
                    ? String.format(
                          '{0} - {1}',
                          new List<String>{ this.birthDate, ((Datetime) this.deceasedDate).formatGmt('MM/dd/yyyy') }
                      )
                    : null;
            }
        }

        /**
         * @description the persons date of birth
         */
        @AuraEnabled
        public String birthDate { get; set; }

        /**
         * @description method for deceased info constructor
         * @param patientAccount represents the Account record of the deceased patient
         */
        public DeceasedInfo(Account patientAccount) {
            if (patientAccount == null) {
                return;
            }
            this.patientName = patientAccount.Name;
            this.deceasedDate = patientAccount.HealthCloudGA__DeceasedDate__pc;
            this.birthDate = patientAccount.Date_of_Birth__pc;
        }
    }
}
