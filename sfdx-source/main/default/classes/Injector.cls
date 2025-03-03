/**
 * Author:Jaren Yach
 *  Created Date 05/04/2022
 *  Purpose: Class is used to help with dependency injection
 */
public inherited sharing class Injector {
    private static Injector injector;

    @TestVisible
    private static Injector mockInjector;

    public Object instantiate(String className) {
        // Load the Type corresponding to the class name
        Type t = Type.forName(className);

        // Create a new instance of the class
        // and return it as an Object
        return t.newInstance();
    }

    public static Injector getInjector() {
        if (mockInjector != null) {
            return mockInjector;
        } else if (injector == null) {
            injector = new Injector();
        }

        return injector;
    }
}
