export const signedMock = JSON.stringify(
    JSON.stringify({
        additionalSignersStatus: {
            templateId: 'TiuAdditionalSignersStatusRead',
            requestId: '5df25e94-0c60-4cc3-a454-2ec96a5bc426',
            patient: {
                requestedResolvedIdentifiers: {
                    requestedResolvedIdentifier: {
                        identity: '8001152',
                        assigningFacility: '657',
                        assigningAuthority: 'USVHA'
                    }
                },
                requestedIncludedIdentifiers: { requestedIncludedIdentifier: {} },
                resultantIdentifiers: {
                    resultantIdentifier: {
                        identity: '8001152',
                        assigningFacility: '657',
                        assigningAuthority: 'USVHA'
                    }
                },
                clinicalDocumentSigners: {
                    clinicalDocumentSigner: [
                        {
                            documentNumber: '1010512536',
                            additionalSigners: {
                                additionalSigner: [
                                    {
                                        expectedSigner: {
                                            identifier: {
                                                identity: '17396',
                                                assigningFacility: '657',
                                                assigningAuthority: 'USVHA'
                                            },
                                            idSourceTable: 'VISTA200',
                                            name: {
                                                given: 'DOCONE',
                                                family: 'HDRMARCY',
                                                title: 'PHYSICIAN (STAFF)'
                                            }
                                        },
                                        cosignatureNeeded: 'NO',
                                        signatureDate: { literal: '20180507163729' },
                                        signer: {
                                            practitioner: {
                                                identifier: { identity: '17396' },
                                                idSourceTable: 'VISTA200',
                                                name: {
                                                    given: 'DOCONE',
                                                    family: 'HDRMARCY',
                                                    title: 'PHYSICIAN (STAFF)'
                                                }
                                            },
                                            participationDate: {},
                                            signatureBlockName: 'DOCONE HDRMARCY',
                                            signatureBlockTitle: 'MD',
                                            signatureMode: {
                                                code: 'E',
                                                displayText: 'electronic'
                                            }
                                        },
                                        signedBySurrogate: 'NO'
                                    },
                                    {
                                        expectedSigner: {
                                            identifier: {
                                                identity: '17398',
                                                assigningFacility: '657',
                                                assigningAuthority: 'USVHA'
                                            },
                                            idSourceTable: 'VISTA200',
                                            name: {
                                                given: 'DOCTHREE',
                                                family: 'HDRMARCY',
                                                title: 'PHYSICIAN (STAFF)'
                                            }
                                        },
                                        cosignatureNeeded: 'NO',
                                        signatureDate: { literal: '20180507163850' },
                                        signer: {
                                            practitioner: {
                                                identifier: { identity: '17398' },
                                                idSourceTable: 'VISTA200',
                                                name: {
                                                    given: 'DOCTHREE',
                                                    family: 'HDRMARCY',
                                                    title: 'PHYSICIAN (STAFF)'
                                                }
                                            },
                                            participationDate: {},
                                            signatureBlockName: 'DOCTHREE HDRMARCY',
                                            signatureBlockTitle: 'MD',
                                            signatureMode: {
                                                code: 'E',
                                                displayText: 'electronic'
                                            }
                                        },
                                        signedBySurrogate: 'NO'
                                    },
                                    {
                                        expectedSigner: {
                                            identifier: {
                                                identity: '17397',
                                                assigningFacility: '657',
                                                assigningAuthority: 'USVHA'
                                            },
                                            idSourceTable: 'VISTA200',
                                            name: {
                                                given: 'DOCTWO',
                                                family: 'HDRMARCY',
                                                title: 'PHYSICIAN (STAFF)'
                                            }
                                        },
                                        cosignatureNeeded: 'NO',
                                        signatureDate: {},
                                        signer: {
                                            practitioner: { identifier: {}, name: {} },
                                            participationDate: {},
                                            signatureMode: {}
                                        }
                                    }
                                ]
                            }
                        }
                    ]
                }
            },
            errorSection: {
                errors: { error: [] },
                fatalErrors: { fatalError: [] },
                warnings: { warning: [] }
            }
        }
    })
);
