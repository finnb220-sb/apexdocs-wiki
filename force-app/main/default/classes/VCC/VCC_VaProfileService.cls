/**
 * @description Profile Service that sends out a POST API call to upsert associated persons
 * @author Liberty
 * @since 01/07/2024
 */
public with sharing class VCC_VaProfileService extends VCC_ModuleService.Module {
    /**
     * @description Given a proper request, this method sends a callout to upsert the associated persons
     * @param associatedPersonsRQ
     * @return  `VCC_VaProfileAssociatedPersonsRS`
     * @exception
     */
    public VCC_VaProfileAssociatedPersonsRS upsertAssociatedPersons(VCC_VaProfileAssociatedPersonsRQ associatedPersonsRQ) {
        HttpRequest request = new HttpRequest();
        request.setEndpoint(VCC_EndpointUtility.getEndpoint('MPIe', 'vaProfileUpsertAssociatedPersons'));
        request.setMethod('POST');
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('clientid', '{!$Credential.UserName}');
        request.setHeader('clientSecret', '{!$Credential.Password}');
        request.setTimeout(120000);
        request.setBody(JSON.serialize(associatedPersonsRQ));

        HttpResponse resp = VCC_HttpService.send(request);

        if (resp.getStatusCode() != 200) {
            throw new VCC_RemoteServiceException(resp.getBody());
        }

        return (VCC_VaProfileAssociatedPersonsRS) JSON.deserialize(resp.getBody(), VCC_VaProfileAssociatedPersonsRS.class);
    }
}
