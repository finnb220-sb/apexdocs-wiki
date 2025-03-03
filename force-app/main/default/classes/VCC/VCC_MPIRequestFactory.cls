public with sharing class VCC_MPIRequestFactory {
    String icn;
    String userId;

    public String searchMPIRequest(Map<String, Object> calloutParams) {
        return JSON.serialize(
            new Map<Object, Object>{
                'userId' => this.userId,
                'firstName' => calloutParams.get('firstName'),
                'middleName' => calloutParams.get('middleName'),
                'lastName' => calloutParams.get('lastName'),
                'ssn' => calloutParams.get('ssn'),
                'dob' => calloutParams.get('dob'),
                'retrieveRelationships' => false,
                'datasets' => new List<String>{ 'VA_PROFILE' }
            }
        );
    }

    public String correlateWithTraitsRequest(Map<String, String> params) {
        return JSON.serialize(
            new Map<Object, Object>{
                'userId' => this.userId,
                'firstName' => params.get('firstName'),
                'middleName' => params.get('middleName'),
                'lastName' => params.get('lastName'),
                'icn' => params.get('icn'),
                'salesforceId' => params.get('salesforceId')
            }
        );
    }

    public VCC_MPIRequestFactory(String icn, String userId) {
        if (userId == null) {
            throw new ParameterException('Missing required parameters');
        }
        this.icn = icn;
        this.userId = userId;
    }

    public class ParameterException extends Exception {
    }
}
