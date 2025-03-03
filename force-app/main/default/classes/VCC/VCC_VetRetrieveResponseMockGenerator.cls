@isTest
/**
 * @description
 * @author
 * @since
 * @group HTTP
 */
global class VCC_VetRetrieveResponseMockGenerator implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('POST', req.getMethod());

        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        res.setStatusCode(200);
        res.setBody(
            ' {' +
                ' "identityMatchThreshold": "132",' +
                '   "potentialDuplicateThreshold": "120",' +
                '   "vets": [' +
                '     {' +
                '       "mviResult": "FOUND",' +
                '       "eeResult": "FOUND",' +
                '       "emisResult": "NO_REQUEST",' +
                '       "vets360Result": "FOUND",' +
                '       "mvi": {' +
                '         "icn": "1008810533V121467",' +
                '         "mviToken": "WSDOC2003161006136761110835549",' +
                '         "personType": "PAT",' +
                '         "firstName": "TestFirstName",' +
                '         "lastName": "TestLastName",' +
                '         "middleName": "T",' +
                '         "mothersMaidenName": "TestMothersName",' +
                '         "cityOfBirth": "AKRON",' +
                '         "stateOfBirth": "CO",' +
                '         "dob": "19440708",' +
                '         "ssn": "101648716",' +
                '         "gender": "M",' +
                '         "queryMatchObservation": "124",' +
                '         "address": {' +
                '           "streetAddress": "34576 COUNTY ROAD 26",' +
                '           "city": "AKRON",' +
                '           "state": "CO",' +
                '           "postalCode": "80720",' +
                '           "country": "USA",' +
                '           "addressTypeCode": "PHYS"' +
                '         }' +
                '       },' +
                '       "ee": {' +
                '         "eeVeteranStatus": "True",' +
                '        "priorityGroup": "Group 1"' +
                '       },' +
                '      "bgs": {' +
                '        "poas": [' +
                '          {' +
                '            "legacyPoaCd": "007",' +
                '            "name": "THE RETIRED ENLISTED ASSOCIATION",' +
                '            "orgTypeName": "POA National Organization",' +
                '            "participantId": 1234' +
                '          }' +
                '        ],' +
                '        "ratingInfo": {' +
                '          "requiresAidAndAttendance": false,' +
                '          "housebound": true,' +
                '          "specialMonthlyCompensation": [' +
                '            {' +
                '              "antmclTc": "36",' +
                '              "antmclTn": "Eyes and Foot",' +
                '              "beginDateTime": [' +
                '                2021,' +
                '                6,' +
                '                7' +
                '              ],' +
                '              "convBeginDateTime": [' +
                '                2021,' +
                '                6,' +
                '                7' +
                '              ],' +
                '              "effectiveDateTimeOverrideTc": "DEFAULT",' +
                '              "effectiveDateTimeOverrideTn": "Default",' +
                '              "endDateTimeOverrideActionInd": "N",' +
                '              "endDateTimeOverrideTc": "DEFAULT",' +
                '              "endDateTimeOverrideTn": "Default",' +
                '              "hospitalSmcTc": "36",' +
                '              "hospitalSmcTn": "HS-Q",' +
                '              "lossUseTc": "36",' +
                '              "lossUseTn": "Eyes aand Foot",' +
                '              "othLossTc": "1",' +
                '              "othLossTn": "Loss or Loss of Use of Creative Organ",' +
                '              "overrideActionInd": "N",' +
                '              "paySmcTc": "36",' +
                '              "paySmcTn": "Q",' +
                '              "prflDateTime": [' +
                '                2021,' +
                '                6,' +
                '                7' +
                '              ],' +
                '              "participantIdA": "32390645",' +
                '              "ratingDateTime": [' +
                '                2021,' +
                '                6,' +
                '                7' +
                '              ],' +
                '              "ratingSn": "165508",' +
                '              "rbaIssueId": "109761",' +
                '              "smcTc": "36",' +
                '              "smcTn": "Q"' +
                '            }' +
                '          ]' +
                '        },' +
                '        "fiduciaries": [' +
                '          {' +
                '            "beginDatetime": [' +
                '              2021,' +
                '              6,' +
                '              7' +
                '            ],' +
                '            "endDatetime": [' +
                '              2021,' +
                '              6,' +
                '              7' +
                '            ],' +
                '            "birthdayDatetime": [' +
                '              2021,' +
                '              6,' +
                '              7' +
                '            ],' +
                '            "deathDatetime": [' +
                '              2021,' +
                '              6,' +
                '              7' +
                '            ],' +
                '            "eventDatetime": [' +
                '              2021,' +
                '              6,' +
                '              7' +
                '            ],' +
                '            "firstName": "Clark",' +
                '            "firstNameKey": 0,' +
                '            "lastName": "Kent",' +
                '            "lastNameKey": 0,' +
                '            "militaryPersonInd": "N",' +
                '            "participantPhone": [' +
                '              {' +
                '                "areaNumber": 815,' +
                '                "effectiveDatetime": [' +
                '                  2021,' +
                '                  6,' +
                '                  7' +
                '                ],' +
                '                "phoneTypeName": "Cellular",' +
                '                "participantId": 1234,' +
                '                "phoneNumber": 7083489' +
                '              }' +
                '            ],' +
                '            "prptnlPhraseTypeNm": "Co-Guardians of",' +
                '            "participantId": 1234,' +
                '            "participantRelationshipPK": {' +
                '              "fiduciaryInd": "Y",' +
                '              "participantIdA": 1234,' +
                '              "participantIdB": 355782,' +
                '              "participantRelationshipTypeName": "Court Appointed Co-Guardian"' +
                '            },' +
                '            "reviewDatetime": [' +
                '              2021,' +
                '              6,' +
                '              7' +
                '            ],' +
                '            "sensitivityLevel": {' +
                '              "bdnStnNbr": "328",' +
                '              "participantId": 1234,' +
                '              "reviewDatetime": [' +
                '                2021,' +
                '                6,' +
                '                7' +
                '              ],' +
                '              "remarksText": "Test Add for Volume",' +
                '              "securityLevelTypeCd": "3",' +
                '              "sensitivityLevelId": 9876' +
                '            },' +
                '            "ssnVrfctnStatusTypeCd": "0",' +
                '            "vetInd": "N"' +
                '          }' +
                '        ]' +
                '      },' +
                '      "vaProfile": {' +
                '        "createDate": "2018-04-24T18:56:52Z",' +
                '        "sourceDate": "2018-04-24T18:56:52Z",' +
                '        "sourceSystem": "VET360-TEST-PARTER",' +
                '        "txAuditId": "e18f3d02-6b64-49e4-bb76-eefcadc70145",' +
                '        "updateDate": "2018-04-24T18:56:52Z",' +
                '        "vet360Id": 1,' +
                '        "addresses": [' +
                '          {' +
                '            "addressId": 4753,' +
                '            "addressLine1": "123 Fake St",' +
                '            "addressPurposeOfUse": "CORRESPONDENCE",' +
                '            "addressType": "Domestic",' +
                '            "cityName": "Richmond",' +
                '            "confidenceScore": "100",' +
                '            "countryCodeFips": "US",' +
                '            "countryCodeIso2": "US",' +
                '            "countryCodeIso3": "USA",' +
                '            "countryName": "United States",' +
                '            "createDate": "2018-04-24T18:56:52Z",' +
                '            "effectiveEndDate": "2018-04-24T18:56:52Z",' +
                '            "geocodeDate": "2018-04-24T18:56:52Z",' +
                '            "geocodePrecision": "3",' +
                '            "latitude": "37.6678",' +
                '            "longitude": "-77.5711",' +
                '            "originatingSourceSystem": "MDM-CUF-PERSON-HUB",' +
                '            "sourceDate": "2018-04-24T18:56:52Z",' +
                '            "sourceSystem": "VET360-TEST-PARTNER",' +
                '            "sourceSystemUser": "MDM-CUF-PERSON-HUB",' +
                '            "stateCode": "VA",' +
                '            "txAuditId": "c674e6fa-db7f-4818-8129-15f2090c7ea7",' +
                '            "updateDate": "2018-04-24T18:56:52Z",' +
                '            "vet360Id": 1,' +
                '            "zipCode5": "23111"' +
                '          },' +
                '          {' +
                '            "addressId": 184847,' +
                '            "addressLine1": "123 Fake St",' +
                '            "addressPurposeOfUse": "RESIDENCE",' +
                '            "addressType": "Domestic",' +
                '            "cityName": "Richmond",' +
                '            "confidenceScore": "100",' +
                '            "countryCodeFips": "US",' +
                '            "countryCodeIso2": "US",' +
                '            "countryCodeIso3": "USA",' +
                '            "countryName": "United States",' +
                '            "createDate": "2018-04-24T18:56:52Z",' +
                '            "effectiveEndDate": "2018-04-24T18:56:52Z",' +
                '            "geocodeDate": "2018-04-24T18:56:52Z",' +
                '            "geocodePrecision": "3",' +
                '            "latitude": "37.6678",' +
                '            "longitude": "-77.5711",' +
                '            "originatingSourceSystem": "MDM-CUF-PERSON-HUB",' +
                '            "sourceDate": "2018-04-24T18:56:52Z",' +
                '            "sourceSystem": "VET360-TEST-PARTNER",' +
                '            "sourceSystemUser": "MDM-CUF-PERSON-HUB",' +
                '            "stateCode": "VA",' +
                '            "txAuditId": "c674e6fa-db7f-4818-8129-15f2090c7ea7",' +
                '            "updateDate": "2018-04-24T18:56:52Z",' +
                '            "vet360Id": 1,' +
                '            "zipCode5": "23111"' +
                '          }' +
                '        ],' +
                '        "emails": [' +
                '          {' +
                '            "confirmationDate": "2018-04-24T18:56:52Z",' +
                '            "createDate": "2018-04-24T18:56:52Z",' +
                '            "effectiveEndDate": "2018-04-24T18:56:52Z",' +
                '            "emailAddressText": "test@test.com",' +
                '            "emailId": 70135,' +
                '            "emailPermInd": true,' +
                '            "emailStatusCode": "NO_KNOWN_PROBLEM",' +
                '            "originatingSourceSystem": "MDM-CUF-PERSON-HUB",' +
                '           "sourceDate": "2018-04-24T18:56:52Z",' +
                '           "sourceSystem": "VET360-TEST-PARTNER",' +
                '           "sourceSystemUser": "MDM-CUF-PERSON-HUB",' +
                '           "txAuditId": "c674e6fa-db7f-4818-8129-15f2090c7ea7",' +
                '           "updateDate": "2018-04-24T18:56:52Z",' +
                '           "vet360Id": 1' +
                '         }' +
                '       ],' +
                '       "telephones": [' +
                '        {' +
                '           "areaCode": "804",' +
                '           "confirmationDate": "2018-04-24T18:56:52Z",' +
                '           "connectionStatusCode": "NO_KNOWN_PROBLEM",' +
                '           "countryCode": "1",' +
                '           "createDate": "2018-04-24T18:56:52Z",' +
                '           "effectiveStartDate": "2018-04-24T18:56:52Z",' +
                '           "internationalIndicator": false,' +
                '           "originatingSourceSystem": "MDM-CUF-PERSON-HUB",' +
                '           "phoneNumber": "9090211",' +
                '           "phoneType": "MOBILE",' +
                '           "sourceDate": "2018-04-24T18:56:52Z",' +
                '           "sourceSystem": "VET360-TEST-PARTNER",' +
                '           "sourceSystemUser": "MDM-CUF-PERSON-HUB",' +
                '           "telephoneId": 220929,' +
                '           "textMessageCapableInd": true,' +
                '           "textMessagePermInd": true,' +
                '           "ttyInd": false,' +
                '           "txAuditId": "c675e6fa-db7f-4818-8129-15f2090c7ea7",' +
                '           "updateDate": "2018-04-24T18:56:52Z",' +
                '           "vet360Id": 1,' +
                '           "voiceMailAcceptableInd": true' +
                '         }' +
                '       ]' +
                '     }' +
                '   }' +
                ' ]' +
                '}'
        );
        return res;
    }
}
