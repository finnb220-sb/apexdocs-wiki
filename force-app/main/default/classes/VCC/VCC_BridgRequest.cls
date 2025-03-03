public virtual with sharing class VCC_BridgRequest {
    // TODO: move this to custom md
    public class VCC_BridgRequestException extends Exception {
    }

    private final STRING assigningAuthority = 'USVHA';
    public String assigningFacility;
    public String ien;
    public String nationalId;

    public virtual Boolean isValid() {
        return (nationalId != null) || (assigningFacility != null && ien != null);
    }

    public VCC_BridgRequest(String nationalId) {
        this.nationalId = nationalId;

        if (!this.isValid()) {
            throw new VCC_BridgRequestException('Request is invalid');
        }
    }

    public VCC_BridgRequest(String assigningFacility, String ien) {
        this.assigningFacility = assigningFacility;
        this.ien = ien;

        if (!this.isValid()) {
            throw new VCC_BridgRequestException('Request is invalid');
        }
    }

    public VCC_BridgRequest() {
        Logger.debug('VCC Bridg Request Default Constructor');
    }

    public String stringify() {
        return JSON.serialize(this);
    }
}
