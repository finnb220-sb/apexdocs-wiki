/**
 * @description       : TUC_HomeChildKanbanDTO defines the data transfer object used by the TUC_HomeChildKanban class
 *                      and corresponding test classes, and the TUC_HomeChildKanban.cmp Aura component. It's sole purpose is to
 *                      define the structural shape of the data that is passed between these classes and components.
 * @author            : Booz Allen Hamilton
 *
 * Note, this class is an evolution of the TUC_HomeChildKanbanUtil class.
 */
public with sharing class TUC_HomeChildKanbanDTO {
    @AuraEnabled
    /**
     * @description - List of Statuses shown on the Kanban cmp
     **/
    public List<String> pickVals { get; set; } // this is a list of included picklist values - always from the mdt record.
    @AuraEnabled
    /**
     * @description - The data set for the cases we want for the Kanban. Returned and used by the cmp.
     **/
    public Map<String, List<Case>> records { get; set; } // this is our generated list of records.
    @AuraEnabled
    /**
     * @description - Did we successfully retrieve cases
     **/
    public Boolean isSuccess { get; set; } // true unless we've hit an error.
    @AuraEnabled
    /**
     * @description - The error message in case something went wrong
     **/
    public String errorMessage { get; set; } // null unless we've hit an error.
    @AuraEnabled
    /**
     * @description - Are cases editable by the current user
     **/
    public Boolean isEditable { get; set; }
    @AuraEnabled
    /**
     * @description - Can the current user delete cases
     **/
    public Boolean isDeletable { get; set; }
    @AuraEnabled
    /**
     * @description - Can the current user create new cases
     **/
    public Boolean isCreatable { get; set; }
    @AuraEnabled
    /**
     * @description - Contains a field typing map for the fields retrieved as part of the fetch for card building by the cmp
     **/
    public Map<String, Map<String, String>> fieldTypeMap { get; set; }

    /**
     * @description Default constructor for TUC_HomeChildKanbanDTO.
     */
    public TUC_HomeChildKanbanDTO() {
        this.pickVals = new List<String>();
        this.records = new Map<String, List<Case>>();
        this.isSuccess = false;
        this.isEditable = false;
        this.isDeletable = false;
        this.isCreatable = false;
        this.fieldTypeMap = new Map<String, Map<String, String>>();
        this.isValid();
    }

    /**
     * @description Constructor for TUC_HomeChildKanbanDTO.
     * @param pickValstr - String[] this is a list of included picklist values - always from the mdt record.
     * @param records - Map<String,List<Case>> this is our generated list of records.
     * @param fieldTypeMap Map<String, Map<String, String>> this is the data structure the frontend uses to determine
     * the type of field and how to render it.
     */
    public TUC_HomeChildKanbanDTO(
        List<String> pickValstr,
        Map<String, List<Case>> records,
        Map<String, Map<String, String>> fieldTypeMap
    ) {
        this.pickVals = pickValstr;
        this.records = records;
        this.fieldTypeMap = fieldTypeMap;
        //initialize booleans as false
        this.isSuccess = false;
        this.isEditable = false;
        this.isDeletable = false;
        this.isCreatable = false;
        this.isValid();
    }

    private void isValid() {
        if (this.pickVals == null) {
            throw new VTC_BadRequestException('You must provide a list of picklist values');
        }

        if (this.records == null) {
            throw new VTC_BadRequestException('You must provide a map of records');
        }

        if (this.fieldTypeMap == null) {
            throw new VTC_BadRequestException('You must provide a map of field types that the Aura will expect');
        }
    }
}
