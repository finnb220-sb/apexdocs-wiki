import { LightningElement, api } from "lwc";
import * as h from "c/helpersLWC";
import { stringHelper } from "c/utils";

const dummyData = [
    {
        name: "sal",
        dob: "1993-03-28",
        content: "The classic latin passage that just never gets old, enjoy as much (or as little) lorem ipsum as you can handle with our easy to use filler text generator."
    },
    {
        name: "jose",
        dob: "1996-04-26",
        content: "If you haven't seen Game of Thrones, go watch it right now. If you have then you'll totally get why this Hodor themed lorem ipsum generator is just brilliant."
    },
    {
        name: "jasmin",
        dob: "1995-02-26",
        content: "A handcrafted, small-batch, artisinal pour-over version of the classic lorem ipsum generator, Hipster Ipsum will give your mocks that blue collar touch."
    },
    {
        name: "casey",
        dob: "1992-05-12",
        content: "Like your lorem ipsum extra crispy? Then Bacon Ipsum is the placeholder text generator for you. Side of eggs and hashbrowns is optional, but recommended."
    }
];

export default class BaseVahcFrame extends LightningElement {
    data = dummyData;

    // TODO: handle date change

    handleDateChange(event) {
        const { detail: value } = event;
        console.log(h.proxyTool(value));
    }

    handleSearchChange(event) {
        console.log(h.proxyTool(event.detail));
    }

    connectedCallback() {
        console.log(stringHelper.formatStringForSearch("sal jose and dogs"));
        console.log("search all", stringHelper.flatSearch(this.data, "19"));
        console.log("search specific", stringHelper.flatSearch(this.data, "1996", ["dob"]));
    }
}
