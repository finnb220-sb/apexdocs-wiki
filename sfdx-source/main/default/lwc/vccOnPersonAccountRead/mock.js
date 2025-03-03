export const mockData = {
    vetsV3: [
        {
            mviResult: 'FOUND',
            eeResult: 'FOUND',
            emisResult: 'NO_REQUEST',
            vets360Result: 'FOUND',
            bgsResult: 'NO_REQUEST',
            mvi: {
                icn: '1011219533V056034',
                salesforceId: 'null',
                corpId: 'null',
                edipi: 'null',
                brlsFilenumber: 'null',
                mviIipt: 'null',
                mviToken: 'WSDOC2107291942062720835451145',
                personType: 'null',
                vet360Id: '1269384',
                prefixName: 'null',
                suffixName: 'null',
                firstName: 'STAGEONE',
                lastName: 'WISDEN',
                middleName: 'null',
                mothersMaidenName: 'BANNER',
                cityOfBirth: 'ALBANY',
                stateOfBirth: 'NY',
                dob: '19620515',
                dod: 'null',
                ssn: '316552291',
                gender: 'M',
                queryMatchObservation: 'null',
                address: {
                    streetAddress: '18 BRIAR AVE',
                    streetAddress2: 'null',
                    streetAddress3: 'null',
                    city: 'ALBANY',
                    state: 'NY',
                    postalCode: '12203-2604',
                    country: 'USA',
                    addressTypeCode: 'PHYS'
                },
                phoneNumber: [],
                medicalCenterFacilities: [
                    {
                        facilityId: '988',
                        personId: '156418'
                    }
                ],
                correlatedIds: [
                    {
                        shortId: '1011219533V056034',
                        longId: '1011219533V056034^NI^200M^USVHA^P',
                        idType: 'ICN_ID',
                        idStatus: 'ACTIVE'
                    },
                    {
                        shortId: '0000001011219533V056034000000',
                        longId: '0000001011219533V056034000000^PI^200ESR^USVHA^A',
                        idType: 'OTHER',
                        idStatus: 'ACTIVE'
                    },
                    {
                        shortId: '156418',
                        longId: '156418^PI^988^USVHA^A',
                        idType: 'VHA_CORRELATED_SYSTEMS_ID',
                        idStatus: 'ACTIVE'
                    },
                    {
                        shortId: '1206211211247900441827131',
                        longId: '1206211211247900441827131^PI^200SSA^USSSA^A',
                        idType: 'OTHER',
                        idStatus: 'ACTIVE'
                    },
                    {
                        shortId: '1269384',
                        longId: '1269384^PI^200VETS^USDVA^A',
                        idType: 'OTHER',
                        idStatus: 'ACTIVE'
                    }
                ],
                relationships: []
            },
            ee: {
                eeVeteranStatus: 'true',
                serviceConnectedPercentage: 'null',
                eligibleForMedicaid: 'null',
                priorityGroup: 'Group 8',
                monetaryBenefits: [
                    {
                        monetaryBenefitIndicator: 'false',
                        monetaryBenefitType: 'Aid And Attendance',
                        monetaryBenefitReportDate: '20081022'
                    },
                    {
                        monetaryBenefitIndicator: 'false',
                        monetaryBenefitType: 'VA Pension',
                        monetaryBenefitReportDate: '20081022'
                    },
                    {
                        monetaryBenefitIndicator: 'false',
                        monetaryBenefitType: 'Housebound',
                        monetaryBenefitReportDate: '20081022'
                    },
                    {
                        monetaryBenefitIndicator: 'false',
                        monetaryBenefitType: 'Disability Compensation',
                        monetaryBenefitReportDate: '20081022'
                    }
                ],
                ratedDisabilities: [],
                serviceBranches: [],
                eeExtendedResponse: {
                    associations: [
                        {
                            address: {},
                            alternatePhone: 'null',
                            contactType: 'Primary Next of Kin',
                            familyName: 'WISDEN',
                            givenName: 'SISTER',
                            lastUpdateDate: '20081022',
                            middleName: 'null',
                            organizationName: 'null',
                            prefix: 'null',
                            primaryPhone: 'null',
                            relationship: 'SISTER',
                            suffix: 'null'
                        }
                    ],
                    demographics: {
                        preferredFacility: '988 - DAYT20',
                        assignmentDate: '20081022',
                        unassignmentDate: 'null',
                        preferredFacilities: [
                            {
                                preferredFacility: '988 - DAYT20',
                                assignmentDate: '20081022',
                                unassignmentDate: 'null'
                            }
                        ]
                    },
                    eligibilityVerification: {
                        eligibilityStatus: 'VERIFIED',
                        eligibilityStatusDate: '20081022',
                        verificationMethod: 'VAMC'
                    },
                    enrollmentDetermination: {
                        effectiveDate: '20161228',
                        eligibleForMedicaid: 'null',
                        endDate: 'null',
                        enrollmentDate: '20081022',
                        enrollmentStatus: 'Verified',
                        enrollmentCategoryName: 'Enrolled',
                        monetaryBenefits: [
                            {
                                monetaryBenefitIndicator: 'false',
                                monetaryBenefitType: 'Aid And Attendance',
                                monetaryBenefitReportDate: '20081022'
                            },
                            {
                                monetaryBenefitIndicator: 'false',
                                monetaryBenefitType: 'VA Pension',
                                monetaryBenefitReportDate: '20081022'
                            },
                            {
                                monetaryBenefitIndicator: 'false',
                                monetaryBenefitType: 'Housebound',
                                monetaryBenefitReportDate: '20081022'
                            },
                            {
                                monetaryBenefitIndicator: 'false',
                                monetaryBenefitType: 'Disability Compensation',
                                monetaryBenefitReportDate: '20081022'
                            }
                        ],
                        otherEligibilities: [],
                        primaryEligibility: {
                            indicator: 'P',
                            type: 'NSC',
                            eligibilityReportDate: '20081022'
                        },
                        priorityGroup: 'Group 8',
                        prioritySubGroup: 'c',
                        secondaryEligibilities: [],
                        serviceConnectionAward: {
                            awardDate: 'null',
                            combinedServiceConnectedPercentageEffectiveDate: 'null',
                            permanentAndTotal: 'false',
                            permanentAndTotalEffectiveDate: 'null',
                            serviceConnectedIndicator: 'false',
                            serviceConnectedPercentage: 'null',
                            unemployable: 'false',
                            scReportDate: '20081022'
                        },
                        veteran: 'true'
                    },
                    insuranceList: [],
                    relations: [],
                    person: {},
                    healthBenefitPlans: [
                        {
                            planName: 'Veteran Full Med Benefits Tx and Rx Copay Req 8',
                            effectiveDate: '20190904',
                            description: 'null',
                            planCode: 'null',
                            coverageCode: 'null'
                        },
                        {
                            planName: 'Veteran Plan - Veterans Choice Basic',
                            effectiveDate: '20190102',
                            description: 'null',
                            planCode: 'null',
                            coverageCode: 'null'
                        }
                    ]
                }
            },
            vaProfileV2: {
                vaProfileContactInfo: {
                    createDate: '2018-04-20T17:15:05Z',
                    sourceDate: '2018-04-20T17:15:05Z',
                    sourceSystem: 'Vet360',
                    sourceSystemUser: 'Seed Admin',
                    txAuditId: 'DATA SEEDING',
                    updateDate: '2018-04-20T17:15:05Z',
                    vet360Id: 1269384
                    // "addresses": [
                    //     {
                    //         "addressId": 1984062,
                    //         "addressLine1": "18 Briar Ave",
                    //         "addressPurposeOfUse": "RESIDENCE",
                    //         "addressType": "Domestic",
                    //         "cityName": "Albany",
                    //         "confidenceScore": "100",
                    //         "countryCodeFips": "US",
                    //         "countryCodeIso2": "US",
                    //         "countryCodeIso3": "USA",
                    //         "countryName": "United States",
                    //         "createDate": "2018-04-20T17:19:57Z",
                    //         "effectiveStartDate": "2012-02-02T11:10:11Z",
                    //         "geocodeDate": "2018-04-04T18:08:48Z",
                    //         "geocodePrecision": "5",
                    //         "latitude": "42.6675",
                    //         "longitude": "-73.8202",
                    //         "originatingSourceSystem": "VAMC",
                    //         "sourceDate": "2012-02-02T11:10:11Z",
                    //         "sourceSystem": "VHAES",
                    //         "sourceSystemUser": "482073",
                    //         "stateCode": "NY",
                    //         "txAuditId": "DATA SEEDING",
                    //         "updateDate": "2018-04-20T17:19:57Z",
                    //         "vet360Id": 1269384,
                    //         "zipCode4": "2604",
                    //         "zipCode5": "12203"
                    //     },
                    //     {
                    //         "addressId": 2852364,
                    //         "addressLine1": "18 Briar Ave",
                    //         "addressPurposeOfUse": "CORRESPONDENCE",
                    //         "addressType": "Domestic",
                    //         "cityName": "Albany",
                    //         "confidenceScore": "100",
                    //         "countryCodeFips": "US",
                    //         "countryCodeIso2": "US",
                    //         "countryCodeIso3": "USA",
                    //         "countryName": "United States",
                    //         "createDate": "2018-04-20T17:19:57Z",
                    //         "effectiveStartDate": "2017-12-07T20:12:08Z",
                    //         "geocodeDate": "2018-04-04T18:19:20Z",
                    //         "geocodePrecision": "5",
                    //         "latitude": "42.6675",
                    //         "longitude": "-73.8202",
                    //         "originatingSourceSystem": "VAMC",
                    //         "sourceDate": "2017-12-07T20:12:08Z",
                    //         "sourceSystem": "VHAES",
                    //         "sourceSystemUser": "ECISService",
                    //         "stateCode": "NY",
                    //         "txAuditId": "DATA SEEDING",
                    //         "updateDate": "2018-04-20T17:19:57Z",
                    //         "vet360Id": 1269384,
                    //         "zipCode4": "2604",
                    //         "zipCode5": "12203"
                    //     }
                    // ]
                }
                // "vaProfilePersonAttributes": {
                //     "activePrescriptionBio": {
                //         "activePrescriptionIndicator": false
                //     }
                // },
                // "vaProfileIdentity": {
                //     "sensitivityInformation": {
                //         "sensitivityFlag": false`
                //     }
                // }
            }
        }
    ]
};
