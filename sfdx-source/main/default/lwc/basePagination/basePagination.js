import { LightningElement, track, api } from "lwc";
import * as helper from "./basePaginationHelper";

export default class BasePagination extends LightningElement {
    @track pages = []; // each page is an array of JSObjects
    @api entriesPerPage; // defaults to 10 entries per page
    @api list; // list of JSObjects to paginate
    @api hideButtons = false; //provides parameter to hide the pagination buttons, but still populate list

    current = 0;
    total = 0;

    prevdisable;
    nextdisable;

    // upon insertion to the dom check if list is a populated array then create the pages array by breaking up list into chunks
    connectedCallback() {
        if (Array.isArray(this.list)) {
            this.pages = helper.chunk([...this.list], this.entriesPerPage || 10);
            this.total = this.list.length;
            this.returnPage();
        }
    }

    // if not on first page, go to previous page
    handleBack() {
        this.current > 0 ? ((this.current = this.current - 1), this.returnPage()) : null;
    }

    // if not on last page, go to next page
    handleNext() {
        this.current < this.pages.length - 1 ? ((this.current = this.current + 1), this.returnPage()) : null;
    }

    // if not on first page go to first page
    handleFirst() {
        this.current != 0 ? ((this.current = 0), this.returnPage()) : null;
    }

    // if not on last page, go to last page
    handleLast() {
        this.current + 1 != this.pages.length ? ((this.current = this.pages.length - 1), this.returnPage()) : null;
    }

    // dispatch current page as array of JSObjects
    returnPage() {
        console.log("gwb");
        this.dispatchEvent(new CustomEvent("pagechange", { detail: this.pages[this.current], bubbles: true, composed: true }));
        this.prevdisable = this.current === 0;
        this.nextdisable = this.current === this.pages.length - 1;
    }

    get paginationString() {
        return `${this.current + 1} of ${this.pages.length}`; // template literal
    }

    @api
    setList(list) {
        this.list = list;
        this.current = 0;
        this.pages = helper.chunk([...list], this.entriesPerPage || 10);
        this.total = list.length;
        this.returnPage();
    }

    @api
    totalRecords() {
        return this.total;
    }
}
