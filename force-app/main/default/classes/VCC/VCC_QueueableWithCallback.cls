public abstract class VCC_QueueableWithCallback implements System.Queueable {
    public void execute(System.QueueableContext queueableContext) {
        execute(this.callback, queueableContext);
    }

    public abstract void execute(Callable callback, System.QueueableContext queueableContext);

    private Callable callback { get; set; }

    public VCC_QueueableWithCallback(Callable callback) {
        this.callback = callback;
    }
}
