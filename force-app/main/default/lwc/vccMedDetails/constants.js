export const sharedDetails = [
    { title: "Prescription Status", info: "fullData.vaStatus.value" },
    { title: "Rx Patient Status", info: "rxPatientStatus" },
    { title: "Dosage", info: "dosesDoseDosage" },
    { title: "Facility Name", info: "facilityName" },
    { title: "SIG", info: "fullData.sig.content" },
    { title: "Schedule", info: "schedule" },
    { title: "No. of Refills", info: "fullData.fillsAllowed.value" },
    { title: "Indication", info: "indication", whoCanSee: ["pharmacy"] },
    { title: "Provider", info: "fullData.orderingProvider.name" },
    { title: "Pat Instructions", info: "fullData.ptInstructions.content" },
    { title: "Documented By", info: "nonVaDocumentedBy" },
    { title: "Expires", info: "fullData.expires.formattedValue" },
    { title: "CS Schedule", info: "csSchedule", whoCanSee: ["pharmacy"] },
    { title: "Provider Comments", info: "fullData.supplemental.outpatientRxFields.providerComments.text", whoCanSee: ["pharmacy", "clinicalTriage", "virtualCareVisit"] },
    { title: "Indicators", info: "indicatorString", whoCanSee: ["pharmacy"] },
    { title: "Remarks", info: "remarks" },
    { title: "Parked", info: "parked", whoCanSee: ["pharmacy"] },
    { title: "Issue Date", info: "fullData.start.formattedValue" },
    { title: "Days of Supply", info: "fullData.daysSupply.value" },
    { title: "Comments", info: "nonVaComments" },
    { title: "Last Fill Date", info: "fullData.lastFilled.formattedValue" },
    { title: "Quantity", info: "fullData.quantity.value" },
    { title: "Release Date", info: "fillsReleaseDate" },
    { title: "Remaining", info: "fullData.fillsRemaining.value" },
    { title: "Clinic", info: "fullData.location.name" },
    { title: "Routing", info: "fullData.routing.value" }
];

export const workstreamAdditionalDetails = {
    clinicalTriageRN: [{ title: "Provider Comments", info: "" }],
    pharmacyPHR: [
        { title: "", info: "" },
        { title: "", info: "" },
        { title: "", info: "" }
    ],
    virtualCareVisitMP: [{ title: "", info: "" }]
};

/*

<!-- <template for:each={medDetails} for:item="detail">
					<div tabindex="0" class='vertical detail-cell' if:true={detail.show} key={med.fullData.prescription.value}>
						<div class="title">
							<p>{detail.title}</p>
						</div>
						<div class="horizontal info">
							<p>{detail.infoValue}</p>
						</div>
					</div>
				</template> -->

				Wasn't working for fullData properties since they are levels deeper and not for dose

	{ title: "Prescription Status", info: "fullData.vaStatus.value" },
	{ title: "Rx Patient Status", info: "rxPatientStatus" },
	{ title: "Dosage", info: "dosesDoseDosage" },
	{ title: "Facility Name", info: "facilityName" },
	{ title: "SIG", info: "fullData.sig.content" },
	{ title: "Schedule", info: ".schedule" },
	{ title: "No. of Refills", info: "fullData.fillsAllowed.value" },
	{ title: "Indication", info: "indication", whoCanSee: ["pharmacy"] },
	{ title: "Provider", info: "fullData.orderingProvider.name" },
	{ title: "Pat Instructions", info: "fullData.ptInstructions.content" },
	{ title: "Documented By", info: "nonVaDocumentedBy" },
	{ title: "Expires", info: "fullData.expires.formattedValue" },
	{ title: "CS Schedule", info: "csSchedule", whoCanSee: ["pharmacy"] },
	{ title: "Provider Comments", info: "fullData.supplemental.outpatientRxFields.providerComments.text", whoCanSee: ["pharmacy"] },
	{ title: "Indicators", info: "indicatorString", whoCanSee: ["pharmacy"] },
	{ title: "Remarks", info: "remarks" },
	{ title: "Parked", info: "parked", whoCanSee: ["pharmacy"] },
	{ title: "Issue Date", info: "fullData.start.formattedValue" },
	{ title: "Days of Supply", info: "fullData.daysSupply.value" },
	{ title: "Comments", info: "nonVaComments" },
	{ title: "Last Fill Date", info: "fullData.lastFilled.formattedValue" },
	{ title: "Quantity", info: "fullData.quantity.value" },
	{ title: "Release Date", info: "fillsReleaseDate" },
	{ title: "Remaining", info: "fullData.fillsRemaining.value" },
	{ title: "Clinic", info: "fullData.location.name" },
	{ title: "Routing", info: "fullData.routing.value" }
*/
