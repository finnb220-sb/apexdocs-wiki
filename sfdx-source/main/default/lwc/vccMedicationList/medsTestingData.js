const data = {
    sites: [
        {
            results: {
                meds: {
                    developerComment: "//*CATEGORIES:(isADuplicate,expirationOlderThan120,expirationNewerThan120)--------------------------------------------------",
                    total: "32",
                    med: [
                        {
                            developerComment: "//?VA_MED:(expirationNewerThan120)--------------------------------------------------",
                            expires: { value: "3230925" },
                            doses: {
                                dose: [{ schedule: "BID", dose: "300", doseStop: "3201118", route: "PO", noun: "TABLET", unitsPerDose: "1", units: "MG", doseStart: "3201019" }]
                            },
                            vaStatus: { value: "SUSPENDED" },
                            fillsAllowed: { value: "0" },
                            medID: { value: "9546500;O" },
                            pharmacist: { code: "130766", name: "PAYNE,RONALDM" },
                            lastFilled: { value: "3220506" },
                            type: { value: "Prescription" },
                            products: {
                                product: [
                                    {
                                        vaGeneric: { code: "1990", name: "LISINOPRIL", vuid: "4019380" },
                                        code: "1143",
                                        role: "D",
                                        vaProduct: { code: "8118", name: "LISINOPRIL10MGTAB", vuid: "4008593" },
                                        name: "ABACAVIRSULFATE 300MG TAB",
                                        concentration: "10MG",
                                        class: { code: "CV800", name: "ACEINHIBITORS", vuid: "4021577" },
                                        ordItem: {}
                                    }
                                ]
                            },
                            sig: { content: "TAKEONETABLETBYMOUTHTWICEADAYHighBP" },
                            routing: { value: "W" },
                            fillsRemaining: { value: "0" },
                            id: { value: "28024396" },
                            fills: { fill: [{ fillDate: "3201019", fillDaysSupply: "30", fillQuantity: "60", fillRouting: "W" }] },
                            vaType: { value: "O" },
                            ordered: { value: "3201019.095853" },
                            orderingProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            quantity: { value: "60" },
                            orderID: { value: "28024396" },
                            daysSupply: { value: "30" },
                            start: { value: "3220506" },
                            fillCost: { value: "4.02" },
                            form: { value: "TAB" },
                            stop: { value: "3201118" },
                            prescription: { value: "10959904" },
                            name: { value: "LISINOPRILTAB" },
                            location: { code: "5752", name: "ACARDIO/RESEARCH" },
                            facility: { code: "982", name: "CLE13TESTLAB" },
                            currentProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            status: { value: "historical" },
                            ptInstructions: {},
                            IMO: {},
                            parent: {},
                            ivLimit: {}
                        },
                        {
                            developerComment: "//?VA_MED:(expirationNewerThan120)--------------------------------------------------",
                            expires: { value: "3230924" },
                            doses: {
                                dose: [{ schedule: "QD", dose: "10", doseStop: "3211105", route: "PO", noun: "TABLET", unitsPerDose: "1", units: "MG", doseStart: "3210922" }]
                            },
                            vaStatus: { value: "ACTIVE" },
                            fillsAllowed: { value: "5" },
                            medID: { value: "9546674;O" },
                            pharmacist: { code: "520824712", name: "GEDGE,LYDSEI" },
                            lastFilled: { value: "3210922" },
                            type: { value: "Prescription" },
                            products: {
                                product: [
                                    {
                                        vaGeneric: { code: "2788", name: "LORATADINE", vuid: "4020716" },
                                        code: "7246",
                                        role: "D",
                                        vaProduct: { code: "9904", name: "LORATADINE10MGTAB", vuid: "4010303" },
                                        name: "LORATADINE 10MG TAB",
                                        concentration: "10MG",
                                        class: { code: "AH109", name: "ANTIHISTAMINES,OTHER", vuid: "4021520" },
                                        ordItem: {}
                                    }
                                ]
                            },
                            sig: { content: "TAKEONETABLETBYMOUTHEVERYDAY(WITHFOOD)" },
                            routing: { value: "W" },
                            fillsRemaining: { value: "5" },
                            id: { value: "28025312" },
                            fills: { fill: [{ fillDate: "3210922", fillDaysSupply: "60", fillQuantity: "60", fillRouting: "W" }] },
                            vaType: { value: "O" },
                            ordered: { value: "3210922.121042" },
                            orderingProvider: {
                                code: "520824671",
                                service: "BAYPINESTESTLAB",
                                name: "CPRSPROVIDER,EIGHTY",
                                taxonomyCode: "203BX0901N",
                                providerType: "Physicians(M.D.andD.O.)",
                                classification: "Physician/Osteopath",
                                specialization: "Otology&Neurotology"
                            },
                            quantity: { value: "60" },
                            orderID: { value: "28025312" },
                            daysSupply: { value: "60" },
                            start: { value: "3210922" },
                            fillCost: { value: "10.314" },
                            form: { value: "TAB,ORAL" },
                            stop: { value: "3211105" },
                            prescription: { value: "10951172" },
                            name: { value: "LORATADINETAB,ORAL" },
                            location: {},
                            facility: { code: "982", name: "CLE13TESTLAB" },
                            currentProvider: {
                                code: "520824671",
                                service: "BAYPINESTESTLAB",
                                name: "CPRSPROVIDER,EIGHTY",
                                taxonomyCode: "203BX0901N",
                                providerType: "Physicians(M.D.andD.O.)",
                                classification: "Physician/Osteopath",
                                specialization: "Otology&Neurotology"
                            },
                            status: { value: "notactive" },
                            ptInstructions: { content: "(WITHFOOD)" },
                            IMO: {},
                            parent: {},
                            ivLimit: {}
                        },
                        {
                            developerComment: "//?VA_MED:(expirationNewerThan120)--------------------------------------------------",
                            expires: { value: "3230923" },
                            doses: { dose: [{ schedule: "TID", dose: "25", doseStop: "3210927", noun: "TABLET", unitsPerDose: "1", units: "MG", doseStart: "3210922" }] },
                            vaStatus: { value: "DISCONTINUED" },
                            fillsAllowed: { value: "5" },
                            medID: { value: "9546676;O" },
                            pharmacist: { code: "520824712", name: "GEDGE,LYDSEI" },
                            lastFilled: { value: "3210922" },
                            type: { value: "Prescription" },
                            products: {
                                product: [
                                    {
                                        vaGeneric: { code: "280", name: "CORTISONE", vuid: "4017937" },
                                        code: "2777",
                                        role: "D",
                                        vaProduct: { code: "2281", name: "CORTISONEACETATE25MGTAB", vuid: "4002864" },
                                        name: "CORTISONEACETATE 25MG TAB",
                                        concentration: "25MG",
                                        class: { code: "HS051", name: "GLUCOCORTICOIDS", vuid: "4021759" },
                                        ordItem: {}
                                    }
                                ]
                            },
                            sig: { content: "TAKEONETABLETTHREETIMESADAY" },
                            routing: { value: "W" },
                            fillsRemaining: { value: "5" },
                            id: { value: "28025314" },
                            fills: { fill: [{ fillDate: "3210922", fillDaysSupply: "60", fillQuantity: "180", fillRouting: "W" }] },
                            vaType: { value: "O" },
                            ordered: { value: "3210922.121257" },
                            orderingProvider: {
                                code: "520824671",
                                service: "BAYPINESTESTLAB",
                                name: "CPRSPROVIDER,EIGHTY",
                                taxonomyCode: "203BX0901N",
                                providerType: "Physicians(M.D.andD.O.)",
                                classification: "Physician/Osteopath",
                                specialization: "Otology&Neurotology"
                            },
                            quantity: { value: "180" },
                            orderID: { value: "28025314" },
                            daysSupply: { value: "60" },
                            start: { value: "3210922" },
                            fillCost: { value: "42.3" },
                            form: { value: "TAB" },
                            stop: { value: "3210927" },
                            prescription: { value: "10951174" },
                            name: { value: "CORTISONEACETATETAB" },
                            location: {},
                            facility: { code: "982", name: "CLE13TESTLAB" },
                            currentProvider: {
                                code: "520824671",
                                service: "BAYPINESTESTLAB",
                                name: "CPRSPROVIDER,EIGHTY",
                                taxonomyCode: "203BX0901N",
                                providerType: "Physicians(M.D.andD.O.)",
                                classification: "Physician/Osteopath",
                                specialization: "Otology&Neurotology"
                            },
                            status: { value: "notactive" },
                            ptInstructions: {},
                            IMO: {},
                            parent: {},
                            ivLimit: {}
                        },
                        {
                            developerComment: "//?VA_MED:(isADuplicate,expirationNewerThan120)--------------------------------------------------",
                            expires: { value: "3230922" },
                            doses: {
                                dose: [{ schedule: "BID", dose: "10", doseStop: "3201118", route: "PO", noun: "TABLET", unitsPerDose: "1", units: "MG", doseStart: "3201019" }]
                            },
                            vaStatus: { value: "EXPIRED" },
                            fillsAllowed: { value: "0" },
                            medID: { value: "9546500;O" },
                            pharmacist: { code: "130766", name: "PAYNE,RONALDM" },
                            lastFilled: { value: "3220106" },
                            type: { value: "Prescription" },
                            products: {
                                product: [
                                    {
                                        vaGeneric: { code: "1990", name: "LISINOPRIL", vuid: "4019380" },
                                        code: "1143",
                                        role: "D",
                                        vaProduct: { code: "8118", name: "LISINOPRIL10MGTAB", vuid: "4008593" },
                                        name: "ACETAMINOPHEN 160MG/5ML LIQUID",
                                        concentration: "10MG",
                                        class: { code: "CV800", name: "ACEINHIBITORS", vuid: "4021577" },
                                        ordItem: {}
                                    }
                                ]
                            },
                            sig: { content: "TAKEONETABLETBYMOUTHTWICEADAYHighBP" },
                            routing: { value: "W" },
                            fillsRemaining: { value: "0" },
                            id: { value: "280243961" },
                            fills: { fill: [{ fillDate: "3201019", fillDaysSupply: "30", fillQuantity: "60", fillRouting: "W" }] },
                            vaType: { value: "O" },
                            ordered: { value: "3201019.095853" },
                            orderingProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            quantity: { value: "60" },
                            orderID: { value: "280243961" },
                            daysSupply: { value: "30" },
                            start: { value: "3211206" },
                            fillCost: { value: "4.02" },
                            form: { value: "TAB" },
                            stop: { value: "3201118" },
                            prescription: { value: "10959901" },
                            name: { value: "LISINOPRILTAB" },
                            location: { code: "5752", name: "ACARDIO/RESEARCH" },
                            facility: { code: "541GG", name: "AKRONCBOC" },
                            currentProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            status: { value: "historical" },
                            ptInstructions: {},
                            IMO: {},
                            parent: {},
                            ivLimit: {}
                        },
                        {
                            developerComment: "//?VA_MED:(isADuplicate,expirationNewerThan120)--------------------------------------------------",
                            expires: { value: "3230407" },
                            doses: {
                                dose: [{ schedule: "BID", dose: "10", doseStop: "3201118", route: "PO", noun: "TABLET", unitsPerDose: "1", units: "MG", doseStart: "3201019" }]
                            },
                            vaStatus: { value: "ACTIVE" },
                            fillsAllowed: { value: "0" },
                            medID: { value: "9546500;O" },
                            pharmacist: { code: "130766", name: "PAYNE,RONALDM" },
                            lastFilled: { value: "3220602" },
                            type: { value: "Prescription" },
                            products: {
                                product: [
                                    {
                                        vaGeneric: { code: "1990", name: "LISINOPRIL", vuid: "4019380" },
                                        code: "1143",
                                        role: "D",
                                        vaProduct: { code: "8118", name: "LISINOPRIL10MGTAB", vuid: "4008593" },
                                        name: "ACETAMINOPHEN 160MG/5ML LIQUID",
                                        concentration: "10MG",
                                        class: { code: "CV800", name: "ACEINHIBITORS", vuid: "4021577" },
                                        ordItem: {}
                                    }
                                ]
                            },
                            sig: { content: "TAKEONETABLETBYMOUTHTWICEADAYHighBP" },
                            routing: { value: "W" },
                            fillsRemaining: { value: "0" },
                            id: { value: "280243962" },
                            fills: { fill: [{ fillDate: "3201019", fillDaysSupply: "30", fillQuantity: "60", fillRouting: "W" }] },
                            vaType: { value: "O" },
                            ordered: { value: "3201019.095853" },
                            orderingProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            quantity: { value: "60" },
                            orderID: { value: "280243962" },
                            daysSupply: { value: "30" },
                            start: { value: "3220306" },
                            fillCost: { value: "4.02" },
                            form: { value: "TAB" },
                            stop: { value: "3201118" },
                            prescription: { value: "10959911" },
                            name: { value: "LISINOPRILTAB" },
                            location: { code: "5752", name: "ACARDIO/RESEARCH" },
                            facility: { code: "541GG", name: "AKRONCBOC" },
                            currentProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            status: { value: "historical" },
                            ptInstructions: {},
                            IMO: {},
                            parent: {},
                            ivLimit: {}
                        },
                        {
                            developerComment: "//?VA_MED:(expirationNewerThan120)--------------------------------------------------",
                            expires: { value: "3230921" },
                            doses: {
                                dose: [{ schedule: "BID", dose: "10", doseStop: "3201118", route: "PO", noun: "TABLET", unitsPerDose: "1", units: "MG", doseStart: "3201019" }]
                            },
                            vaStatus: { value: "ACTIVE" },
                            fillsAllowed: { value: "0" },
                            medID: { value: "9546500;O" },
                            pharmacist: { code: "130766", name: "PAYNE,RONALDM" },
                            lastFilled: { value: "3220410" },
                            type: { value: "Prescription" },
                            products: {
                                product: [
                                    {
                                        vaGeneric: { code: "1990", name: "LISINOPRIL", vuid: "4019380" },
                                        code: "1143",
                                        role: "D",
                                        vaProduct: { code: "8118", name: "LISINOPRIL10MGTAB", vuid: "4008593" },
                                        name: "AZITHROMYCIN 250MGTAB 6/CARD",
                                        concentration: "10MG",
                                        class: { code: "CV800", name: "ACEINHIBITORS", vuid: "4021577" },
                                        ordItem: {}
                                    }
                                ]
                            },
                            sig: { content: "TAKEONETABLETBYMOUTHTWICEADAYHighBP" },
                            routing: { value: "W" },
                            fillsRemaining: { value: "0" },
                            id: { value: "280243964" },
                            fills: { fill: [{ fillDate: "3201019", fillDaysSupply: "30", fillQuantity: "60", fillRouting: "W" }] },
                            vaType: { value: "O" },
                            ordered: { value: "3201019.095853" },
                            orderingProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            quantity: { value: "60" },
                            orderID: { value: "280243964" },
                            daysSupply: { value: "30" },
                            start: { value: "3220406" },
                            fillCost: { value: "4.02" },
                            form: { value: "TAB" },
                            stop: { value: "3201118" },
                            prescription: { value: "10959903" },
                            name: { value: "LISINOPRILTAB" },
                            location: { code: "5752", name: "ACARDIO/RESEARCH" },
                            facility: { code: "541GG", name: "AKRONCBOC" },
                            currentProvider: { code: "130766", service: "BAYPINESTESTLAB", name: "PAYNE,RONALDM", email: "ronald.payne@va.gov" },
                            status: { value: "historical" },
                            ptInstructions: {},
                            IMO: {},
                            parent: {},
                            ivLimit: {}
                        }
                    ]
                }
            }
        }
    ]
};
