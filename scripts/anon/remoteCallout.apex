HttpRequest request = new HttpRequest(); // newing up the request body
String namedCredString = 'vccBridg_qa'; // using bridg qa aka hdr qa
String endpointstring = 'v1/meds'; // endpoint string, change this to point to the desired endpoint
request.setEndpoint('callout:' + namedCredString + '/' + endpointstring); // concatinating (sp?) named cred and endpoint
request.setMethod('POST');// boilerplate
request.setHeader('Content-Type', 'application/json;charset=UTF-8'); // boilerplate
request.setHeader('apiKey', '{!$Credential.Password}'); // change this to 'clientSecret' for MPI or whatever the named cred calls for
request.setTimeout(120000); // boilerplate
HttpResponse resp; // response

system.debug('callout:' + namedCredString + '/' + endpointstring);

// construct the body of the request here using a map
String body = JSON.serialize(new Map<String, Object>{
    'nationalId' => '1012835386V730604',
    'startDate' => '2022-01-01'
});

// AA LAD,LAKXUM = '1012835270V798147'
// Alanna Grey = '1012835130V916240'
// Javier Oscar = '1012826101V366128'
// Larry Lima = '1012660666V427556'
// ROBERTA BARRERA LUCAS = '1012835386V730604'

request.setBody(body);
//System.debug(LoggingLevel.INFO, 'VAHC::request' + request.getBody());
resp = (new Http()).send(request);

// in case we don't get a 200 response
if (resp.getStatusCode() != 200) {
    System.debug('well shucks no response: ' + resp.getBody());
}

System.debug(resp.getBody());