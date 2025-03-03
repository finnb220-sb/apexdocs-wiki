/**
 * @description test class for PC_SuperScreenPushEvent
 * @author      Booz Allen Hamilton
 * @see         PC_SuperScreenPushEvent
 */
@IsTest
private class PC_SuperScreenPushEventTest {
    private final static User SPECIALIST_USER;
    static {
        //mixed DML error workaround
        System.runAs([SELECT Id FROM User WHERE Id = :UserInfo.getUserId()][0]) {
            SPECIALIST_USER = new VATEST_UserBuilder()
                .withUserProfile('VAVET Base Profile')
                .withStandardData()
                .withPermissionSet('PrC_Specialist_Users')
                .build(true);
        }
    }

    /**
     * @description positive test of the PC_SuperScreenPushEvent constructor that utilizes AgentWork and PrC Case parameters
     */
    @IsTest
    static void unitConstructorAgentWorkPositive() {
        PC_Case__c pcCase = new PC_Case__c(Id = VATEST_IdFactory.get('PC_Case__c'), Specialty__c = 'Cardiology');
        AgentWork agentWork = new AgentWork(
            Id = VATEST_IdFactory.get('AgentWork'),
            UserId = VATEST_IdFactory.get('User'),
            WorkItemId = VATEST_IdFactory.get('PC_Case__c')
        );

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(agentWork, pcCase, null);
            Test.stopTest();
        }

        Assert.areEqual(
            agentWork.UserId,
            pcSuperScreenPushEvent.pushEvent.OwnerId,
            'Expected the Super Screen Push Event OwnerId to be the same as the AgentWork UserId, but the OwnerId was different'
        );
    }

    /**
     * @description positive test of the PC_SuperScreenPushEvent constructor that utilizes UserServicePresence parameter
     */
    @IsTest
    static void unitConstructorUserServicePresencePositive() {
        UserServicePresence userServicePresence = new UserServicePresence(
            Id = VATEST_IdFactory.get('UserServicePresence'),
            UserId = VATEST_IdFactory.get('User'),
            PC_Specialty__c = 'Cardiology'
        );

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(userServicePresence, null);
            Test.stopTest();
        }

        Assert.areEqual(
            userServicePresence.UserId,
            pcSuperScreenPushEvent.pushEvent.OwnerId,
            'Expected the Super Screen Push Event OwnerId to be the same as the UserServicePresence UserId, but the OwnerId was different'
        );
    }

    /**
     * @description positive test of resetPushEventFields method that resets the SkillName__c field of the pushEvent record
     */
    @IsTest
    static void unitResetPushEventFieldsPositive() {
        UserServicePresence userServicePresence = new UserServicePresence(
            Id = VATEST_IdFactory.get('UserServicePresence'),
            UserId = VATEST_IdFactory.get('User'),
            PC_Specialty__c = 'Cardiology'
        );

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(userServicePresence, null);
            pcSuperScreenPushEvent.pushEvent.SkillName__c = 'SKILL TO BLANK';
            pcSuperScreenPushEvent.resetPushEventFields();
            Test.stopTest();
        }

        Assert.isTrue(
            String.isBlank(pcSuperScreenPushEvent.pushEvent.SkillName__c),
            'Expected the Push Event SkillName__c field to be reset to an empty string, but the SkillName__c field was still populated.'
        );
    }

    /**
     * @description positive test of setNewOwnerFields by checking that the pcCaseOwner User's Email propogates into the NewCaseOwnerEmail__c field on the push event
     */
    @IsTest
    static void unitSetNewOwnerFieldsPositive() {
        Map<String, Object> toForceCastToUser = new Map<String, Object>();
        toForceCastToUser.put('Id', SPECIALIST_USER.Id);
        toForceCastToUser.put('Name', 'Bruce Wayne');
        toForceCastToUser.put('MediumPhotoUrl', 'https://example.com/medium/imageUrl.jpg');
        toForceCastToUser.put('Email', 'bruce@wayneenterprises.com');
        toForceCastToUser.put('Street', '123 Sesame St');
        toForceCastToUser.put('City', 'Gotham');
        toForceCastToUser.put('State', 'New York');
        toForceCastToUser.put('PostalCode', '98601');
        toForceCastToUser.put('Title', 'Batman');
        toForceCastToUser.put('Department', 'Gotham City Poilice');
        toForceCastToUser.put('Division', 'VISN 1');
        String intermediateUserString = JSON.serialize(toForceCastToUser);
        User pcCaseOwner = (User) JSON.deserialize(intermediateUserString, User.class);

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Id', VATEST_IdFactory.get('PC_Case__c'));
        toForceCastToPcCase.put('OwnerId', pcCaseOwner.Id);
        toForceCastToPcCase.put('Specialty__c', 'Cardiology');
        toForceCastToPcCase.put('Closed', false);
        String intermediatePcCaseString = JSON.serialize(toForceCastToPcCase);
        PC_Case__c pcCase = (PC_Case__c) JSON.deserialize(intermediatePcCaseString, PC_Case__c.class);

        Map<String, Object> toForceCastToAgentWork = new Map<String, Object>();
        toForceCastToAgentWork.put('Id', VATEST_IdFactory.get('AgentWork'));
        toForceCastToAgentWork.put('UserId', pcCaseOwner.Id);
        toForceCastToAgentWork.put('WorkItemId', pcCase.Id);
        toForceCastToAgentWork.put('Status', 'Canceled');
        String intermediateAgentWorkString = JSON.serialize(toForceCastToAgentWork);
        AgentWork agentWork = (AgentWork) JSON.deserialize(intermediateAgentWorkString, AgentWork.class);

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(agentWork, pcCase, null);
            pcSuperScreenPushEvent.setNewOwnerFields(pcCaseOwner);
            Test.stopTest();
        }

        Assert.areEqual(
            pcCaseOwner.Email,
            pcSuperScreenPushEvent.pushEvent.NewOwnerEmail__c,
            'Expected the Super Screen Push Event NewOwnerEmail__c field to be the same as the pcCaseOwner record Email field, but the email values were different'
        );
    }

    /**
     * @description negative test of setNewOwnerFields to ensure that the NewCaseOwner fields are gracefully not set if the input parameters do not meet the criteria
     */
    @IsTest
    private static void unitSetNewOwnerFieldsNegative() {
        Id caseOwnerId = VATEST_IdFactory.get('User');

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Id', VATEST_IdFactory.get('PC_Case__c'));
        toForceCastToPcCase.put('OwnerId', caseOwnerId);
        toForceCastToPcCase.put('Specialty__c', 'Cardiology');
        toForceCastToPcCase.put('Closed', false);
        String intermediatePcCaseString = JSON.serialize(toForceCastToPcCase);
        PC_Case__c pcCase = (PC_Case__c) JSON.deserialize(intermediatePcCaseString, PC_Case__c.class);

        Map<String, Object> toForceCastToAgentWork = new Map<String, Object>();
        toForceCastToAgentWork.put('Id', VATEST_IdFactory.get('AgentWork'));
        toForceCastToAgentWork.put('UserId', caseOwnerId);
        toForceCastToAgentWork.put('WorkItemId', pcCase.Id);
        toForceCastToAgentWork.put('Status', 'Canceled');
        String intermediateAgentWorkString = JSON.serialize(toForceCastToAgentWork);
        AgentWork agentWork = (AgentWork) JSON.deserialize(intermediateAgentWorkString, AgentWork.class);

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(agentWork, pcCase, null);
            pcSuperScreenPushEvent.setNewOwnerFields(null);
            Test.stopTest();
        }

        // Asserts
        Assert.isNull(
            pcSuperScreenPushEvent.pushEvent.NewOwnerEmail__c,
            'Expected the Super Screen Push Event NewOwnerEmail__c field to be blank, but the field was populated'
        );
    }

    /**
     * @description positive test of setCaseClosedFields by checking that the PrC Case's Status propogates into the CaseClosedStatus__c field on the push event
     */
    @IsTest
    static void unitSetCaseClosedFieldsPositive() {
        Id caseOwnerId = VATEST_IdFactory.get('User');

        Map<String, Object> toForceCastToUser = new Map<String, Object>();
        toForceCastToUser.put('Id', SPECIALIST_USER.Id);
        toForceCastToUser.put('Name', 'Bruce Wayne');
        toForceCastToUser.put('MediumPhotoUrl', 'https://example.com/medium/imageUrl.jpg');
        toForceCastToUser.put('Email', 'bruce@wayneenterprises.com');
        toForceCastToUser.put('Street', '123 Sesame St');
        toForceCastToUser.put('City', 'Gotham');
        toForceCastToUser.put('State', 'New York');
        toForceCastToUser.put('PostalCode', '98601');
        toForceCastToUser.put('Title', 'Batman');
        toForceCastToUser.put('Department', 'Gotham City Poilice');
        toForceCastToUser.put('Division', 'VISN 1');
        String intermediateUserString = JSON.serialize(toForceCastToUser);
        User pcCaseLastModifiedUser = (User) JSON.deserialize(intermediateUserString, User.class);

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Id', VATEST_IdFactory.get('PC_Case__c'));
        toForceCastToPcCase.put('OwnerId', caseOwnerId);
        toForceCastToPcCase.put('Specialty__c', 'Cardiology');
        toForceCastToPcCase.put('Closed', false);
        toForceCastToPcCase.put('Status__c', 'Cancelled');
        String intermediatePcCaseString = JSON.serialize(toForceCastToPcCase);
        PC_Case__c pcCase = (PC_Case__c) JSON.deserialize(intermediatePcCaseString, PC_Case__c.class);

        Map<String, Object> toForceCastToAgentWork = new Map<String, Object>();
        toForceCastToAgentWork.put('Id', VATEST_IdFactory.get('AgentWork'));
        toForceCastToAgentWork.put('UserId', caseOwnerId);
        toForceCastToAgentWork.put('WorkItemId', pcCase.Id);

        String intermediateAgentWorkString = JSON.serialize(toForceCastToAgentWork);
        AgentWork agentWork = (AgentWork) JSON.deserialize(intermediateAgentWorkString, AgentWork.class);

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(agentWork, pcCase, null);
            pcSuperScreenPushEvent.setCaseClosedFields(pcCaseLastModifiedUser);
            Test.stopTest();
        }

        Assert.areEqual(
            pcCaseLastModifiedUser.Name,
            pcSuperScreenPushEvent.pushEvent.CaseClosedByName__c,
            'Expected the Super Screen Push Event CaseClosedByName__c field to be the same as the pcCaseLastModifiedUser record Name field, but the Name values were different'
        );

        Assert.areEqual(
            pcCase.Status__c,
            pcSuperScreenPushEvent.pushEvent.CaseClosedStatus__c,
            'Expected the Super Screen Push Event CaseClosedStatus__c field to be the same as the pcCase record Status__c field, but the status values were different'
        );
    }

    /**
     * @description negative test of setCaseClosedFields to ensure that the CaseClosed fields are gracefully not set if the input parameters do not meet the criteria
     */
    @IsTest
    static void unitSetCaseClosedFieldsNegative() {
        Id caseOwnerId = VATEST_IdFactory.get('User');

        Map<String, Object> toForceCastToPcCase = new Map<String, Object>();
        toForceCastToPcCase.put('Id', VATEST_IdFactory.get('PC_Case__c'));
        toForceCastToPcCase.put('OwnerId', caseOwnerId);
        toForceCastToPcCase.put('Specialty__c', 'Cardiology');
        toForceCastToPcCase.put('Closed', false);
        toForceCastToPcCase.put('Status__c', 'Open');
        String intermediatePcCaseString = JSON.serialize(toForceCastToPcCase);
        PC_Case__c pcCase = (PC_Case__c) JSON.deserialize(intermediatePcCaseString, PC_Case__c.class);

        Map<String, Object> toForceCastToAgentWork = new Map<String, Object>();
        toForceCastToAgentWork.put('Id', VATEST_IdFactory.get('AgentWork'));
        toForceCastToAgentWork.put('UserId', caseOwnerId);
        toForceCastToAgentWork.put('WorkItemId', pcCase.Id);

        String intermediateAgentWorkString = JSON.serialize(toForceCastToAgentWork);
        AgentWork agentWork = (AgentWork) JSON.deserialize(intermediateAgentWorkString, AgentWork.class);

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(agentWork, pcCase, null);
            pcSuperScreenPushEvent.setCaseClosedFields(null);
            Test.stopTest();
        }

        Assert.isNull(
            pcSuperScreenPushEvent?.pushEvent?.CaseClosedStatus__c,
            'Expected the Super Screen Push Event CaseClosedStatus__c field to be null, but the field was populated'
        );
    }

    /**
     * @description positive test of setSpecialtyAvailabilityFields to ensure that the Specialty Availability fields are set correctly
     */
    @IsTest
    static void unitSetSpecialtyAvailabilityFieldsPositive() {
        UserServicePresence userServicePresence = new UserServicePresence(
            Id = VATEST_IdFactory.get('UserServicePresence'),
            UserId = VATEST_IdFactory.get('User'),
            PC_Specialty__c = 'Cardiology'
        );

        PC_ProviderConnectController.SkillStatus skillStatus = new PC_ProviderConnectController.SkillStatus();
        skillStatus.skillName = 'Cardiology';

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(userServicePresence, null);
            pcSuperScreenPushEvent.setSpecialtyAvailabilityFields(skillStatus);
            Test.stopTest();
        }

        Assert.areEqual(
            userServicePresence.PC_Specialty__c,
            pcSuperScreenPushEvent.pushEvent.SkillName__c,
            'Expected the Super Screen Push Event SkillName__c field to be the same as the UserServicePresence record PC_Specialty__c field, but the values were different'
        );
    }

    /**
     * @description negative test of setSpecialtyAvailabilityFields to ensure that the Specialty Availability fields are gracefully not set when the parameters do not meet the required criteria
     */
    @IsTest
    static void unitSetSpecialtyAvailabilityFieldsNegative() {
        UserServicePresence userServicePresence = new UserServicePresence(
            Id = VATEST_IdFactory.get('UserServicePresence'),
            UserId = VATEST_IdFactory.get('User'),
            PC_Specialty__c = 'Cardiology'
        );

        PC_SuperScreenPushEvent pcSuperScreenPushEvent;
        System.runAs(SPECIALIST_USER) {
            Test.startTest();
            pcSuperScreenPushEvent = new PC_SuperScreenPushEvent(userServicePresence, null);
            pcSuperScreenPushEvent.setSpecialtyAvailabilityFields(null);
            Test.stopTest();
        }

        Assert.isNull(
            pcSuperScreenPushEvent?.pushEvent?.SkillName__c,
            'Expected the Super Screen Push Event SkillName__c field to be not set, but field was populated'
        );
    }
}
