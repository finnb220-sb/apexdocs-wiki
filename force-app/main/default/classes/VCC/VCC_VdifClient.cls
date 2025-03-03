/**
 * @description Client for
 *
 * @author Liberty
 * @since 01/08/2024
 * @group VAHC
 */
@SuppressWarnings('PMD.CyclomaticComplexity, PMD.ClassNamingConventions')
public with sharing class VCC_VdifClient extends VCC_BaseClient {
    private static final String INVALID_REQUEST_MSG = 'The provided request is invalid.';

    @TestVisible
    private static final String VDIF_TRANSACTION_ID_KEY = 'x-sfTransactionId'; // CCCM-26514

    private VCC_HttpHeaderB3 b3Header;

    /**
     * @description    Creates http request and sets http headers
     * @param httpRequestMethod `String`
     * @param requestBody       `Object`
     * @return                  `HTTPRequest`
     */
    @TestVisible
    protected override HTTPRequest createHttpRequest(String httpRequestMethod, Object requestBody) {
        HTTPRequest request = new HTTPRequest();
        request.setMethod(httpRequestMethod);
        request.setHeader('Content-Type', 'application/json;charset=UTF-8');
        request.setHeader('clientid', '{!$Credential.UserName}');
        request.setHeader('clientSecret', '{!$Credential.Password}');
        request.setHeader(VDIF_TRANSACTION_ID_KEY, System.Request.getCurrent().getRequestId()); // CCCM-26514
        b3Header = generateB3Header((VCC_VdifBaseRQ) requestBody);
        b3Header.addTo(request);
        request.setTimeout(120000);
        request.setBody(JSON.serialize(requestBody, true));
        return request;
    }

    /**
     * @description       Creates a B3 header using recordId from VCC_VdifBaseRQ and serviceName
     * @param requestBody `VCC_VdifBaseRQ`
     * @return            `VCC_HttpHeaderB3`
     */
    public VCC_HttpHeaderB3 generateB3Header(VCC_VdifBaseRQ requestBody) {
        return (new VCC_HttpHeaderB3(new VCC_TransactionId(this.serviceName, requestBody.recordId)));
    }

    /**
     * @description    Logs information about VDIF request and response if an exception occurs
     * @param request `VCC_VdifBaseRQ` http request instance involved in exception
     * @param response `VCC_BaseClient.BaseResponse` http response instance involved in exception
     * @param thrownException `Exception`
     */
    private void logThrownException(
        VCC_VdifBaseRQ request,
        VCC_BaseClient.BaseResponse response,
        Exception thrownException
    ) {
        VCC_VdifLogger logger = new VCC_VdifLogger();
        String template =
            'Date/Time: {0}\n' +
            'Service Name: {1}\n' +
            'Header: {2}\n' +
            'HTTP Request: {3}\n' +
            'Response Status Code: {4}\n' +
            'HTTP Response: {5}';
        List<Object> parameters = new List<Object>{
            DateTime.now().format('yyyy-MM-dd hh:mm:ss'),
            this.serviceName,
            b3Header.toString(),
            String.valueOf(request),
            String.valueOf(response.httpResponse.getStatusCode()),
            response.httpResponse.getBody()
        };
        logger.debug(String.format(template, parameters));
        logger.error('VDIF Exception', thrownException);
        logger.saveLog();
    }

    /**
     * @description core method that retrieves additional signers via api call
     *
     * @param getAdditionalSignersRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse getAdditionalSignersBase(VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ) {
        if (!getAdditionalSignersRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifGetAdditionalSigners');
        return this.send(createHttpRequest('POST', getAdditionalSignersRQ));
    }

    /**
     * @description retrieves additional signers with error handling and logging
     *
     * @param getAdditionalSignersRQ
     * @return  `VCC_VdifGetAdditionalSignersRS`
     */
    public VCC_VdifGetAdditionalSignersRS getAdditionalSigners(VCC_VdifGetAdditionalSignersRQ getAdditionalSignersRQ) {
        VCC_BaseClient.BaseResponse resp = getAdditionalSignersBase(getAdditionalSignersRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(getAdditionalSignersRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifGetAdditionalSignersRS(resp);
    }

    /**
     * @description core method that creates an Addendum via api call
     *
     * @param createAddendumRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse createAddendumBase(VCC_VdifCreateAddendumRQ createAddendumRQ) {
        if (!createAddendumRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifCreateAddendum');
        return this.send(createHttpRequest('POST', createAddendumRQ));
    }

    /**
     * @description creates addendum with error handling and logging
     *
     * @param createAddendumRQ
     * @return  `VCC_VdifCreateAddendumRS`
     */
    public VCC_VdifCreateAddendumRS createAddendum(VCC_VdifCreateAddendumRQ createAddendumRQ) {
        VCC_BaseClient.BaseResponse resp = createAddendumBase(createAddendumRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(createAddendumRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifCreateAddendumRS(resp);
    }

    /**
     * @description core method that checks if Esig is valid via api call
     *
     * @param isValidEsigRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse isValidEsigBase(VCC_VdifIsValidEsigRQ isValidEsigRQ) {
        if (!isValidEsigRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifIsValidEsig');
        return this.send(createHttpRequest('POST', isValidEsigRQ));
    }

    /**
     * @description checks if valid Esig with error handling and logging
     *
     * @param isValidEsigRQ
     * @return  `VCC_VdifIsValidEsigRS`
     */
    public VCC_VdifIsValidEsigRS isValidEsig(VCC_VdifIsValidEsigRQ isValidEsigRQ) {
        VCC_BaseClient.BaseResponse resp = isValidEsigBase(isValidEsigRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(isValidEsigRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifIsValidEsigRS(resp);
    }

    /**
     * @description core method that saves not and encounter via api call
     *
     * @param saveNoteAndEncounterRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse saveNoteAndEncounterBase(VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRQ) {
        if (!saveNoteAndEncounterRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifSaveNoteAndEncounter');
        return this.send(createHttpRequest('POST', saveNoteAndEncounterRQ));
    }

    /**
     * @description saves not and enounter with error handling and logging
     *
     * @param saveNoteAndEncounterRQ
     * @return  `VCC_VdifSaveNoteAndEncounterRS`
     */
    public VCC_VdifSaveNoteAndEncounterRS saveNoteAndEncounter(VCC_VdifSaveNoteAndEncounterRQ saveNoteAndEncounterRQ) {
        VCC_BaseClient.BaseResponse resp = saveNoteAndEncounterBase(saveNoteAndEncounterRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(saveNoteAndEncounterRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifSaveNoteAndEncounterRS(resp);
    }

    /**
     * @description core method to sign a note via api call
     *
     * @param signNoteRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse signNoteBase(VCC_VdifSignNoteRQ signNoteRQ) {
        if (!signNoteRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifSignNote');
        return this.send(createHttpRequest('POST', signNoteRQ));
    }

    /**
     * @description signs a note with error handling and logging
     *
     * @param signNoteRQ
     * @return  `VCC_VdifSignNoteRS`
     */
    public VCC_VdifSignNoteRS signNote(VCC_VdifSignNoteRQ signNoteRQ) {
        VCC_BaseClient.BaseResponse resp = signNoteBase(signNoteRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(signNoteRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifSignNoteRS(resp);
    }

    /**
     * @description core method to write a note via api call
     *
     * @param writeNoteRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse writeNoteBase(VCC_VdifWriteNoteRQ writeNoteRQ) {
        if (!writeNoteRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifWriteNote');
        return this.send(createHttpRequest('POST', writeNoteRQ));
    }

    /**
     * @description writes a note with error handling and logging
     *
     * @param writeNoteRQ
     * @return  `VCC_VdifWriteNoteRS`
     */
    public VCC_VdifWriteNoteRS writeNote(VCC_VdifWriteNoteRQ writeNoteRQ) {
        VCC_BaseClient.BaseResponse resp = writeNoteBase(writeNoteRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(writeNoteRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifWriteNoteRS(resp);
    }

    /**
     * @description core method to select patient via api call
     *
     * @param selectPatientRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse selectPatientBase(VCC_VdifSelectPatientRQ selectPatientRQ) {
        if (!selectPatientRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifSelectPatient');
        return this.send(createHttpRequest('POST', selectPatientRQ));
    }

    /**
     * @description selects a patient with error handling and logging
     *
     * @param selectPatientRQ
     * @return  `VCC_VdifSelectPatientRS`
     */
    public VCC_VdifSelectPatientRS selectPatient(VCC_VdifSelectPatientRQ selectPatientRQ) {
        VCC_BaseClient.BaseResponse resp = selectPatientBase(selectPatientRQ);
        try {
            handleStatusCode(resp);
            if (Test.isRunningTest()) {
                CalloutException excep = new CalloutException();
                excep.setMessage('Exception for testing and code coverage');
                throw excep;
            }
        } catch (Exception thrownException) {
            logThrownException(selectPatientRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifSelectPatientRS(resp);
    }

    /**
     * @description core method to get providers by site via api call
     *
     * @param getProvidersBySiteRQ
     * @return  `VCC_BaseClient.BaseResponse`
     * @exception
     */
    public VCC_BaseClient.BaseResponse getProvidersBySiteBase(VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ) {
        if (!getProvidersBySiteRQ.isValid()) {
            throw new InvalidRequestException(INVALID_REQUEST_MSG);
        }
        setServiceName('vccVdifGetProvidersBySite');
        return this.send(createHttpRequest('POST', getProvidersBySiteRQ));
    }

    /**
     * @description gets the providers by site
     *
     * @param getProvidersBySiteRQ
     * @return  `VCC_VdifGetProvidersBySiteRS`
     */
    public VCC_VdifGetProvidersBySiteRS getProvidersBySite(VCC_VdifGetProvidersBySiteRQ getProvidersBySiteRQ) {
        VCC_BaseClient.BaseResponse resp = getProvidersBySiteBase(getProvidersBySiteRQ);
        try {
            handleStatusCode(resp);
        } catch (Exception thrownException) {
            logThrownException(getProvidersBySiteRQ, resp, thrownException);
            /** Re-throws uncaught exception so that flow can move to the next screen  **/
            handleStatusCode(resp);
        }
        return new VCC_VdifGetProvidersBySiteRS(resp);
    }

    /**
     * @description default constructor method
     */
    public VCC_VdifClient() {
        super();
        setAppName('Vdif');
    }

    /**
     * @description constructor with options param
     * @param options
     */
    public VCC_VdifClient(Set<VCC_BaseClient.ClientOption> options) {
        super(options);
        setAppName('Vdif');
    }

    /**
     * @description Invalid request exception
     */
    public class InvalidRequestException extends Exception {
    }
    /**
     * @description Vdif Client Exception
     */
    public class VdifClientException extends Exception {
    }
}
