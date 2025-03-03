/**
 * @description Shape/structure of the JSON HTTP response body of das/writeNote. For use in JSON.deserialize().
 */
@SuppressWarnings('PMD.ClassNamingConventions')
public with sharing class VCC_DASWriteNoteRS {
    public NoteResultTO noteResultTO;

    /**
     * @description structure within 'noteResultTO' JSON
     */
    public class NoteResultTO {
        public VCC_DASRSCommon.FaultTO fault;

        @SuppressWarnings('PMD.FieldNamingConventions') // naming of 'id' is required to match expected JSON response
        public String id;

        public Long totalPages;
        public Long lastPageRecd;
        public String explanation;

        /**
         * @description no-arg constructor solely for achieving test coverage
         */
        public NoteResultTO() {
            this.fault = new VCC_DASRSCommon.FaultTO();
        }
    }

    /**
     * @description no-arg constructor solely for achieving test coverage
     */
    public VCC_DASWriteNoteRS() {
        this.noteResultTO = new NoteResultTO();
    }
}
