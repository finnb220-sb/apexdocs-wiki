import { PactBase, PactBaseKind } from "./PactBase.js";

export class NonVaPactBase extends PactBase {
    constructor() {
        super(PactBaseKind.NonVA);
    }
}

export class NonVaPactMember extends NonVaPactBase {
    specialtyName;
    teamName;
    careCoordinatorName;
    providerName;
    phone;
    city;
    state;
    practiceCity;
    practiceState;
    assignmentDate;
    Category;

    constructor({
        specialtyName = "",
        teamName = "",
        careCoordinatorName = "",
        providerName = "",
        phone = "",
        city = "",
        state = "",
        practiceCity = "",
        practiceState = "",
        assignmentDate = "",
        Category = ""
    } = {}) {
        super();
        this.specialtyName = specialtyName;
        this.teamName = teamName;
        this.careCoordinatorName = careCoordinatorName;
        this.providerName = providerName;
        this.phone = phone;
        this.city = city;
        this.state = state;
        this.practiceCity = practiceCity;
        this.practiceState = practiceState;
        this.assignmentDate = assignmentDate;
        this.Category = Category;
    }
}

export function parseNonVaPact(nonVAPCProviders, Logger) {
    let nonVaPactMembers = [];

    if (!Array.isArray(nonVAPCProviders)) {
        return nonVaPactMembers;
    }

    while (nonVAPCProviders.length > 0) {
        try {
            nonVaPactMembers.push(new NonVaPactMember(nonVAPCProviders.shift()));
        } catch (e) {
            Logger.debug("unable to add non-va pact member");
            Logger.debug(e);
        }
    }

    return nonVaPactMembers;
}
