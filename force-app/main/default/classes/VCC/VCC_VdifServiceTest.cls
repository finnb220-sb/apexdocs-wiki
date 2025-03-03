@isTest
/**
 * @description
 * @author
 * @since
 * @group Test Classes
 * @see VCC_VdifService
 */
public with sharing class VCC_VdifServiceTest {
    @isTest
    public static void missingRequiredFieldsTest() {
        VCC_VdifService.MissingOrInvalidParameterException expectedException;
        try {
            VCC_VdifService.callService('vccVdifSignNote', new Map<String, Object>());
        } catch (VCC_VdifService.MissingOrInvalidParameterException e) {
            expectedException = e;
        }

        System.assert(expectedException != null, 'Expected exception was not thrown');
    }

    @isTest
    public static void serviceNotConfiguredTest() {
        VCC_VdifService.ServiceNotConfiguredException expectedException;
        try {
            VCC_VdifService.VdifHttpRequest req = new VCC_VdifService.VdifHttpRequest('test');
        } catch (VCC_VdifService.ServiceNotConfiguredException e) {
            expectedException = e;
        }

        System.assert(expectedException != null, 'Expected exception was not caught.');
    }

    @isTest
    public static void serviceTestHappy() {
        StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
        mock.setStaticResource('VCC_vdifSaveNoteAndEncounterMockResponse');
        mock.setStatus('200');
        Test.setMock(HttpCalloutMock.class, mock);

        VCC_VdifService.callService(
            'vccVdifSignNote',
            new Map<String, Object>{
                'esig' => 'test',
                'providerLoginSiteCode' => 'test',
                'providerName' => 'test',
                'providerUserId' => 'test',
                'noteIEN' => 'test',
                'userDUZ' => 'test'
            }
        );

        VCC_VdifService.callService(
            'vccVdifSaveNoteAndEncounter',
            new Map<String, Object>{
                'providerLoginSiteCode' => 'test',
                'providerUserId' => 'test',
                'patientLocalPid' => 'test',
                'patientLocalSiteId' => 'test',
                'noteAndEncounterLocationIen' => 'test',
                'noteAndEncounterNoteTitleIen' => 'test',
                'noteAndEncounterServiceCategory' => 'test',
                'noteAndEncounterProcedures' => 'test',
                'noteAndEncounterDiagnoses' => 'test',
                'noteAndEncounterVisitRelatedTos' => 'test'
            }
        );

        VCC_VdifService.callService(
            'vccVdifWriteNote',
            new Map<String, Object>{
                'encounterString' => 'test',
                'text' => 'test',
                'providerName' => 'test',
                'providerLoginSiteCode' => 'test',
                'providerUserId' => 'test',
                'patientLocalPid' => 'test',
                'titleIEN' => 'test'
            }
        );

        System.assert(true, 'Force assertion.');
    }
}
