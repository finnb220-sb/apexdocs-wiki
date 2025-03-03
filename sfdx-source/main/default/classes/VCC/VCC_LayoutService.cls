public with sharing class VCC_LayoutService {
    public static Metadata.Layout getPageLayout(String sobjectName, String pageLayoutName) {
        List<Metadata.Metadata> pageLayoutList = Metadata.Operations.retrieve(Metadata.MetadataType.Layout, new List<String>{ sobjectName + '-' + pageLayoutName });
        return (pageLayoutList.size() > 0) ? (Metadata.Layout) pageLayoutList[0] : null;
    }

    public static LayoutInfo getLayoutInfo(Metadata.Layout layout, LayoutInfoOptions options) {
        return new LayoutInfo(layout, options);
    }

    public static LayoutInfo getLayoutInfo(Metadata.Layout layout, Set<String> sectionsToExclude) {
        LayoutInfoOptions options = new LayoutInfoOptions();
        options.excludeSections = sectionsToExclude;
        return new LayoutInfo(layout, options);
    }

    public static LayoutInfo getLayoutInfo(Metadata.Layout layout) {
        return new LayoutInfo(layout);
    }

    public static Map<String, String> getRelationshipFields(LayoutInfo layoutInfo, SObjectType sObjectType) {
        Map<String, SObjectField> fieldMap = sObjectType.getDescribe().fields.getMap();
        Map<String, String> fieldNameToRelationshipNameMap = new Map<String, String>();

        for (String fieldName : layoutInfo.fieldSet) {
            String relationshipName = fieldMap.get(fieldName).getDescribe().getRelationshipName();

            if (String.isBlank(relationshipName)) {
                continue;
            }
            fieldNameToRelationshipNameMap.put(fieldName, relationshipName);
        }

        return fieldNameToRelationshipNameMap;
    }

    /**
     * @description
     * @param originalSObject the sObject whose missings fields will be returned.
     * @param layoutInfo `VCC_LayoutService.LayoutInfo` info of page layout whose fields you need data for
     * @return  `Set<String>` of fields that are missing from originalSObject
     */
    public static Set<String> getMissingFields(SObject originalSObject, LayoutInfo layoutInfo) {
        //gathering all fields with data in them already
        Set<String> populatedFieldSet = originalSObject.getPopulatedFieldsAsMap().keySet();

        //removing fields that are not required from the populated field set
        populatedFieldSet.retainAll(layoutInfo.fieldSet);

        //creating a set of fields to query
        Set<String> missingFieldSet = new Set<String>(layoutInfo.fieldSet);

        //removing fields that have data already
        missingFieldSet.removeAll(populatedFieldSet);

        return missingFieldSet;
    }

    public class LayoutInfoOptions {
        public Set<String> excludeSections { get; set; }

        public LayoutInfoOptions() {
            this.excludeSections = new Set<String>();
        }
    }

    public class LayoutInfo {
        public LayoutInfo(Metadata.Layout layout, LayoutInfoOptions options) {
            parseLayout(layout, options.excludeSections);
        }

        public LayoutInfo(Metadata.Layout layout) {
            this(layout, new LayoutInfoOptions());
        }

        public Set<String> fieldSet = new Set<String>();

        //using a list to preserve the order of sections
        public List<String> sectionHashList = new List<String>();

        /**
         * The keys in this map are: layoutSection.label + layoutSection.hashCode()
         * I use hash codes because Metadata.LayoutSection does not have a unique key.
         *
         * It's worth noting that it is possible for two different strings to generate the same hashcode..albeit very rare.
         * Even more rare considering that a given field can only be in one LayoutSection.
         */
        public Map<String, Metadata.LayoutSection> sectionHashToSectionMap = new Map<String, Metadata.LayoutSection>();

        /**
         * generates the hash map
         */
        private void parseLayout(Metadata.Layout layout, Set<String> sectionsToExclude) {
            //sections
            for (Metadata.LayoutSection layoutSection : layout?.layoutSections) {
                if (sectionsToExclude.contains(layoutSection.label)) {
                    continue;
                }
                String sectionHash = generateHash(layoutSection);
                this.sectionHashList.add(sectionHash);
                this.sectionHashToSectionMap.put(sectionHashList[sectionHashList.size() - 1], layoutSection);

                //columns
                for (Metadata.LayoutColumn layoutColumn : layoutSection?.layoutColumns) {
                    if (layoutColumn.layoutItems == null) {
                        continue;
                    }

                    for (Metadata.LayoutItem layoutItem : layoutColumn?.layoutItems) {
                        if (String.isBlank(layoutItem.field)) {
                            continue;
                        }

                        this.fieldSet.add(layoutItem.field);
                    }
                }
            }
            System.assert(this.sectionHashList.size() == this.sectionHashToSectionMap.keySet().size(), 'A collision ocurred when parsing the page layout.');
        }

        private String generateHash(Metadata.LayoutSection layoutSection) {
            return layoutSection.label + (String.valueOf(layoutSection).hashCode());
        }
    }
}
