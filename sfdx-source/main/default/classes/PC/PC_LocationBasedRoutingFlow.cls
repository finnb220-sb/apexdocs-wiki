/**
 * @description Holds the invocable flow action entry point for NDTH Agreement routing logic for PC Cases (including proximity based tiebreaker that utilizes the FLP's Location Address and compares it in a distance formula with the available Specialist's Location Address)
 * @author      Booze Allen Hamilton
 * @since       2024
 * @see         PC_LocationBasedRouting
 * @justification This class needs inherited sharing in order to inherit the sharing from the Flow the calls it
 */
public inherited sharing class PC_LocationBasedRoutingFlow {
    /**
     * @description holds instantiation of the routing driver class
     */
    @TestVisible
    private static PC_LocationBasedRouting routingDriver {
        get {
            return routingDriver = routingDriver ?? new PC_LocationBasedRouting();
        }
        set;
    }

    /**
     * @description Main invocable apex method entry point that drives the NDTH routing logic. It calculates the most available (per current case-load) and nearest (as the crow flies) online specialist under the NDTH agreement routing rules
     * @param flowInputs List of inputs for the invocable method containing the flp user Id(s) and their respective selected specialties
     * @return List<String> list of sf user Id(s) for the selected specialist(s)
     **/
    @InvocableMethod(
        Label='Get Nearest Service Resource'
        Description='Gets the most available/nearest service resource (Specialist) to FLP user location based on current case load, provided specialty and applicable NDTH Agreements'
        Category='Provider Connect'
    )
    public static List<String> getNearestAvailableSpecialistForFlow(List<PrcCaseRoutingFlowInput> flowInputs) {
        if (
            flowInputs == null ||
            flowInputs.isEmpty() ||
            String.isBlank(flowInputs[0].userid) ||
            String.isBlank(flowInputs[0].skillName)
        ) {
            PC_ExceptionUtils.logAndThrowIllegalArgumentError(
                'Invalid input found for the invocable method, getNearestAvailableSpecialistForFlow'
            );
        }

        String flpUserId = flowInputs[0].userid;
        String skillName = flowInputs[0].skillName;

        String nearestSpecialistUserId = routingDriver.getNearestAvailableSpecialist(flpUserId, skillName);

        return new List<String>{ nearestSpecialistUserId };
    }

    /**
     * @description Wrapper class containing FLP user's Id and the required skill (specialty) for routing the Case via Flow entry
     */
    public class PrcCaseRoutingFlowInput {
        @InvocableVariable(required=true)
        public Id userid;

        @InvocableVariable(required=true)
        public String skillName;
    }
}
