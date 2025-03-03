import { PactBase, PactBaseKind } from "./PactBase.js";

export class VaPactBase extends PactBase {
    constructor() {
        super(PactBaseKind.VA);
    }
}

export class VaPactStation extends VaPactBase {
    assignments = [];
    teamMembers = [];

    stationNameRaw;
    parentStationNameRaw;
    stationNumber;
    parentStationNameAndNumber;
    stationNameAndNumber;

    constructor({ stationNameRaw = "", parentStationNameRaw = "", stationNumber = "", parentStationNameAndNumber = "", stationNameAndNumber = "" } = {}) {
        super();
        this.stationNameRaw = stationNameRaw;
        this.parentStationNameRaw = parentStationNameRaw;
        this.stationNumber = stationNumber;
        this.parentStationNameAndNumber = parentStationNameAndNumber;
        this.stationNameAndNumber = stationNameAndNumber;
    }
}

export class VaPactAssignment extends VaPactBase {
    station = {};
    teamMembers = [];

    assignmentCategory;
    assignmentStatus;
    teamName;
    assignmentDate;
    careType;
    teamFocus;

    constructor({ station, assignment }) {
        super();

        if (station === null || typeof station !== "object" || !(station instanceof VaPactStation)) {
            return;
        }
        if (assignment === null || typeof assignment !== "object") {
            return;
        }

        this.station = station;

        ({
            assignmentCategory: this.assignmentCategory = "",
            assignmentStatus: this.assignmentStatus = "",
            teamName: this.teamName = "",
            assignmentDate: this.assignmentDate = "",
            careType: this.careType = "",
            teamFocus: this.teamFocus = ""
        } = assignment);

        this.station.assignments.push(this);
    }
}

export class VaPactMember extends VaPactBase {
    station = {};
    assignment = {};

    primaryCare;
    pager;
    phone;
    supportStaff;
    roleName;
    name;
    roleDescription;
    ien;

    constructor({ station, assignment, teamMember }) {
        super();

        if (station === null || typeof station !== "object" || !(station instanceof VaPactStation)) {
            return;
        }
        if (assignment === null || typeof assignment !== "object" || !(assignment instanceof VaPactAssignment)) {
            return;
        }
        if (teamMember === null || typeof teamMember !== "object") {
            return;
        }

        this.station = station;
        this.assignment = assignment;

        ({
            primaryCare: this.primaryCare = "",
            pager: this.pager = "",
            phone: this.phone = "",
            supportStaff: this.supportStaff = "",
            roleName: this.roleName = "",
            name: this.name = "",
            roleDescription: this.roleDescription = "",
            ien: this.ien = ""
        } = teamMember);

        this.station.teamMembers.push(this);
        this.assignment.teamMembers.push(this);
    }
}

export class VaPactData {
    vaPactMembers = [];
    vaPactAssignments = [];
    vaPactStations = [];

    addPactMember(vaPactMember) {
        if (!(vaPactMember instanceof VaPactMember)) {
            throw new Error("First argument must be an instance of VaPactMember.");
        }
        this.vaPactMembers.push(vaPactMember);
    }

    addPactAssignment(vaPactAssignment) {
        if (!(vaPactAssignment instanceof VaPactAssignment)) {
            throw new Error("First argument must be an instance of VaPactAssignment.");
        }
        this.vaPactAssignments.push(vaPactAssignment);
    }

    addPactStation(vaPactStation) {
        if (!(vaPactStation instanceof VaPactStation)) {
            throw new Error("First argument must be an instance of VaPactStation.");
        }
        this.vaPactStations.push(vaPactStation);
    }
}

/**
 * @argument patientAssignmentsAtStations from the PACT PCMM response JSON
 * @returns {VaPactData} object containing all, well.. VA PACT data
 * @description Consumes the 'patientAssignmentsAtStations' property from 'PatientSummary' and the data.
 */
export function parseVaPactMembers(patientAssignmentsAtStations, Logger) {
    let vaPactData = new VaPactData();

    if (!Array.isArray(patientAssignmentsAtStations)) {
        return vaPactData;
    }

    while (patientAssignmentsAtStations?.length > 0) {
        try {
            let station = patientAssignmentsAtStations.shift();
            if (station === undefined) {
                continue;
            }

            let vaPactStation = new VaPactStation(station);
            vaPactData.addPactStation(vaPactStation);

            if (!Array.isArray(station.assignments)) {
                continue;
            }

            while (station.assignments?.length > 0) {
                try {
                    let assignment = station.assignments.shift();
                    if (assignment === undefined) {
                        continue;
                    }
                    let vaPactAssignment = new VaPactAssignment({
                        station: vaPactStation,
                        assignment: assignment
                    });
                    vaPactData.addPactAssignment(vaPactAssignment);

                    if (!Array.isArray(assignment.teamMembers)) {
                        continue;
                    }

                    while (assignment.teamMembers?.length > 0) {
                        try {
                            let vaPactMember = new VaPactMember({
                                station: vaPactStation,
                                assignment: vaPactAssignment,
                                teamMember: assignment.teamMembers.shift()
                            });
                            vaPactData.addPactMember(vaPactMember);
                        } catch (e) {
                            Logger.debug("failed to add pact member");
                            Logger.debug(String(e));
                        }
                    }
                } catch (e) {
                    Logger.debug("failed to add pact assignment");
                    Logger.debug(String(e));
                }
            }
        } catch (e) {
            Logger.debug("failed to add pact station");
            Logger.debug(String(e));
        }
    }

    return vaPactData;
}
