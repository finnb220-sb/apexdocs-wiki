/**
 * @description Abstract class that implements Callable specifically for use in OmniStudio Integration Procedure's (IP).
 * Classes that extend VCC_OmniRemoteAction must implement a new call() method that accepts a string methodName and an
 * ArgTuple defined in this class.
 * @author Booz Allen Hamilton
 * @see `VCC_SchedulingOmniConnector`
 * @example
 * public class VCC_SchedulingOmniConnector extends VCC_OmniRemoteAction {
 *      protected override Object call(String methodName, VCC_OmniRemoteAction.ArgTuple argTuple) {
 *          switch on methodName {
 *              when 'someMethod' {
 *                  this.someMethod(argTuple);
 *              } when else {
 *                  throw new IllegalArgumentException('Method does not exist');
 *              }
 *          }
 *          return true;
 *      }
 * }
 */
public abstract class VCC_OmniRemoteAction implements Callable {
    @TestVisible
    private static final String ARG_TUPLE_INVALID_OR_MISSING_METHOD_NAME = 'Callable.call() methodName is a null or blank String';
    @TestVisible
    private static final String ARG_TUPLE_INVALID_OR_MISSING_MAP = 'Callable.call() args map input, output, or options keys must contain non-null Map<String, Object>\'s';

    /**
     * @description Wrapper class to house input, output, and options maps extracted from Callable.call's args map
     */
    public class ArgTuple {
        /**
         * @description methodName from Callable interface call method
         */
        public String methodName { get; private set; }

        /**
         * @description input map received from OmniStudio IP
         */
        public Map<String, Object> input { get; private set; }

        /**
         * @description output map returned to OmniStudio IP
         */
        public Map<String, Object> output { get; private set; }

        /**
         * @description options map received from OmniStudio IP
         */
        public Map<String, Object> options { get; private set; }

        /**
         * @description ArgTuple constructor
         * @param callableMethodName `String` method name from Callable.call(methodName, args)
         * @param callableArgs `Map<String, Object>` args from Callable.call(methodName, args)
         */
        public ArgTuple(String callableMethodName, Map<String, Object> callableArgs) {
            this.methodName = callableMethodName;
            if (String.isBlank(this.methodName)) {
                throw new IllegalArgumentException(ARG_TUPLE_INVALID_OR_MISSING_METHOD_NAME);
            }
            this.input = (Map<String, Object>) callableArgs?.get('input');
            this.output = (Map<String, Object>) callableArgs?.get('output');
            this.options = (Map<String, Object>) callableArgs?.get('options');
            if (this.input == null || this.output == null || this.options == null) {
                throw new IllegalArgumentException(ARG_TUPLE_INVALID_OR_MISSING_MAP);
            }
        }
    }

    /**
     * @description Implementation of Callable.call that extracts the input, output, and options and places them into an ArgTuple
     * @param methodName `String` name of the method to be invoked
     * @param args `Map<String, Object>` containing the input/output/options from the IP
     * @return `Object` Boolean result of call(). true being success, false otherwise.
     */
    public Object call(String methodName, Map<String, Object> args) {
        return this.call(new ArgTuple(methodName, args));
    }

    /**
     * @description New method to implement. Given a method name and OmniStudio args (input, output, and options)
     * execute the apex associated with specified method name. Setting the return value in the output map.
     * @param argTuple `VCC_OmniRemoteAction.ArgTuple` object containing the methodName, input, output, and options
     * @return `Object` Boolean result of call(). true being success, false otherwise.
     */
    protected abstract Object call(ArgTuple argTuple);
}
