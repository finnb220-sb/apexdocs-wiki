/**
 * @description       : This class will handle the MPI callouts to handle data to send back to the flow
 * @author            : Booz Allen Hamilton
 * @date              : 03-26-2024
 **/
public with sharing class VCC_MPIFlowAction {
    @TestVisible
    private static VCC_MPIParser response;
    private static final String TRUE_LITERAL = 'true';
    private static final String FALSE_LITERAL = 'false';
    private static final String NULL_LITERAL = 'null';
    private static final String WIFE_LITERAL = 'WIFE';
    private static final String HUSBAND_LITERAL = 'HUSBAND';

    /**
     * @description This invocable method gets called in a flow to take input and give outputs
     * @param flowInputs Inputs from the flow
     * @return List<FlowOutput> Returns the results of the callout
     **/
    @InvocableMethod(Label='MPI Callout Flow Action' Category='General' Callout=true)
    public static List<FlowOutput> calloutToMPI(List<FlowInput> flowInputs) {
        List<FlowOutput> results = new List<FlowOutput>();

        if (!Test.isRunningTest()) {
            response = VCC_OnPatientLoadController.retrieveVetInfo(flowInputs[0].recordId);
        }
        if (response != null) {
            FlowOutput output = new FlowOutput();
            ServiceDate serviceDate = getLatestServiceDate(response?.vetsV3[0].ee?.serviceBranches);
            output.serviceDates = serviceDate?.serviceEntryDate != null
                ? serviceDate?.serviceEntryDate + ' - ' + serviceDate?.serviceExitDate
                : '';
            output.branchOfService = serviceDate?.serviceBranch;
            output.militaryServiceNumber = serviceDate?.serviceNumber;
            output.spouseName = getSpouseName(response?.vetsV3[0].ee?.eeExtendedResponse?.associations);
            results.add(output);
        }

        return results;
    }

    /**
     * @description This will parse the MPI Callout response for the Spouse Name
     * @param associations Getting name of spouse when the association relationship is husband or wife
     * @return String Returns the spouse's name
     **/
    private static String getSpouseName(List<VCC_MPIParser.EEAssociation> associations) {
        String spouseName = null;
        if (associations != null && associations.size() > 0) {
            for (VCC_MPIParser.EEAssociation association : associations) {
                if (association.relationship == WIFE_LITERAL || association.relationship == HUSBAND_LITERAL) {
                    spouseName = association.givenName + ' ' + association.familyName;
                    break;
                }
            }
        }
        return spouseName;
    }

    /**
     * @description This method will parse the MPI Callout response for the Service Dates Information
     * @param branches Service Branches
     * @return ServiceDate Returns the Service Dates
     **/
    private static ServiceDate getLatestServiceDate(List<VCC_MPIParser.EEServiceBranch> branches) {
        if (branches != null && branches.size() > 0) {
            return loopServiceDatesBranches(branches);
        }

        return null;
    }

    /**
     * @description This formates the date to be {2 month}/{2 day}/{4 year}. This method was added to reduce the cognitive complexity in code scan.
     * @param serviceDate Service Dates
     * @return String Returns the dates in proper format
     **/
    private static String formatDate(String serviceDate) {
        return serviceDate != null
            ? serviceDate.mid(4, 2) + '/' + serviceDate.mid(6, 2) + '/' + serviceDate.mid(0, 4)
            : '';
    }

    /**
     * @description This loops through service branches and gets the latest service branch date. This method was added to reduce the cognitive complexity in code scan.
     * @param branches Service branches
     * @return ServiceDate Returns the Service Dates
     **/
    private static ServiceDate loopServiceDatesBranches(List<VCC_MPIParser.EEServiceBranch> branches) {
        ServiceDate serviceDate = new ServiceDate();
        Integer latestEntryDate = 0;
        Integer latestEntryDatePrior = 0;
        for (VCC_MPIParser.EEServiceBranch branch : branches) {
            latestEntryDate = Integer.valueOf(branch.serviceEntryDate); //format of the serviceEntryDate is 4YEAR2MONTH2DAY (e.g '20140704')
            if (latestEntryDate > latestEntryDatePrior) {
                String entryDate = branch?.serviceEntryDate;
                String exitDate = branch?.serviceExitDate;
                serviceDate.serviceEntryDate = formatDate(entryDate);
                serviceDate.serviceExitDate = formatDate(exitDate);
                serviceDate.serviceBranch = branch?.serviceBranch;
                serviceDate.serviceNumber = branch?.serviceNumber;
            }
            latestEntryDatePrior = latestEntryDate;
        }

        return serviceDate;
    }

    /**
     * @description This inner class will store the data coming from EEServiceBranch object
     **/
    private class ServiceDate {
        public String serviceEntryDate;
        public String serviceExitDate;
        public String serviceBranch;
        public String serviceNumber;
    }

    /**
     * @description This inner class will handle the flow inputs
     **/
    public class FlowInput {
        @InvocableVariable
        public String recordId; //account record ID
    }

    /**
     * @description This inner class will handle the flow outputs
     **/
    public class FlowOutput {
        @InvocableVariable
        public String serviceDates;

        @InvocableVariable
        public String branchOfService;

        @InvocableVariable
        public String militaryServiceNumber;

        @InvocableVariable
        public String spouseName;
    }
}
