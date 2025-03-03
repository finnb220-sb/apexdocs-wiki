/**
 * @description
 * @author
 * @since
 * @group API - PCMM
 */
global with sharing class VCC_PACTSerializeRequestToJSON {
    @InvocableMethod
    global static List<Results> serialize(List<Requests> requestList) {
        // Todo: Training Mode look here to inject training mode service
        System.debug(LoggingLevel.INFO, 'entering object json serialize');

        //Wrap the Results object in a List container (an extra step added to allow this interface to also support bulkification)
        List<Results> responseWrapper = new List<Results>();

        for (Requests request : requestList) {
            SObject inputSObject = request.inputSObject;

            //Create a Results object to hold the return values
            Results response = new Results();

            // JSON Builder start
            JSONGenerator jsonBody = JSON.createGenerator(true);

            jsonBody.writeStartObject();
            System.debug(LoggingLevel.INFO, 'WRITING JSON OBJECT NOW');
            System.debug(LoggingLevel.INFO, request);
            // .get returns an object, so must cast as type needed
            if (inputSObject.get('VCC_MVI_External_Id__pc') != null) {
                jsonBody.writeStringField('icn', (String) inputSObject.get('VCC_MVI_External_Id__pc'));
            }

            jsonBody.writeStringField('application_id', request?.application_id == null ? '' : request.application_id); // maybe this gets more interesting later

            jsonBody.writeEndObject();

            // add the final result to the Results object
            response.serializedSObjectString = jsonBody.getAsString();
            System.debug(LoggingLevel.INFO, response.serializedSObjectString);
            responseWrapper.add(response);
        }

        return responseWrapper;
    }

    global class Results {
        @InvocableVariable
        global String serializedSObjectString;
    }

    global class Requests {
        @InvocableVariable(required=true)
        global SObject inputSObject;

        @InvocableVariable(required=true)
        global String icn;

        @InvocableVariable(required=false)
        global String application_id;
    }
}
