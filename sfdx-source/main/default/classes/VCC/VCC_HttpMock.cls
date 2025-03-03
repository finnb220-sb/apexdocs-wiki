@isTest
/**
 * @description
 * @author Kumar Balan
 * @since 5/28/2021
 * @group HTTP
 */
global class VCC_HttpMock implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        String endpoint = req.getEndpoint();
        String response;
        System.debug('Endpoint -------------> ' + endpoint);
        if (endpoint.contains('appointments')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_AppointmentJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('meds')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_MedicationJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('flags')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_FlagJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('womensHealth')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_FlagJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('vitals')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_VitalJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('consults')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_ConsultJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('labs')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_LabJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('orders')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_OrderJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('notes')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_DischargeSummaryJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('allergyRequest')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_AllergyJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('problems')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_ProblemJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('Exam')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_RadiologyJsonExample' LIMIT 1][0].Body.toString();
        }
        if (endpoint.contains('immunization')) {
            response = [SELECT Id, Body FROM StaticResource WHERE Name = 'VCC_ImmunizationJsonExample' LIMIT 1][0].Body.toString();
        }

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setBody(response);
        res.setStatusCode(200);
        return res;
    }
}
