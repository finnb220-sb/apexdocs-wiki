/**
 * @description Vista Data Service Model
 *
 * @author VAHC Development Team
 * @since 7/30/2023
 */
public with sharing class VCC_VISTADataService {
    /**
     * @description constructor with birdge request argument
     *
     * @param rq
     * @return  `VCC_VISTAModel`
     */
    public static VCC_VISTAModel getDemographicsByVista(VCC_BridgRequest rq) {
        return new VCC_VISTAModel(new VCC_HDRClient().getDemographicsBridg(rq), rq);
    }
}
