/**
 * @description Extension of VCC_NebulaWrapper that adds tags to every debug/error entry
 * @see VCC_NebulaWrapper
 */
public virtual with sharing class VCC_NebulaWrapperWithTags extends VCC_NebulaWrapper {
    @TestVisible
    private Set<String> tags = new Set<String>();

    /**
     * @description Empty constructor for testing.
     */
    @TestVisible
    private VCC_NebulaWrapperWithTags() {
        return;
    }

    /**
     * @description Constructs this wrapper with the given tags
     * @param tags the set of tags to use add to logs
     */
    public VCC_NebulaWrapperWithTags(Set<String> tags) {
        this.addTags(tags);
    }

    /**
     * @description Adds tags which will then be added to future log entries
     * @param tags set of tags to add
     * @return `VCC_NebulaWrapperWithTags` this wrapper
     */
    public VCC_NebulaWrapperWithTags addTags(Set<String> tags) {
        this.tags.addAll(tags);
        return this;
    }

    /**
     * @description Removes tags from future log entries
     * @param tags set of tags to remove
     * @return `VCC_NebulaWrapperWithTags` this wrapper
     */
    public VCC_NebulaWrapperWithTags removeTags(Set<String> tags) {
        this.tags.removeAll(tags);
        return this;
    }

    /**
     * @description Calls parent class debug method and adds tags
     * @param message The `String` log message.
     * @return a `LogEntry`
     */
    public override LogEntryEventBuilder debug(String message) {
        return super.debug(message).addTags(new List<String>(this.tags));
    }

    /**
     * @description Calls parent class error method and adds tag
     * @param logMessage The `String` message to log.
     * @param apexException The `Exception` to log.
     * @return a `LogEntry`
     */
    public override LogEntryEventBuilder error(String logMessage, Object apexException) {
        return super.error(logMessage, apexException).addTags(new List<String>(this.tags));
    }
}
