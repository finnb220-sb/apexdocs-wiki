export const mockDuplicateData = [
    { personId: "68924542", facilityName: "Elephant", facilityId: "984" },
    { personId: "89210574", facilityName: "Walrus", facilityId: "984" },
    { personId: "128503910", facilityName: "Honey Badger", facilityId: "984" }
];

export const mockSELECT = [
    {
        name: "Michael Bravo",
        ssn: "000-00-0000",
        dob: "04/15/1978",
        relatedTos: {
            serviceConnected: true,
            combatVeteran: true,
            agentorangeExposure: false,
            ionizingradiationExposure: false,
            southwestasiaConditions: false,
            shipboardhazardandDefence: false,
            mst: false,
            headandneckCancer: false,
            persiangulfExposure: false
        }
    },
    {
        name: "Michael Bravo",
        ssn: "111-11-1111",
        dob: "02/12/1000",
        relatedTos: {
            serviceConnected: false,
            combatVeteran: false,
            agentorangeExposure: false,
            ionizingradiationExposure: true,
            southwestasiaConditions: false,
            shipboardhazardandDefence: true,
            mst: true,
            headandneckCancer: false,
            persiangulfExposure: false
        }
    },
    {
        name: "Michael Bravo",
        ssn: "222-22-2222",
        dob: "12/19/2814",
        relatedTos: {
            serviceConnected: true,
            combatVeteran: true,
            agentorangeExposure: true,
            ionizingradiationExposure: true,
            southwestasiaConditions: true,
            shipboardhazardandDefence: true,
            mst: true,
            headandneckCancer: true,
            persiangulfExposure: true
        }
    }
];
