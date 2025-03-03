/**
 * @description VCC Order Controller class
 *
 * @author Booz Allen
 *
 * @see VTC_PatientService Class responsible for handshaking between repo and VTC
 */
public with sharing class VCC_OrderController {
    @TestVisible
    private static final String APPLICATION = 'VAHC';

    @TestVisible
    private static final String RETRY_CMD = 'RETRY_CMD';

    @TestVisible
    private static final String NO_RETRY_CMD = 'NO_RETRY_CMD';

    /**
     * @description instantiation of orders repo
     */
    @TestVisible
    private static VCR_OrderRepo orderRepo {
        get {
            if (orderRepo == null) {
                orderRepo = new VCR_OrderRepo();
            }
            return orderRepo;
        }
        set;
    }

    /**
     * @description instantiation of health data repo
     */
    @TestVisible
    private static VCR_HealthDataRepo healthDataRepo {
        get {
            if (healthDataRepo == null) {
                healthDataRepo = new VCR_HealthDataRepo('orders');
            }
            return healthDataRepo;
        }
        set;
    }

    /**
     * @description - Get orders from VTC
     *
     * @param args  - Arguments map for orders fetch from VTC
     *
     * @return VTC_DataModel - Data model containing order data
     */
    @AuraEnabled(cacheable=true)
    public static VTC_DataModel fetchOrders(Map<String, Object> args) {
        args.put('application', APPLICATION);
        try {
            return orderRepo.fetchOrdersWithPharmacy(args);
        } catch (Exception excep) {
            Logger.error('Fetch orders came back with an exception: ', excep);
            Map<String, String> cmdMap = new Map<String, String>{
                'VTC_LimitException' => RETRY_CMD,
                'VTC_CalloutException' => RETRY_CMD,
                'VTC_TimeoutException' => RETRY_CMD
            };
            throw VCC_ExceptionUtils.createAuraHandledException(excep, cmdMap, NO_RETRY_CMD);
        } finally {
            Logger.saveLog();
        }
    }

    /**
     * @description - Get orders from VTC and use new model to additional fields
     *
     * @param args  - Arguments map for orders fetch from VTC
     *
     * @return VTC_DataModel - Data model containing order data and new fields
     */
    @AuraEnabled(cacheable=true)
    public static VTC_DataModel getOrders(Map<String, Object> args) {
        VTC_DataModel results = fetchOrders(args);
        for (VTC_Site site : results.sites) {
            List<VCC_Order> transformedOrders = new List<VCC_Order>();
            for (VTC_Record record : site.records) {
                transformedOrders.add(
                    (VCC_OrderController.VCC_Order) JSON.deserialize(
                        JSON.serialize(record),
                        VCC_OrderController.VCC_Order.class
                    )
                );
            }
            site.records = transformedOrders;
        }
        return results;
    }

    @AuraEnabled(Cacheable=true)
    /**
     * @description - Gets Patient birthyear, and workstream settings, primarily used for the "load more" functionality of this HDR LWC
     * @param icn - ICN to query org against
     * @return VCR_HealthDataRepo.Model - Returns patient birthyear, and workstream settings
     */
    public static VCR_HealthDataRepo.Model fetchHealthDataConfig(String icn) {
        healthDataRepo.setPatientByICN(icn);
        return healthDataRepo.fetchHealthDataConfig();
    }

    /**
     * @description This is a custom Order that has additional fields for the vccOrderList lwc
     */
    public class VCC_Order extends VTC_Order {
        @AuraEnabled
        /**
         * @description unnesting provider name
         */
        public String providerName {
            get {
                return this.provider?.name;
            }
        }
        @AuraEnabled
        /**
         * @description stat date as string format in MM/dd/yyyy
         */
        public String startDateFormatted {
            get {
                return this.start?.formatGmt('MM/dd/yyyy');
            }
        }
        @AuraEnabled
        /**
         * @description stat date as string format in yyyy-MM-dd
         */
        public String startDateStr {
            get {
                return this.start?.formatGmt('yyyy-MM-dd');
            }
        }
        @AuraEnabled
        /**
         * @description signed date as string format in MM/dd/yyyy
         */
        public String signedDateFormatted {
            get {
                return this.signed?.formatGmt('MM/dd/yyyy');
            }
        }
        @AuraEnabled
        /**
         * @description signed date as string format in yyyy-MM-dd
         */
        public String signedDateStr {
            get {
                return this.signed?.formatGmt('yyyy-MM-dd');
            }
        }
        @AuraEnabled
        /**
         * @description released date as string format in MM/dd/yyyy
         */
        public String releasedDateFormatted {
            get {
                return this.released?.formatGmt('MM/dd/yyyy');
            }
        }
    }
}
