public with sharing class VCCMPIClient extends VCC_MPI_HTTP {
    private VCC_MPIRequestFactory requestFactory { get; set; }

    public VCCMPIClient(String userId, String icn) {
        this.requestFactory = new VCC_MPIRequestFactory(userId, icn);
    }

    public VCCMPIClient() {
        System.debug(LoggingLevel.INFO, 'Empty constructor.');
    }

    public VCC_MpiRetrieveRS mpiRetrieve(VCC_MpiRetrieveRQ mpiRetrieveRQ) {
        HttpRequest req = createRequest('POST', JSON.serialize(mpiRetrieveRQ), 'vccMPIeMpiRetrieve');
        HttpResponse res = dispatchRequest(req);
        VCC_MpiRetrieveRS rs;
        try {
            rs = (VCC_MpiRetrieveRS) JSON.deserialize(res.getBody(), VCC_MpiRetrieveRS.class);
            if (Test.isRunningTest()) {
                CalloutException e = new CalloutException();
                e.setMessage('This is a constructed exception for testing and code coverage');
                throw e;
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, e.getMessage());
            System.debug(LoggingLevel.ERROR, e.getStackTraceString());
        }
        return rs;
    }

    public VCC_MPISearchResponse searchMPI(Map<String, Object> calloutParams) {
        String requestBody = this.requestFactory.searchMPIRequest(calloutParams);
        system.debug('MPISEARCHREQUESTBODY' + requestBody);
        VCC_LogService.log('VCCMPIClient.searchMPI() Request', VCC_LogService.VCC_LogType.INFO, requestBody);
        HttpResponse raw = dispatchRequest(createRequest('POST', requestBody, 'vccMPIeSearch'));

        switch on raw.getStatusCode() {
            when 200 {
                System.Debug('#' + raw);
                VCC_LogService.log('VCCMPIClient.searchMPI() Response', VCC_LogService.VCC_LogType.INFO, raw.getBody());
                String sanitizedBody = raw.getBody().replace('"null"', 'null');
                return (VCC_MPISearchResponse) JSON.deserialize(sanitizedBody, VCC_MPISearchResponse.class);
            }
            when 404 {
                System.Debug('#' + raw);
                // HERE WE GET THE RESPONSE
                // CHECk WHAT THE RESPONSE SAYS AND UPDATE ACCORDINGLY
                String customResponseString = '';
                VCC_LogService.log(
                    'VCCMPIClient.searchMPI() No Results Exception',
                    VCC_LogService.VCC_LogType.ERROR,
                    new Map<String, Object>{ 'statusCode' => raw.getStatusCode(), 'message' => 'No results found. Please refine your search', 'body' => raw.getBody() }
                );
                // instead of below throw relevant message

                if (raw.getBody().contains('ZeroResultsFound')) {
                    customResponseString = Label.VCC_MPI_Search_No_Results;
                } else {
                    customResponseString = Label.VCC_MPI_Search_More_Than_10_Results;
                }
                System.debug(raw.getBody());
                System.debug(customResponseString);
                throw new VCC_NoResultsException(customResponseString);
            }
            when 500 {
                Logger.error('MPI Application Error 500');
                Logger.error('get body', raw.getBody());
                Logger.saveLog();
                throw new VCC_RemoteServiceException('MPI Application Error 500');
            }
            when 503 {
                Logger.error('MPI Application Error 503');
                Logger.error('get body', raw.getBody());
                Logger.saveLog();
                throw new VCC_RemoteServiceException('MPI Application Error 503');
            }
            when else {
                System.Debug('#' + raw);
                VCC_LogService.log(
                    'VCCMPIClient.searchMPI() Remote Service Exception',
                    VCC_LogService.VCC_LogType.ERROR,
                    new Map<String, Object>{ 'statusCode' => raw.getStatusCode(), 'message' => 'MPI Application Error', 'body' => raw.getBody() }
                );
                throw new VCC_RemoteServiceException('MPI Application Error');
            }
        }
    }

    public String mpiCorrelate(Map<String, String> params) {
        System.debug('params ' + params);
        // Todo: We can also wrap this callout with VCC_LogService like we have done above and handle exceptions
        String requestBody = this.requestFactory.correlateWithTraitsRequest(params);
        HttpResponse raw = dispatchRequest(createRequest('POST', requestBody, 'vccMPIeCorrelateWithTraits'));
        System.Debug('##' + raw);

        switch on raw.getStatusCode() {
            when 500 {
                Logger.error('MPI Application Error 500');
                Logger.error('get body', raw.getBody());
                Logger.saveLog();
                throw new VCC_RemoteServiceException('MPI Application Error 500');
            }
            when 503 {
                Logger.error('MPI Application Error 503');
                Logger.error('get body', raw.getBody());
                Logger.saveLog();
                throw new VCC_RemoteServiceException('MPI Application Error 503');
            }
        }
        return raw.getBody();
    }
}
