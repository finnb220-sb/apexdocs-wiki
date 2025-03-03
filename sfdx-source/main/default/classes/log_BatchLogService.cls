@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class log_BatchLogService extends log_LogService {
    /** The class stores the Database.Error record info */
    public class DatabaseErrorDetailLog {
        public String status;
        public String message;
        public String fields;

        /**
         * @param error Database.Error single record
         * */
        public DatabaseErrorDetailLog(Database.Error error) {
            this.status = String.valueOf(error.getStatusCode());
            this.message = error.getMessage();
            if (!error.getFields().isEmpty()) {
                this.fields = String.join(error.getFields(), ',');
            }
        }
    }

    /** The class stores the Database.Error records info and failed record details */
    public class DatabaseErrorLog {
        public String objectName;
        public String recordId;
        public List<DatabaseErrorDetailLog> logDetails;

        /**
         * @param recordId SObject record Id
         * @param logDetails List<OHRS_Service_Log.DatabaseErrorDetailLog>
         * */
        public DatabaseErrorLog(Id recordId, List<DatabaseErrorDetailLog> logDetails) {
            this.objectName = String.valueOf(recordId.getSobjectType());
            this.recordId = recordId;
            this.logDetails = logDetails;
        }
    }

    public class BatchInfoLog {
        public String jobId;
        public String className;
        public String createdAt;
        public String completedAt;
        public String status;
        public String details;
        public Integer batchesProcessed;
        public Integer totalBatches;
        public Integer failedBatches;

        /** Total Time Spent on Batch Job in Minutes */
        public Decimal totalMinSpent;

        /**
         * @param currentJob AsyncApexJob
         * */
        public BatchInfoLog(AsyncApexJob currentJob) {
            if (currentJob != null) {
                this.jobId = currentJob.Id;
                this.className = currentJob.ApexClass.Name;
                this.createdAt = (currentJob.CreatedDate != null) ? currentJob.CreatedDate.format('MMM dd, yyyy HH:mm:ss a') : Datetime.now().format('MMM dd, yyyy HH:mm:ss a');
                this.status = currentJob.Status;
                this.details = currentJob.ExtendedStatus;
                this.batchesProcessed = currentJob.JobItemsProcessed;
                this.totalBatches = currentJob.TotalJobItems;
                this.failedBatches = currentJob.NumberOfErrors;
            }
        }
    }
}
