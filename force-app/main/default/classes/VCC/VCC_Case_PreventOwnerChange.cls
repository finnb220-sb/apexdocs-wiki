/**
 * @description Trigger Handler for Before Update Trigger When Case OwnerId is changed
 * @author Raj Hoare
 * @since 10/31/2023
 * @group Object - Case
 *
 * updated 01/07/2024 by Lung Joe - PMD violdation corrections
 */
//Need to suppress this warning due to SOQLing PermssionSetAssignment object which is only available in system mode context for actual running users
@SuppressWarnings('PMD.ApexCRUDViolation')
public with sharing class VCC_Case_PreventOwnerChange implements TriggerAction.BeforeUpdate {
    public static final string userErr = label.VCC_Prevent_New_Case_Owner_From_Taking_Case;
    public static final string queueErr = label.VCC_Prevent_Queue_From_Taking_Case;

    List<Case> newOwnerUserLst = new List<Case>();
    List<Case> newOwnerQueueLst = new List<Case>();
    Set<Id> newOwnerUserIds = new Set<Id>();
    Set<Id> newOwnerQueueIds = new Set<Id>();
    Set<Id> validRecordTypeIds = new Set<Id>{
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Administrative').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId(),
        Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Vitrual_Clinic_Visit').getRecordTypeId()
    };

    /**
     * @description Validates the desired new owner of a case to meet permissions criteria before the update operation
     *
     * @param newCases - cases data with desired updated data
     * @param oldCases - cases data with the previous data before the update
     */
    public void beforeUpdate(List<Case> newCases, List<Case> oldCases) {
        Map<Id, Case> oldCasesMap = new Map<Id, Case>(oldCases);
        List<Group> queueGroupLst = new List<Group>();
        List<Case> newOwnerUserLst = new List<Case>();
        List<Case> newOwnerQueueLst = new List<Case>();
        List<Case> oldOwnerQueueLst = new List<Case>();
        Set<Id> oldOwnerQueueIds = new Set<Id>();
        Set<Id> newOwnerUserIds = new Set<Id>();
        Set<Id> newOwnerQueueIds = new Set<Id>();

        for (Case c : newCases) {
            if (
                c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId() ||
                c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Administrative').getRecordTypeId() ||
                c.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId() ||
                c.recordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Vitrual_Clinic_Visit').getRecordTypeId()
            ) {
                //Check if Case has a new Owner Id. If so, Check if new Owner Id is a User or Group(Queue)
                for (Case updatedCase : newCases) {
                    String ownerIdString = String.valueOf(updatedCase.OwnerId);
                    if (updatedCase.OwnerId != oldCasesMap.get(updatedCase.Id).OwnerId) {
                        if (!ownerIdString.startsWith('00G')) {
                            newOwnerUserIds.add(updatedCase.OwnerId);
                            newOwnerUserLst.add(updatedCase);
                        } else {
                            newOwnerQueueIds.add(updatedCase.OwnerId);
                            newOwnerQueueLst.add(updatedCase);
                        }
                    }
                }
                // Check if Old Case Owner was a Queue
                for (Case oldQueueCase : oldCases) {
                    String queueIdString = String.valueOf(oldQueueCase.OwnerId);
                    if (queueIdString.startsWith('00G')) {
                        oldOwnerQueueLst.add(oldQueueCase);
                        oldOwnerQueueIds.add(oldQueueCase.OwnerId);
                    }
                }
            }
        }
        // If New Owner is a User...
        if (!newOwnerUserIds.isEmpty()) {
            // Query PermissionSetAssignment to Get the New Owner's VCC Permission Set Groups
            List<PermissionSetAssignment> psaLst = [
                SELECT AssigneeId, PermissionSetGroup.DeveloperName
                FROM PermissionSetAssignment
                WHERE
                    AssigneeId IN :newOwnerUserIds
                    AND PermissionSetGroup.DeveloperName IN (
                        'VCC_Registered_Nurse',
                        'VCC_Advanced_Medical_Support_Assistant',
                        'VCC_Pharmacy_I',
                        'VCC_Pharmacy_II',
                        'VCC_Pharmacy_III',
                        'VCC_Tier_I_Supervisor',
                        'VCC_Tier_II_Supervisor',
                        'VCC_Tier_III_Supervisor',
                        'VCC_Medical_Provider'
                    )
            ];

            // Create a map to store the permission set groups assigned to each user
            List<String> psgLst = new List<String>();
            Map<Id, Set<String>> permissionSetsByUser = new Map<Id, Set<String>>();
            for (PermissionSetAssignment psa : psaLst) {
                if (!permissionSetsByUser.containsKey(psa.AssigneeId)) {
                    permissionSetsByUser.put(psa.AssigneeId, new Set<String>());
                }
                permissionSetsByUser.get(psa.AssigneeId).add(psa.PermissionSetGroup.DeveloperName);
                String s = psa.PermissionSetGroup.DeveloperName;
                psgLst.add(s);
            }
            // If Old Owner was a Queue...
            if (!oldOwnerQueueLst.isEmpty()) {
                queueGroupLst = [SELECT Id, Name FROM Group WHERE Id IN :oldOwnerQueueIds WITH SECURITY_ENFORCED];
                Map<Id, String> oldQueueNamesByOwner = new Map<Id, String>();
                if (!queueGroupLst.isEmpty()) {
                    for (Group queue : queueGroupLst) {
                        if (!oldQueueNamesByOwner.containsKey(queue.Id)) {
                            oldQueueNamesByOwner.put(queue.Id, queue.Name);
                        }
                    }
                }
                //Loop Through Case List Where Old Case Owner was a Queue, check Pharmacy Queue Name and if the new Owner has the correct permissions to take the Case. Show Error if New Owner doesn't have correct Tier permissions.
                for (Case oldQ : oldOwnerQueueLst) {
                    if (
                        (oldQueueNamesByOwner.get(oldQ.OwnerId).contains('PHARM-TIER I') || oldQueueNamesByOwner.get(oldQ.OwnerId).contains('PHARM-TIER-I')) &&
                        oldQ.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId() &&
                        (!psgLst.contains('VCC_Pharmacy_I') &&
                        !psgLst.contains('VCC_Tier_I_Supervisor') &&
                        !psgLst.contains('VCC_Pharmacy_II') &&
                        !psgLst.contains('VCC_Tier_II_Supervisor') &&
                        !psgLst.contains('VCC_Pharmacy_III') &&
                        !psgLst.contains('VCC_Tier_III_Supervisor'))
                    ) {
                        final string pharm1Error = userErr.replace('{0}', 'Pharmacy Tier I');
                        newCases[0].addError(pharm1Error);
                    }
                    if (
                        (oldQueueNamesByOwner.get(oldQ.OwnerId).contains('PHARM-TIER II') || oldQueueNamesByOwner.get(oldQ.OwnerId).contains('PHARM-TIER-II')) &&
                        oldQ.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId() &&
                        (!psgLst.contains('VCC_Pharmacy_II') &&
                        !psgLst.contains('VCC_Tier_II_Supervisor') &&
                        !psgLst.contains('VCC_Pharmacy_III') &&
                        !psgLst.contains('VCC_Tier_I_Supervisor') &&
                        !psgLst.contains('VCC_Tier_II_Supervisor') &&
                        !psgLst.contains('VCC_Tier_III_Supervisor'))
                    ) {
                        final string pharm2Error = userErr.replace('{0}', 'Pharmacy Tier II');
                        newCases[0].addError(pharm2Error);
                    }
                    if (
                        (oldQueueNamesByOwner.get(oldQ.OwnerId).contains('PHARM-TIER III') || oldQueueNamesByOwner.get(oldQ.OwnerId).contains('PHARM-TIER-III')) &&
                        oldQ.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId() &&
                        (!psgLst.contains('VCC_Pharmacy_III') &&
                        !psgLst.contains('VCC_Tier_I_Supervisor') &&
                        !psgLst.contains('VCC_Tier_II_Supervisor') &&
                        !psgLst.contains('VCC_Tier_III_Supervisor'))
                    ) {
                        final string pharm3Error = userErr.replace('{0}', 'Pharmacy Tier III');
                        newCases[0].addError(pharm3Error);
                    }
                }
            }
            // Loop through Case List to check Case's Record Type, and if the Owner has the Permission Set to work on the case. If New Owner Does not have correct Permission, then show error message
            for (Case c1 : newOwnerUserLst) {
                if (
                    c1.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId() &&
                    (!permissionSetsByUser.containsKey(c1.OwnerId) || !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Registered_Nurse'))
                ) {
                    final String ctError = userErr.replace('{0}', 'Clinical Triage');
                    newCases[0].addError(ctError);
                }
                if (
                    c1.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Administrative').getRecordTypeId() &&
                    (!permissionSetsByUser.containsKey(c1.OwnerId) || !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Advanced_Medical_Support_Assistant'))
                ) {
                    final String msaError = userErr.replace('{0}', 'Administrative & Scheduling');
                    newCases[0].addError(msaError);
                }

                if (
                    c1.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Vitrual_Clinic_Visit').getRecordTypeId() &&
                    (!permissionSetsByUser.containsKey(c1.OwnerId) || !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Medical_Provider'))
                ) {
                    final String vcvError = userErr.replace('{0}', 'Virtual Clinic Visit');
                    newCases[0].addError(vcvError);
                }
                if (
                    c1.RecordTypeId == Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId() &&
                    (!permissionSetsByUser.containsKey(c1.OwnerId) ||
                    (!permissionSetsByUser.get(c1.OwnerId).contains('VCC_Pharmacy_I') &&
                    !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Pharmacy_II') &&
                    !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Pharmacy_III') &&
                    !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Tier_I_Supervisor') &&
                    !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Tier_II_Supervisor') &&
                    !permissionSetsByUser.get(c1.OwnerId).contains('VCC_Tier_III_Supervisor')))
                ) {
                    final String pharmError = userErr.replace('{0}', 'Pharmacy');
                    newCases[0].addError(pharmError);
                }
            }
        }
        // If New Owner is a Queue...
        if (!newOwnerQueueIds.isEmpty()) {
            queueGroupLst = [SELECT Id, Name FROM Group WHERE Id IN :newOwnerQueueIds WITH SECURITY_ENFORCED];

            Map<Id, String> queueNamesByOwner = new Map<Id, String>();

            if (!queueGroupLst.isEmpty()) {
                for (Group queue : queueGroupLst) {
                    if (!queueNamesByOwner.containsKey(queue.Id)) {
                        queueNamesByOwner.put(queue.Id, queue.Name);
                    }
                }
            }
            // Loop through Case List Where new Owner Id is a Queue. If the Case Record Type does not match what should go in Persona Queue, then show Error.
            for (Case c2 : newOwnerQueueLst) {
                if (
                    queueNamesByOwner.get(c2.OwnerId).contains('RN') &&
                    (c2.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Clinical_Triage').getRecordTypeId() ||
                    (!queueNamesByOwner.containsKey(c2.OwnerId)))
                ) {
                    String ctError = queueErr.replace('{0}', 'Clinical Triage');
                    c2.addError(ctError);
                    newCases[0].addError(ctError);
                }
                if (
                    (queueNamesByOwner.get(c2.OwnerId).contains('MSA') &&
                    c2.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Administrative').getRecordTypeId()) ||
                    !queueNamesByOwner.containsKey(c2.OwnerId)
                ) {
                    final String msaError = queueErr.replace('{0}', 'Administrative & Scheduling');
                    newCases[0].addError(msaError);
                }
                if (
                    (queueNamesByOwner.get(c2.OwnerId).contains('PHARM') &&
                    c2.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Pharmacy').getRecordTypeId()) ||
                    !queueNamesByOwner.containsKey(c2.OwnerId)
                ) {
                    String pharmError = queueErr.replace('{0}', 'Pharmacy');
                    newCases[0].addError(pharmError);
                }
                if (
                    (queueNamesByOwner.get(c2.OwnerId).contains('MP') &&
                    c2.RecordTypeId != Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('VCC_Vitrual_Clinic_Visit').getRecordTypeId()) ||
                    !queueNamesByOwner.containsKey(c2.OwnerId)
                ) {
                    final String vcvError = queueErr.replace('{0}', 'Virtual Clinic Visit');
                    newCases[0].addError(vcvError);
                }
            }
        }
    }
}
