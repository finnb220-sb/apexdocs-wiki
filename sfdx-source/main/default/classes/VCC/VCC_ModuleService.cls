/**
 * @author Patrick Skamarak
 * @since 02/16/2023
 * @description
 * This class establishes a pattern for 'dependency injection'.
 * In this case a module is defined as an apex class that can be stubbed**.
 *
 * At time of writing, the following apex elements cannot be mocked/stubbed:
 *      Static methods (including future methods)
 *      Private methods
 *      Properties (getters and setters)
 *      Triggers
 *      Inner classes
 *      System types
 *      Classes that implement the Batchable interface
 *      Classes that have only private constructors
 *
 * **There are things that this service cannot detect (not without significan cpu overehead)
 * like private/static methods & getters/setters. Classes that contain those can still be
 * stubbed, but those particular pieces of code cannot be mocked to my knowledge.
 */
public with sharing class VCC_ModuleService {
    /** Exception Messages Start */
    private static final String MODULE_EXCEPTION_MESSAGE_TEMPLATE = '{0}';
    @TestVisible
    private static final String NO_INNER_CLASS_MODULE = 'Specified module is an inner class.';
    @TestVisible
    private static final String NO_SYSTEM_BATCHABLE_MODULE = 'Specified module implements System.Batchable interface.';
    @TestVisible
    private static final String DOES_NOT_IMPLEMENT_MODULE_INTERFACE = 'Specified module does not extend VCC_ModuleService.Module.';
    @TestVisible
    private static final String FAILED_INSTANTIATION = 'Specified module could not be instantiated due to: {0}';
    @TestVisible
    private static final String BAD_CONSTRUCTION = 'Modules may not be constructed with the \'new\' keyword. Use VCC_ModuleService.getModule(Type)';
    /** Exception Messages End */

    //Cached (already instantiated modules) are stored here
    private static Map<Type, Object> moduleCache = new Map<Type, Object>();

    @TestVisible
    //stub
    private static VCC_Stub stubModule(Type type) {
        VCC_Stub moduleStub = new VCC_Stub(type);
        moduleCache.put(type, moduleStub.instance);
        return moduleStub;
    }

    //overloaded getModule calls other getModule with 'useCache' as 'true'
    public static Object getModule(Type moduleType) {
        return getModule(moduleType, true);
    }

    // either pulls module from cache if it exists or creates it
    public static Object getModule(Type moduleType, Boolean useCache) {
        if ((useCache == true || Test.isRunningTest()) && moduleCache.containsKey(moduleType)) {
            return moduleCache.get(moduleType);
        }

        Object module = validateAndInstantiate(moduleType);
        moduleCache.put(moduleType, module);
        return module;
    }

    @TestVisible
    /**
     * Validates the given Type as a Module and creates a new
     * instance of it.
     */
    private static Object validateAndInstantiate(Type moduleType) {
        if (String.valueOf(moduleType).contains('.')) {
            raiseException(NO_INNER_CLASS_MODULE);
        }
        if ((Database.Batchable<Object>.class).isAssignableFrom(moduleType)) {
            raiseException(NO_SYSTEM_BATCHABLE_MODULE);
        }
        if (!VCC_ModuleService.Module.class.isAssignableFrom(moduleType)) {
            raiseException(DOES_NOT_IMPLEMENT_MODULE_INTERFACE);
        }

        allowConstruction = true;
        return moduleType.newInstance();
    }

    //used to prohibit 'newing-up' modules in the below Module class
    private static Boolean allowConstruction = false;

    //this interface is purely for querying ApexTypeImplementor in VCC_ModuleServiceTest.validateAllModules
    public interface ModuleInterface {
    }

    //could be expanded in the future
    public abstract class Module implements ModuleInterface {
        public Module() {
            if (VCC_ModuleService.allowConstruction != true) {
                VCC_ModuleService.raiseException(BAD_CONSTRUCTION);
            }
            VCC_ModuleService.allowConstruction = false;
        }
    }

    public static void raiseException(String msg) {
        throw new ModuleServiceException(String.format(MODULE_EXCEPTION_MESSAGE_TEMPLATE, new List<String>{ msg }));
    }

    public class ModuleServiceException extends Exception {
    }
}
