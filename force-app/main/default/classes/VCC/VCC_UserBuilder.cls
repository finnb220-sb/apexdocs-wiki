/**
 * @description Instance of builder class for test users/personas for VCC application. It extends the Test Accelerator
 *  version of the builder, assigning Test User/Persona to PSG giving them access to Test & Mock Classes to ensure
 *  tests do not fail
 * @author Booz Allen Hamilton
 * @see VATEST_UserBuilder
 * @see VCC_UserBuilderTest
 */
public with sharing class VCC_UserBuilder extends VATEST_UserBuilder {
    @TestVisible
    /**
     * @description  Name of PSG that holds all PS names for the Apex Tests & Mocks.
     *  The idea is that different features/applications can add Permission Sets to the PSG.
     */
    private static final String APEX_TEST_PERMISSION_SET_GROUP_NAME = 'VAHC_Apex_Tests_Mocks';

    /**
     * @description Create a new instance of the test accelerator for building test users with
     *  permission(s) to access all Apex test & mock classes to facilitate impersonation of
     *  the various personas
     */
    public VCC_UserBuilder() {
        super();
        // always include the Apex & Mock Apex classes
        this.permissionSetNames.add(APEX_TEST_PERMISSION_SET_GROUP_NAME);
    }
}
