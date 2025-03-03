@isTest
public with sharing class VCC_ApiProxyTest {
    @isTest
    public static void baseApiProxyTest() {
        TestProxy testProxy = new TestProxy();

        Test.startTest();

        System.assert(!testProxy.isDebugModeEnabled(), 'Debug mode should be disabled.');
        testProxy.debugMode(true);
        System.assert(testProxy.isDebugModeEnabled(), 'Debug mode should be enabled.');

        System.assert(!testProxy.isTrainingModeEnabled(), 'Training mode should be disabled.');
        testProxy.trainingMode(true);
        System.assert(testProxy.isTrainingModeEnabled(), 'Training mode should be enabled.');

        testProxy.trainingMode(false);
        testProxy.debugMode(false);
        System.assert(!testProxy.isTrainingModeEnabled(), 'Training mode should be disabled.');
        System.assert(!testProxy.isDebugModeEnabled(), 'Debug mode should be disabled.');

        Test.stopTest();

        System.assert(true, 'Empty assert.');
    }

    public class TestClient extends VCC_BaseClient {
        protected override HttpRequest createHttpRequest(String method, Object body) {
            return null;
        }
    }

    public class TestProxy extends VCC_ApiProxy {
        protected override System.Type getClientType() {
            return TestClient.class;
        }
    }
}
