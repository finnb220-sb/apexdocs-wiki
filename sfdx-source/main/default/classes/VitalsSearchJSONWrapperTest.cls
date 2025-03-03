@IsTest
public class VitalsSearchJSONWrapperTest {
    // This test method should give 100% coverage
    static testMethod void testParse() {
        String json =
            '{' +
            '   \"taggedVitalSignSetArrays\":{' +
            '      \"count\":1,' +
            '      \"arrays\":{' +
            '         \"taggedVitalSignSetArray\":[' +
            '            {' +
            '               \"count\":52,' +
            '               \"tag\":\"984\",' +
            '               \"vitals\":{' +
            '                  \"vitalSignSetTO\":[' +
            '                     {' +
            '                        \"timestamp\":\"20171129.090730\",' +
            '                        \"facility\":{' +
            '                           \"tag\":\"983\",' +
            '                           \"text\":\"CHYSHR TEST LAB\"' +
            '                        },' +
            '                        \"vitals\":{' +
            '                           \"vitalSignTO\":[' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"BLOOD PRESSURE\"' +
            '                                 },' +
            '                                 \"value1\":\"135/75\",' +
            '                                 \"units\":\"mm[Hg]\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"PULSE\"' +
            '                                 },' +
            '                                 \"value1\":\"120\",' +
            '                                 \"units\":\"/min\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"PAIN\"' +
            '                                 },' +
            '                                 \"value1\":\"3\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"PULSE OXIMETRY\"' +
            '                                 },' +
            '                                 \"value1\":\"100\",' +
            '                                 \"units\":\"%\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"RESPIRATION\"' +
            '                                 },' +
            '                                 \"value1\":\"100\",' +
            '                                 \"units\":\"/min\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"TEMPERATURE\"' +
            '                                 },' +
            '                                 \"value1\":\"99.3\",' +
            '                                 \"units\":\"F\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"WEIGHT\"' +
            '                                 },' +
            '                                 \"value1\":\"151\",' +
            '                                 \"units\":\"lb\"' +
            '                              }' +
            '                           ]' +
            '                        },' +
            '                        \"units\":\"BP:mm[Hg],PULSE:/min,POx:%,RESP:/min,TEMP:F,WT:lb\"' +
            '                     },' +
            '                     {' +
            '                        \"timestamp\":\"20150115.092700\",' +
            '                        \"facility\":{' +
            '                           \"tag\":\"983\",' +
            '                           \"text\":\"CHYSHR TEST LAB\"' +
            '                        },' +
            '                        \"vitals\":{' +
            '                           \"vitalSignTO\":[' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"BLOOD PRESSURE\"' +
            '                                 },' +
            '                                 \"value1\":\"120/\",' +
            '                                 \"units\":\"mm[Hg]\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"CIRCUMFERENCE/GIRTH\"' +
            '                                 },' +
            '                                 \"value1\":\"36\",' +
            '                                 \"units\":\"in\",' +
            '                                 \"qualifiers\":\"ABDOMINAL\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"CENTRAL VENOUS PRESSURE\"' +
            '                                 },' +
            '                                 \"value1\":\"25\",' +
            '                                 \"units\":\"cmH2O\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"HEIGHT\"' +
            '                                 },' +
            '                                 \"value1\":\"100\",' +
            '                                 \"units\":\"in\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"PULSE\"' +
            '                                 },' +
            '                                 \"value1\":\"66\",' +
            '                                 \"units\":\"/min\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"PAIN\"' +
            '                                 },' +
            '                                 \"value1\":\"0\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"PULSE OXIMETRY\"' +
            '                                 },' +
            '                                 \"value1\":\"66\",' +
            '                                 \"units\":\"%\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"RESPIRATION\"' +
            '                                 },' +
            '                                 \"value1\":\"100\",' +
            '                                 \"units\":\"/min\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"TEMPERATURE\"' +
            '                                 },' +
            '                                 \"value1\":\"97.5\",' +
            '                                 \"units\":\"F\"' +
            '                              },' +
            '                              {' +
            '                                 \"type\":{' +
            '                                    \"category\":\"Vital Signs\",' +
            '                                    \"name\":\"WEIGHT\"' +
            '                                 },' +
            '                                 \"value1\":\"200\",' +
            '                                 \"units\":\"lb\"' +
            '                              }' +
            '                           ]' +
            '                        },' +
            '                        \"units\":\"BP:mm[Hg],CIRC:in,CVP:cmH2O,HT:in,PULSE:/min,POx:%,RESP:/min,TEMP:F,WT:lb\",' +
            '                        \"qualifiers\":\"CIRC:ABDOMINAL\"' +
            '                     }' +
            '                  ]' +
            '               }' +
            '            }' +
            '         ]' +
            '      }' +
            '   }' +
            '}';
        VitalsSearchJSONWrapper r = VitalsSearchJSONWrapper.parse(json);
        System.assert(r != null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.VitalSignSetTO objVitalSignSetTO = new VitalsSearchJSONWrapper.VitalSignSetTO(System.JSON.createParser(json));
        System.assert(objVitalSignSetTO != null);
        System.assert(objVitalSignSetTO.timestamp == null);
        System.assert(objVitalSignSetTO.facility == null);
        System.assert(objVitalSignSetTO.vitals == null);
        System.assert(objVitalSignSetTO.units == null);
        System.assert(objVitalSignSetTO.qualifiers == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.Type objType = new VitalsSearchJSONWrapper.Type(System.JSON.createParser(json));
        System.assert(objType != null);
        System.assert(objType.category == null);
        System.assert(objType.name == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper objVitalsSearchJSONWrapper = new VitalsSearchJSONWrapper(System.JSON.createParser(json));
        System.assert(objVitalsSearchJSONWrapper != null);
        System.assert(objVitalsSearchJSONWrapper.taggedVitalSignSetArrays == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.VitalSignTO objVitalSignTO = new VitalsSearchJSONWrapper.VitalSignTO(System.JSON.createParser(json));
        System.assert(objVitalSignTO != null);
        System.assert(objVitalSignTO.type == null);
        System.assert(objVitalSignTO.value1 == null);
        System.assert(objVitalSignTO.units == null);
        System.assert(objVitalSignTO.qualifiers == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.TaggedVitalSignSetArray objTaggedVitalSignSetArray = new VitalsSearchJSONWrapper.TaggedVitalSignSetArray(System.JSON.createParser(json));
        System.assert(objTaggedVitalSignSetArray != null);
        System.assert(objTaggedVitalSignSetArray.count == null);
        System.assert(objTaggedVitalSignSetArray.tag == null);
        System.assert(objTaggedVitalSignSetArray.vitals == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.Vitals objVitals = new VitalsSearchJSONWrapper.Vitals(System.JSON.createParser(json));
        System.assert(objVitals != null);
        System.assert(objVitals.vitalSignTO == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.Facility objFacility = new VitalsSearchJSONWrapper.Facility(System.JSON.createParser(json));
        System.assert(objFacility != null);
        System.assert(objFacility.tag == null);
        System.assert(objFacility.text == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.TaggedVitalSignSetArrays objTaggedVitalSignSetArrays = new VitalsSearchJSONWrapper.TaggedVitalSignSetArrays(System.JSON.createParser(json));
        System.assert(objTaggedVitalSignSetArrays != null);
        System.assert(objTaggedVitalSignSetArrays.count == null);
        System.assert(objTaggedVitalSignSetArrays.arrays == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.Arrays objArrays = new VitalsSearchJSONWrapper.Arrays(System.JSON.createParser(json));
        System.assert(objArrays != null);
        System.assert(objArrays.taggedVitalSignSetArray == null);

        json = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
        VitalsSearchJSONWrapper.Vitals_Z objVitals_Z = new VitalsSearchJSONWrapper.Vitals_Z(System.JSON.createParser(json));
        System.assert(objVitals_Z != null);
        System.assert(objVitals_Z.vitalSignSetTO == null);
    }
}
