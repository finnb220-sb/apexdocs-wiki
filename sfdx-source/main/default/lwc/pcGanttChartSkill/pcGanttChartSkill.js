import { LightningElement, api, track } from "lwc";

export default class PcGanttChartSkill extends LightningElement {
    @api serviceResourcesId;
    @api
    get skill() {
        return this._skill;
    }
    set skill(_skill) {
        this._skill = _skill;
        this.setServiceResources();
    }
    defaultBackgroundColor = "GavinBlue";

    @api
    refreshDates() {
        let times = [];
        for (let i = 0; i < 24; i++) {
            let time = {
                class: "slds-col lwc-timeslot"
            };
            times.push(time);
        }
        this.times = times;
        this.setServiceResources();
    }
    @track serviceResources = [];

    connectedCallback() {
        this.refreshDates();
    }

    // calculate shift classes
    calcClass() {
        let classes = ["slds-is-absolute", "lwc-allocation"];
        return classes.join(" ");
    }

    // calculate shift positions/styles
    calcStyle(shift) {
        if (!this.times) {
            return;
        }
        const totalSlots = this.times.length;
        let styles = ["left: " + (shift.left / totalSlots) * 100 + "%", "right: " + ((totalSlots - shift.right) / totalSlots) * 100 + "%"];

        if ("Unavailable" !== shift.Status__c) {
            const colorMap = {
                Blue: "#1589EE",
                Green: "#4AAD59",
                Red: "#E52D34",
                Turqoise: "#0DBCB9",
                Navy: "#052F5F",
                Orange: "#E56532",
                Purple: "#62548E",
                Pink: "#CA7CCE",
                Brown: "#823E17",
                Lime: "#7CCC47",
                Gold: "#FCAF32",
                GavinBlue: "#B6C4DE"
            };
            styles.push("background-color: " + colorMap[this.defaultBackgroundColor]);
        }
        styles.push("pointer-events: none");
        styles.push("transition: left ease 250ms, right ease 250ms");
        return styles.join("; ");
    }

    // calculate allocation label position
    calcLabelStyle(shift) {
        if (!this.times) {
            return;
        }

        const totalSlots = this.times.length;
        let left = shift.left / totalSlots < 0 ? 0 : shift.left / totalSlots;
        let right = (totalSlots - shift.right) / totalSlots < 0 ? 0 : (totalSlots - shift.right) / totalSlots;
        let styles = ["left: calc(" + left * 100 + "% + 15px)", "right: calc(" + right * 100 + "% + 30px); color : black;"];
        styles.push("transition: left ease 250ms, right ease 250ms");
        return styles.join("; ");
    }

    setServiceResources() {
        let self = this;
        self.serviceResources = [];
        // set alternating row color
        if (self._skill.Id % 2) {
            this.bgColor = "background-color : #F9F9F9";
        } else {
            this.bgColor = "background-color : #FFFFFF";
        }
        Object.keys(self._skill.shiftsByServiceResource).forEach((srId) => {
            let sr = {
                id: srId,
                shifts: []
            };
            let shift = self.skill.shiftsByServiceResource[srId];
            shift = Object.assign({}, shift);
            shift.class = self.calcClass(shift);
            shift.style = self.calcStyle(shift);
            shift.labelStyle = self.calcLabelStyle(shift);
            sr.shifts.push(shift);
            self.serviceResources.push(sr);
        });
    }
}
