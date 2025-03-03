public with sharing class vitalsSearchJSONWrapper {
    public class VitalSignSetTO {
        public String timestamp { get; set; }
        public Facility facility { get; set; }
        public Vitals vitals { get; set; }
        public String units { get; set; }
        public String qualifiers { get; set; }

        public VitalSignSetTO(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'timestamp') {
                            timestamp = parser.getText();
                        } else if (text == 'facility') {
                            facility = new Facility(parser);
                        } else if (text == 'vitals') {
                            vitals = new Vitals(parser);
                        } else if (text == 'units') {
                            units = parser.getText();
                        } else if (text == 'qualifiers') {
                            qualifiers = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'VitalSignSetTO consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Type {
        public String category { get; set; }
        public String name { get; set; }

        public Type(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'category') {
                            category = parser.getText();
                        } else if (text == 'name') {
                            name = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Type consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public TaggedVitalSignSetArrays taggedVitalSignSetArrays { get; set; }

    public vitalsSearchJSONWrapper(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'taggedVitalSignSetArrays') {
                        taggedVitalSignSetArrays = new TaggedVitalSignSetArrays(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'VdifVitalsSearchResponse consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    public class VitalSignTO {
        public Type type { get; set; }
        public String value1 { get; set; }
        public String units { get; set; }
        public String qualifiers { get; set; }

        public VitalSignTO(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = new Type(parser);
                        } else if (text == 'value1') {
                            value1 = parser.getText();
                        } else if (text == 'units') {
                            units = parser.getText();
                        } else if (text == 'qualifiers') {
                            qualifiers = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'VitalSignTO consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class TaggedVitalSignSetArray {
        public Integer count { get; set; }
        public String tag { get; set; }
        public Vitals_Z vitals { get; set; }

        public TaggedVitalSignSetArray(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'count') {
                            count = parser.getIntegerValue();
                        } else if (text == 'tag') {
                            tag = parser.getText();
                        } else if (text == 'vitals') {
                            vitals = new Vitals_Z(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'TaggedVitalSignSetArray consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Vitals {
        public List<VitalSignTO> vitalSignTO { get; set; }

        public Vitals(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'vitalSignTO') {
                            vitalSignTO = arrayOfVitalSignTO(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Vitals consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Facility {
        public String tag { get; set; }
        public String text { get; set; }

        public Facility(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'tag') {
                            tag = parser.getText();
                        } else if (text == 'text') {
                            text = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Facility consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class TaggedVitalSignSetArrays {
        public Integer count { get; set; }
        public Arrays arrays { get; set; }

        public TaggedVitalSignSetArrays(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'count') {
                            count = parser.getIntegerValue();
                        } else if (text == 'arrays') {
                            arrays = new Arrays(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'TaggedVitalSignSetArrays consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Arrays {
        public List<TaggedVitalSignSetArray> taggedVitalSignSetArray { get; set; }

        public Arrays(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'taggedVitalSignSetArray') {
                            taggedVitalSignSetArray = arrayOfTaggedVitalSignSetArray(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Arrays consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public class Vitals_Z {
        public List<VitalSignSetTO> vitalSignSetTO { get; set; }

        public Vitals_Z(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'vitalSignSetTO') {
                            vitalSignSetTO = arrayOfVitalSignSetTO(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Vitals_Z consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    public static vitalsSearchJSONWrapper parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new vitalsSearchJSONWrapper(parser);
    }

    public static void consumeObject(System.JSONParser parser) {
        Integer depth = 0;
        do {
            System.JSONToken curr = parser.getCurrentToken();
            if (curr == System.JSONToken.START_OBJECT || curr == System.JSONToken.START_ARRAY) {
                depth++;
            } else if (curr == System.JSONToken.END_OBJECT || curr == System.JSONToken.END_ARRAY) {
                depth--;
            }
        } while (depth > 0 && parser.nextToken() != null);
    }

    private static List<VitalSignSetTO> arrayOfVitalSignSetTO(System.JSONParser p) {
        List<VitalSignSetTO> res = new List<VitalSignSetTO>();
        if (p.getCurrentToken() == null)
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new VitalSignSetTO(p));
        }
        return res;
    }

    private static List<VitalSignTO> arrayOfVitalSignTO(System.JSONParser p) {
        List<VitalSignTO> res = new List<VitalSignTO>();
        if (p.getCurrentToken() == null)
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new VitalSignTO(p));
        }
        return res;
    }

    private static List<TaggedVitalSignSetArray> arrayOfTaggedVitalSignSetArray(System.JSONParser p) {
        List<TaggedVitalSignSetArray> res = new List<TaggedVitalSignSetArray>();
        if (p.getCurrentToken() == null)
            p.nextToken();
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new TaggedVitalSignSetArray(p));
        }
        return res;
    }
}
