public with sharing class VCC_SOT_OnboardingActivityTriggerHandler {
    public static void onboardingActivityDuplicatePrevention(List<VCC_Onboarding_Activity__c> onboardingActivityList) {
        List<String> triggerNewRecords = new List<String>();
        for (VCC_Onboarding_Activity__c voa : onboardingActivityList) {
            triggerNewRecords.add(voa.Name);
        }

        Map<String, VCC_Onboarding_Activity__c> onboardingActivityMap = new Map<String, VCC_Onboarding_Activity__c>();
        for (VCC_Onboarding_Activity__c voa : onboardingActivityList) {
            onboardingActivityMap.put(voa.Name, voa);
        }

        List<VCC_Onboarding_Activity__c> lstOnboardingActivities = [SELECT Id, Name FROM VCC_Onboarding_Activity__c WHERE Name IN :triggerNewRecords WITH SECURITY_ENFORCED];
        for (VCC_Onboarding_Activity__c voa : lstOnboardingActivities) {
            if (onboardingActivityMap.containsKey(voa.Name)) {
                onboardingActivityMap.get(voa.Name).addError('This Onboarding Activity already exists.');
            }
        }
    }
}
