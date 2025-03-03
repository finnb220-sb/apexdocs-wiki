String serviceName = 'vccDivaActivityLog';
// 'vccDivaActivityLog'
// 'vccDivaRefillLog'
// 'vccDivaLabelLog'
// 'vccDivaERXLog'
// 'vccDivaCMOPLog'
// 'vccDivaCopayLog'
// 'vccDivaECMELog'
// 'vccDivaPartialsFillLog'
// 'vccDivaCMOPLotExpirationLog'

HttpRequest request = new HttpRequest();
request.setEndpoint(VCC_EndpointUtility.getEndpoint('DIVA', serviceName));
request.setHeader('Accept', 'application/json');
request.setHeader('Content-Type', 'application/json; charset=UTF-8');
request.setHeader('clientId', '{!$Credential.Username}');
request.setHeader('clientSecret', '{!$Credential.Password}');
request.setMethod('POST'); // Will these endponts always be POSTs?

String rq = JSON.serialize(new Map<String, Object>{
	'facilityId' => '982',
	'prescriptionId' => '22139514'
});


request.setBody(rq);
request.setTimeout(120000); // TODO: this needs to be in custom md

HttpResponse resp = new Http().send(request);

if (resp.getStatusCode() != 200) {
    System.debug('well shucks no response: ' + resp.getBody());
}

System.debug('resp::: ' + resp);
System.debug('resp.getBody()::: ' + resp.getBody());