/**
 * @description Represents a DTO (Data Transfer Object) for Progress Note in VCC.
 * This class is responsible for parsing JSON into a structured format.
 */
@SuppressWarnings('PMD.ApexDoc')
public with sharing class VCC_ProgressNoteDTO {
    /**
     * @description represents the 'NationalTitleService' clause of returned json.
     * it is an inner class of VCC_ProgressNoteDTO
     */
    public class NationalTitleService {
        /**
         * @description The service associated with the national title.
         */
        public String service { get; set; }
        /**
         * @description the VUID associated with the service.
         */
        public String vuid { get; set; }

        /**
         * @description Constructor for the NationalTitleService inner class
         * @param parser jsonParser object to parse the JSON (passed by value)
         */
        public NationalTitleService(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'service') {
                            service = parser.getText();
                        } else if (text == 'vuid') {
                            vuid = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'NationalTitleService consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description represents the 'nationalTitle' clause of returned json.
     */
    public class NationalTitle {
        /**
         * @description The title associated with the national title.
         */
        public String title { get; set; }
        /**
         * @description the VUID associated with the title.
         */
        public String vuid { get; set; }

        /**
         * @description constructor for NationalTitle objects
         * @param parser JSONParser passed by value
         */
        public NationalTitle(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'title') {
                            title = parser.getText();
                        } else if (text == 'vuid') {
                            vuid = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'NationalTitle consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Represents the Params clause of the returned JSON.
     */
    public class Params {
        /**
         * @description The domain associated with the json.
         */
        public String domain { get; set; }
        /**
         * @description the systemId associated with the json.
         */
        public String systemId { get; set; }

        /**
         * @description Constructor for the Params class
         * @param parser JsonParser object passed by value
         */
        public Params(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'domain') {
                            domain = parser.getText();
                        } else if (text == 'systemId') {
                            systemId = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Params consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Represents the 'text' clause of the json
     */
    public class Text {
        /**
         * @description list of Clinician objects
         */
        public List<Clinicians> clinicians { get; set; }
        /**
         * @description text field with the actual note in it.
         */
        public String content { get; set; }
        /**
         * @description datetime stamp
         */
        public String dateTime_Z { get; set; } // in json: dateTime
        /**
         * @description status field of the progress note.
         */
        public String status { get; set; }
        /**
         * @description uid field of the progress note.
         */
        public String uid { get; set; }

        /**
         * @description Constructor for the Text object
         * @param parser JSONParser object passed by value
         */
        public Text(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'clinicians') {
                            clinicians = arrayOfClinicians(parser);
                        } else if (text == 'content') {
                            content = parser.getText();
                        } else if (text == 'dateTime') {
                            dateTime_Z = parser.getText();
                        } else if (text == 'status') {
                            status = parser.getText();
                        } else if (text == 'uid') {
                            uid = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Text consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Represents the Data clause of the returned JSON.
     * functionally a container for items
     */
    public class Data {
        /**
         * @description Timestamp of the last update
         */
        public String updated { get; set; }
        /**
         * @description Represents the total number of items in the data object.
         */
        public String totalItems { get; set; }
        /**
         * @description array of Items objects.
         */
        public List<Items> items { get; set; }

        /**
         * @description Constructor for the Data object
         * @param parser JSONParser object passed by value
         */
        public Data(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'updated') {
                            updated = parser.getText();
                        } else if (text == 'totalItems') {
                            totalItems = parser.getText();
                        } else if (text == 'items') {
                            items = arrayOfItems(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Data consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description represents the 'NationalTitleRole' clause of the returned JSON.
     */
    public class NationalTitleRole {
        /**
         * @description role string: e.g.: 'nursing'
         */
        public String role { get; set; }
        /**
         * @description URN string for this role.
         */
        public String vuid { get; set; }

        /**
         * @description Constructor for the NationalTitleRole object
         * @param parser JSONParser object passed by value
         */
        public NationalTitleRole(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'role') {
                            role = parser.getText();
                        } else if (text == 'vuid') {
                            vuid = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'NationalTitleRole consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description represents the 'NationalTitleSetting' clause of the returned JSON.
     */
    public class NationalTitleSetting {
        /**
         * @description represents the setting string: e.g.: 'inpatient' or 'telephone encounter'
         */
        public String setting { get; set; }
        /**
         * @description URN string for this setting.
         */
        public String vuid { get; set; }

        /**
         * @description Constructor for the NationalTitleSetting object
         * @param parser JSONParser object passed by value
         */
        public NationalTitleSetting(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'setting') {
                            setting = parser.getText();
                        } else if (text == 'vuid') {
                            vuid = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'NationalTitleSetting consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Represents the 'sites' clause of the returned json.
     * note: a site isn't a great name for this object, but it's what the json uses.
     * think of a site as a location where a progress note was taken.
     */
    public class Sites {
        /**
         * @description the api version this site returned
         */
        public String apiVersion { get; set; }
        /**
         * @description a Params object
         */
        public Params params { get; set; }
        /**
         * @description The data object
         */
        public Data data { get; set; }
        /**
         * @description An ErrorSection object. (optional)
         */
        public ErrorSection errorSection { get; set; }

        /**
         * @description Site constructor
         * @param parser jsonParser object passed by value
         */
        public Sites(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'apiVersion') {
                            apiVersion = parser.getText();
                        } else if (text == 'params') {
                            params = new Params(parser);
                        } else if (text == 'data') {
                            data = new Data(parser);
                        } else if (text == 'errorSection') {
                            errorSection = new ErrorSection(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'Sites consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description National title subject object
     */
    public class NationalTitleSubject {
        public String subject { get; set; }
        public String vuid { get; set; }
        public String service { get; set; }
        /**
         * @description Constructor for the NationalTitleSubject object
         * @param parser jsonParser object passed by value
         */
        public NationalTitleSubject(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'subject') {
                            subject = parser.getText();
                        } else if (text == 'vuid') {
                            vuid = parser.getText();
                        } else if (text == 'service') {
                            service = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'NationalTitleSubject consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Raw json represents multiple sites, this stores the decoded sites.
     */
    public List<Sites> sites { get; set; }

    /**
     * @description Constructor for the VCC_ProgressNoteDTO object
     * @param parser JSONParser object passed by value
     */
    public VCC_ProgressNoteDTO(JSONParser parser) {
        while (parser.nextToken() != System.JSONToken.END_OBJECT) {
            if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                String text = parser.getText();
                if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                    if (text == 'sites') {
                        sites = arrayOfSites(parser);
                    } else {
                        System.debug(LoggingLevel.WARN, 'ProgressNoteDTO consuming unrecognized property: ' + text);
                        consumeObject(parser);
                    }
                }
            }
        }
    }

    /**
     * @description Represents the 'NationalTitleType' clause of the returned JSON.
     */
    public class NationalTitleType {
        /**
         * @description Represents the text value of the type of note
         */
        public String type { get; set; }
        /**
         * @description represents the URN of the type of note.
         */
        public String vuid { get; set; }

        /**
         * @description constructor for the NationalTitleType object
         * @param parser jsonParser object passed by value
         */
        public NationalTitleType(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'type') {
                            type = parser.getText();
                        } else if (text == 'vuid') {
                            vuid = parser.getText();
                        } else {
                            System.debug(
                                LoggingLevel.WARN,
                                'NationalTitleType consuming unrecognized property: ' + text
                            );
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description This is the main class we care about. It represents an actual progress note.
     */
    public class Items {
        /**
         * @description The document class of the note. e.g.: 'progress note', 'advanced directive'
         */
        public String documentClass { get; set; }
        /**
         * @description the document type code of the note. e.g.: 'PN', 'CR', 'C', 'W', 'A', 'D', 'DS', 'SR', 'CP', 'LR', 'RA'
         * we primarily care about PN (progress note) and D (advanced directive)
         */
        public String documentTypeCode { get; set; }
        /**
         * @description represents the document type name. e.g.: 'Progress Note', 'Advance Directive'
         */
        public String documentTypeName { get; set; }
        /**
         * @description String referencing a given name for the encounter
         */
        public String encounterName { get; set; }
        /**
         * @description URN string representing this encounter.
         */
        public String encounterUid { get; set; }
        /**
         * @description timestampe as string for when note was entered into system
         */
        public String entered { get; set; }
        /**
         * @description String representing the facility code. In theory, decodable into a VCC_FacilityService.FacilityId
         */
        public String facilityCode { get; set; }
        /**
         * @description Name of the Facility
         */
        public String facilityName { get; set; }
        /**
         * @description A local id for the note, specific to the facility code.
         */
        public String localId { get; set; }
        /**
         * @description title of the note
         */
        public String localTitle { get; set; }
        /**
         * @description nationalTitle object
         */
        public NationalTitle nationalTitle { get; set; }
        /**
         * @description nationalTitleType object
         */
        public NationalTitleType nationalTitleType { get; set; }
        /**
         * @description datetime as string for the reference date time
         */
        public String referenceDateTime { get; set; }
        /**
         * @description string representation of the status.
         */
        public String statusName { get; set; }
        /**
         * @description the TextObject(s) associated with this note.
         */
        public List<Text> text { get; set; }
        /**
         * @description URN string for this note.
         */
        public String uid { get; set; }
        /**
         * @description NationalTitleSubject object
         */
        public NationalTitleSubject nationalTitleSubject { get; set; }
        /**
         * @description NationalTitleSubject object
         */
        public NationalTitleSubject nationalTitleService { get; set; }
        /**
         * @description nationalTitleRole object
         */
        public NationalTitleRole nationalTitleRole { get; set; }
        /**
         * @description nationalTitleSetting object
         */
        public NationalTitleSetting nationalTitleSetting { get; set; }
        /**
         * @description integer as string. count of images associated with this note.
         */
        public String images { get; set; }

        /**
         * @description The constructor for the Item object.
         * @param parser JsonParser object passed by value
         */
        public Items(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String nodeName = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (nodeName == 'documentClass') {
                            documentClass = parser.getText();
                        } else if (nodeName == 'documentTypeCode') {
                            documentTypeCode = parser.getText();
                        } else if (nodeName == 'documentTypeName') {
                            documentTypeName = parser.getText();
                        } else if (nodeName == 'encounterName') {
                            encounterName = parser.getText();
                        } else if (nodeName == 'encounterUid') {
                            encounterUid = parser.getText();
                        } else if (nodeName == 'entered') {
                            entered = parser.getText();
                        } else if (nodeName == 'facilityCode') {
                            facilityCode = parser.getText();
                        } else if (nodeName == 'facilityName') {
                            facilityName = parser.getText();
                        } else if (nodeName == 'localId') {
                            localId = parser.getText();
                        } else if (nodeName == 'localTitle') {
                            localTitle = parser.getText();
                        } else if (nodeName == 'nationalTitle') {
                            nationalTitle = new NationalTitle(parser);
                        } else if (nodeName == 'nationalTitleType') {
                            nationalTitleType = new NationalTitleType(parser);
                        } else if (nodeName == 'referenceDateTime') {
                            referenceDateTime = parser.getText();
                        } else if (nodeName == 'statusName') {
                            statusName = parser.getText();
                        } else if (nodeName == 'text') {
                            text = arrayOfText(parser);
                        } else if (nodeName == 'uid') {
                            uid = parser.getText();
                        } else if (nodeName == 'nationalTitleSubject') {
                            nationalTitleSubject = new NationalTitleSubject(parser);
                        } else if (nodeName == 'nationalTitleService') {
                            nationalTitleService = new NationalTitleSubject(parser);
                        } else if (nodeName == 'nationalTitleRole') {
                            nationalTitleRole = new NationalTitleRole(parser);
                        } else if (nodeName == 'nationalTitleSetting') {
                            nationalTitleSetting = new NationalTitleSetting(parser);
                        } else if (nodeName == 'images') {
                            images = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Items consuming unrecognized property: ' + nodeName);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description represents the 'errorSection' clause of the returned JSON.
     */
    public class ErrorSection {
        /**
         * @description List of errors
         */
        public List<String> errors { get; set; }
        /**
         * @description list of fatal errors
         */
        public List<String> fatalErrors { get; set; }
        /**
         * @description list of warnings
         */
        public List<String> warnings { get; set; }

        /**
         * @description Constructor for the ErrorSection object
         * @param parser JSONParser object passed by value
         */
        public ErrorSection(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'errors') {
                            errors = arrayOfStrings(parser);
                        } else if (text == 'fatalErrors') {
                            fatalErrors = arrayOfStrings(parser);
                        } else if (text == 'warnings') {
                            warnings = arrayOfStrings(parser);
                        } else {
                            System.debug(LoggingLevel.WARN, 'ErrorSection consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description represents Clinician data
     */
    public class Clinicians {
        /**
         * @description name string in last,first format
         */
        public String name { get; set; }
        /**
         * @description The type code for the role this person played in this note.
         */
        public String role { get; set; }
        /**
         * @description the URN string for this provider.
         */
        public String uid { get; set; }
        /**
         * @description string containing first last name of the provider.
         */
        public String signature { get; set; }
        /**
         * @description the datetime stamp the note was signed stored as a string.
         */
        public String signedDateTime { get; set; }

        /**
         * @description Constructor for the Clinicians object
         * @param parser jsonParser object passed by value
         */
        public Clinicians(JSONParser parser) {
            while (parser.nextToken() != System.JSONToken.END_OBJECT) {
                if (parser.getCurrentToken() == System.JSONToken.FIELD_NAME) {
                    String text = parser.getText();
                    if (parser.nextToken() != System.JSONToken.VALUE_NULL) {
                        if (text == 'name') {
                            name = parser.getText();
                        } else if (text == 'role') {
                            role = parser.getText();
                        } else if (text == 'uid') {
                            uid = parser.getText();
                        } else if (text == 'signature') {
                            signature = parser.getText();
                        } else if (text == 'signedDateTime') {
                            signedDateTime = parser.getText();
                        } else {
                            System.debug(LoggingLevel.WARN, 'Clinicians_Z consuming unrecognized property: ' + text);
                            consumeObject(parser);
                        }
                    }
                }
            }
        }
    }

    /**
     * @description Parse method
     * @param json incoming json string.
     *
     * @return a VCC_ProgressNoteDTO object
     */
    public static VCC_ProgressNoteDTO parse(String json) {
        System.JSONParser parser = System.JSON.createParser(json);
        return new VCC_ProgressNoteDTO(parser);
    }

    /**
     * @description method to consume json with a manual parser.
     * @param parser JsonParser object passed by value
     */
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

    private static List<NationalTitleSubject> arrayOfNationalTitleSubject(System.JSONParser p) {
        List<NationalTitleSubject> res = new List<NationalTitleSubject>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new NationalTitleSubject(p));
        }
        return res;
    }

    private static List<Text> arrayOfText(System.JSONParser p) {
        List<Text> res = new List<Text>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Text(p));
        }
        return res;
    }

    private static List<String> arrayOfStrings(System.JSONParser p) {
        List<String> res = new List<String>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(p.getText());
        }
        return res;
    }

    private static List<Items> arrayOfItems(System.JSONParser p) {
        List<Items> res = new List<Items>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Items(p));
        }
        return res;
    }

    private static List<Clinicians> arrayOfClinicians(System.JSONParser p) {
        List<Clinicians> res = new List<Clinicians>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Clinicians(p));
        }
        return res;
    }

    private static List<Sites> arrayOfSites(System.JSONParser p) {
        List<Sites> res = new List<Sites>();
        if (p.getCurrentToken() == null) {
            p.nextToken();
        }
        while (p.nextToken() != System.JSONToken.END_ARRAY) {
            res.add(new Sites(p));
        }
        return res;
    }
}
