public with sharing class VCC_LabDomain {
    public VCC_LabDomain() {
    }

    /**
     * @description Static methods that returns a flattened array constructed from labs from all sites
     * @param labObject Lab Data Structure
     * @return  `List<VCC_LabModal.lab>`
     */
    public List<VCC_LabModal.Lab> flattenSites(VCC_LabModal labObject) {
        List<VCC_LabModal.Lab> labsFromAllSites = new List<VCC_LabModal.Lab>();

        for (VCC_LabModal.Sites site : labObject?.sites) {
            labsFromAllSites.addAll(site?.results?.labs?.lab);
        }
        return labsFromAllSites;
    }
}
