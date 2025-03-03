trigger VCC_SOT_OnboardingActivity_Trigger on VCC_Onboarding_Activity__c(before insert) {
    Boolean disableTriggers = FeatureManagement.checkPermission('DisableTriggersFlag');
    if (!disableTriggers) {
        if (Trigger.isInsert && Trigger.isBefore) {
            VCC_SOT_OnboardingActivityTriggerHandler.onboardingActivityDuplicatePrevention(Trigger.New);
        }
    }
}
