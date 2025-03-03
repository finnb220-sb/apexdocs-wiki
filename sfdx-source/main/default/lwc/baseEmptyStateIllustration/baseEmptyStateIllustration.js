import { LightningElement, api } from "lwc";
import stateAxe from "./stateAxe.html";
import stateBalloon from "./stateBalloon.html";
import stateDefault from "./stateDefault.html";
import stateDesert from "./stateDesert.html";
import stateFish from "./stateFish.html";
import stateRain from "./stateRain.html";
import stateStopsign from "./stateStopsign.html";
import stateTreasure from "./stateTreasure.html";

export default class BaseEmptyStateIllustrations extends LightningElement {
    _type = "default";

    @api set type(val) {
        if (val?.length) this._type = val;
    }

    get type() {
        return this._type;
    }

    render() {
        switch (this._type) {
            case "axe":
                return stateAxe;
            case "balloon":
            case "noConnection":
                return stateBalloon;
            case "desert":
                return stateDesert;
            case "fish":
                return stateFish;
            case "rain":
                return stateRain;
            case "stopsign":
                return stateStopsign;
            case "treasure":
            case "noResults":
                return stateTreasure;
            default:
                return stateDefault;
        }
    }
}
