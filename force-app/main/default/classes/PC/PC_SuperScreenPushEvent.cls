/**
 * @description Class used by PC_ChatStreamController to track new/changed data from Agent Work and User Service Presence records from their respective record-triggered flows (Trigger_Pushtopic_from_AgentWork & PC_Set_Presence_Channel)
 *              The AW Push Event created from the flow input is used to invoke the PC Super Screen Push Topic in order to refresh the Availability Matrix table on the FLP Homepage
 * @author      Booz Allen Hamilton
 * @see         PC_ChatStreamController
 */
public inherited sharing class PC_SuperScreenPushEvent {
    private AgentWork agentWork;
    private PC_Case__c pcCase;
    private UserServicePresence userServicePresence;

    /**
     * @description AW Push Event to refresh PC Super Screen (Availability Matrix)
     */
    public PC_AWPushEvent__c pushEvent {
        public get {
            return this.pushEvent = this.pushEvent ?? new PC_AWPushEvent__c();
        }
        private set;
    }

    /**
     * @description Specialty for the event
     */
    public String specialty {
        public get {
            return this.userServicePresence?.PC_Specialty__c ?? this.pcCase?.Specialty__c;
        }
        private set;
    }

    /**
     * @description constructor for Agent Work record-triggered flows that want to invoke the PC Super Screen Push Topic
     * @param agentWork
     * @param pcCase
     * @param pushEvent
     */
    public PC_SuperScreenPushEvent(AgentWork agentWork, PC_Case__c pcCase, PC_AWPushEvent__c pushEvent) {
        this.agentWork = agentWork;
        this.pcCase = pcCase;
        this.pushEvent = pushEvent;
        this.pushEvent.OwnerId = agentWork?.UserId;
    }

    /**
     * @description constructor for User Service Presence record-triggered flows that want to invoke the PC Super Screen Push Topic
     * @param userServicePresence
     * @param pushEvent
     */
    public PC_SuperScreenPushEvent(UserServicePresence userServicePresence, PC_AWPushEvent__c pushEvent) {
        this.userServicePresence = userServicePresence;
        this.pushEvent = pushEvent;
        this.pushEvent.OwnerId = userServicePresence?.UserId;
    }

    /**
     * @description resets all fields on the push event to default values
     */
    public void resetPushEventFields() {
        this.pushEvent.CaseClosedJSON__c = '';
        this.pushEvent.CaseClosedByName__c = '';
        this.pushEvent.CaseClosedStatus__c = '';
        this.pushEvent.NewCaseOwner__c = '';
        this.pushEvent.NewOwnerTitle__c = '';
        this.pushEvent.NewOwnerCity__c = '';
        this.pushEvent.NewOwnerState__c = '';
        this.pushEvent.NewOwnerEmail__c = '';
        this.pushEvent.NewOwnerMediumPhotoUrl__c = '';
        this.pushEvent.NewOwnerDepartment__c = '';
        this.pushEvent.SkillName__c = '';
        this.pushEvent.HasPresence__c = false;
        this.pushEvent.ConsultantsOnline__c = 0;
        this.pushEvent.MinCapacity__c = 0.0;
        this.pushEvent.PatientSpecificDisabled__c = false;
        this.pushEvent.GeneralDisabled__c = false;
    }

    /**
     * @description sets New Owner fields on push event when an Agent Work record is Canceled and/or PrC Case is Closed
     * @param pcCaseOwner
     */
    public void setNewOwnerFields(User pcCaseOwner) {
        if (pcCaseOwner == null || this.agentWork?.Status != 'Canceled' || this.pcCase?.Closed__c) {
            return;
        }

        this.pushEvent.NewCaseOwner__c = pcCaseOwner?.Name;
        this.pushEvent.NewOwnerTitle__c = pcCaseOwner?.Title;
        this.pushEvent.NewOwnerCity__c = pcCaseOwner?.City;
        this.pushEvent.NewOwnerState__c = pcCaseOwner?.State;
        this.pushEvent.NewOwnerEmail__c = pcCaseOwner?.Email;
        this.pushEvent.NewOwnerMediumPhotoUrl__c = pcCaseOwner?.MediumPhotoUrl;
        this.pushEvent.NewOwnerDepartment__c = pcCaseOwner?.Department;
    }

    /**
     * @description sets Case Closed fields on push event when a PrC Case is Closed or Cancelled
     * @param pcCaseLastModifiedUser
     */
    public void setCaseClosedFields(User pcCaseLastModifiedUser) {
        if (pcCaseLastModifiedUser == null || !(this.pcCase?.Closed__c || this.pcCase?.Status__c == 'Cancelled')) {
            return;
        }

        this.pushEvent.CaseClosedByName__c = pcCaseLastModifiedUser?.Name ?? '';
        this.pushEvent.CaseClosedStatus__c = pcCase?.Status__c;
        this.pushEvent.CaseClosedJSON__c = JSON.serialize(new Map<String, String>{ pcCase?.Id => pcCase?.Name });
    }

    /**
     * @description sets Specialty Availability fields on push event so Specialty table on the Availability Matrix (PC SuperScreen) can the provided skill's row info is updated for conditional displays
     * @param skillStatus
     */
    public void setSpecialtyAvailabilityFields(PC_ProviderConnectController.SkillStatus skillStatus) {
        if (skillStatus == null || !this.specialty.equalsIgnoreCase(skillStatus?.skillName)) {
            return;
        }

        this.pushEvent.SkillName__c = skillStatus.skillName;
        this.pushEvent.HasPresence__c = skillStatus.hasPresence;
        this.pushEvent.ConsultantsOnline__c = skillStatus.consultantsOnline;
        this.pushEvent.MinCapacity__c = skillStatus.minCapacity;
        this.pushEvent.PatientSpecificDisabled__c = skillStatus.patientSpecificDisabled;
        this.pushEvent.GeneralDisabled__c = skillStatus.generalDisabled;
    }
}
