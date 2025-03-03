/**
 * @description Utility class with Exception utility methods.
 */
public with sharing class VCC_ExceptionUtils {
    /**
     * @description Logs the message passed into the method, instantiates and sets an Aura handled Exception
     * @param message `String` Message to be logged, and set in the AuraHandled Exception
     *
     * @return `AuraHandledException` Fully constructed Aura handled exception with its internal message set.
     */
    public static AuraHandledException createAuraHandledException(String message) {
        Logger.error(message);
        AuraHandledException exceptionForFrontEnd = new AuraHandledException(message);
        //This is required if you want anything other than Script-thrown exception.
        exceptionForFrontEnd.setMessage(message);
        return exceptionForFrontEnd;
    }

    /**
     * @description Given an exception with a message already set, create an Aura handled Exception with that same message.
     * @param genericException `Exception` Exception to base our AuraHandledException off of.
     *
     * @return `AuraHandledException` Instantiated  AuraHandled Exception with a C
     */
    public static AuraHandledException createAuraHandledException(Exception genericException) {
        return createAuraHandledException(genericException.getMessage());
    }

    /**
     * @description Given a prefix, postix and and exception, join their three messages and return an AuraHandled Exception.
     * @param prefix `String` String to be concatenated to the beginning of the exception message.
     * @param genericException `Exception` to base our AuraHandledExceptions message off of.
     * @param postfix `String` String to be concatenated to the end of the exception message.
     *
     * @return `AuraHandledException` return a fully constructed AurahandlexException.
     */
    public static AuraHandledException createAuraHandledException(
        String prefix,
        Exception genericException,
        String postfix
    ) {
        return createAuraHandledException(prefix + genericException.getMessage() + postfix);
    }

    /**
     * @description Given an exception and a map containing the corresponding commands, this will return an AuraHandledException with the appropriate command as the message
     * @param excep `Exception` exception that the program threw originally
     * @param commandMap `Map<String, String>` map containing command to send based on exception type
     * @param defaultCommand `String` default command if exception was not in the command map
     *
     * @return `AuraHandledException` return a fully constructed AurahandlexException.
     */
    public static AuraHandledException createAuraHandledException(
        Exception excep,
        Map<String, String> commandMap,
        String defaultCommand
    ) {
        return commandMap.containsKey(excep.getTypeName())
            ? createAuraHandledException(commandMap.get(excep.getTypeName()))
            : createAuraHandledException(defaultCommand);
    }
}
