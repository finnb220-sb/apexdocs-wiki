import apex_fetchDirectives from "@salesforce/apex/VCC_DirectivesController.getDirectives";

export async function fetchDirectives({ recordId, systemId, stopDate }) {
    if (typeof recordId !== "string") {
        return;
    }

    let response = await apex_fetchDirectives({
        recordId: recordId,
        systemId: systemId,
        stopDate: stopDate
    });

    return JSON.parse(response);
}

//converting the new response so it plays nice with the how the component expects it
export async function convertResponse(response) {
    let items = response.flatMap((site) => {
        if (site?.facilityIdToDirectivesMap == null || typeof site.facilityIdToDirectivesMap != "object") {
            return [];
        }
        return Object.values(site.facilityIdToDirectivesMap).flat();
    });

    return { sites: [{ data: { items: items } }] };
}
