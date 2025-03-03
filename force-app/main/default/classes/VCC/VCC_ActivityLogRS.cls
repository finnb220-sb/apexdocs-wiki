public class VCC_ActivityLogRS extends VCC_DivaResponse {
    @AuraEnabled
    public Boolean success;
    @AuraEnabled
    public String message;
    @AuraEnabled
    public List<ActivityLog> log;

    public class ActivityLog {
        @AuraEnabled
        public String activityLogDate;
        @AuraEnabled
        public String initiatorOfActivity;
        @AuraEnabled
        public String reason;
        @AuraEnabled
        public String rxReference;
        @AuraEnabled
        public String comment;
        @AuraEnabled
        public List<OtherComment> otherComments;
        @AuraEnabled
        public String otherCommentsString;
    }

    public class OtherComment {
        @AuraEnabled
        public String otherComments;
    }

    public VCC_ActivityLogRS concatOtherComments() {
        if (!this.success) {
            return this; // don't proceed, return object as is
        }

        List<String> otherCommentsCollection = new List<String>();

        for (ActivityLog log : this.log) {
            if (log.otherComments?.size() > 0) {
                for (OtherComment oc : log?.otherComments) {
                    if (oc != null) {
                        otherCommentsCollection.add(oc?.otherComments);
                    }
                }
            }
            log.otherCommentsString = String.join(otherCommentsCollection, ', ');
        }

        return this;
    }

    public static VCC_ActivityLogRS parse(String responseBody) {
        return (VCC_ActivityLogRS) System.JSON.deserialize(responseBody, VCC_ActivityLogRS.class);
    }
}
