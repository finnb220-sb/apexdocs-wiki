// disabling es lint rules below as this is legacy code, we need to revisit these at a future time
/* eslint-disable consistent-return */
import { LightningElement, api, track } from 'lwc';

export default class PaginationContainer extends LightningElement {
    @api list;
    // TODO: fetch data
    @api properties;
    @api handler;
    @track current;
    @api recId;
    @api context;
    first;
    next;
    previous;
    last;
    loading;
    index;

    connectedCallback() {
        if (this.list) {
            // Pagination Logic
            this.current = this.list.filter((entry) => entry.vtcId === this.recId)[0];
            this.index = this.list.findIndex((entry) => entry.vtcId === this.recId);
            this.first = this.list[0];
            this.last = JSON.parse(JSON.stringify(this.list[this.list.length - 1]));

            if (this.last.vtcId === this.current.vtcId) {
                this.next = this.current;
            } else {
                this.next = this.list[this.index + 1];
            }

            if (this.first.vtcId === this.current.vtcId) {
                this.previous = this.current;
            } else {
                this.previous = this.list[this.index - 1];
            }

            //this.loading = false;
        } else {
            //this.loading = false;
        }
    }

    get isPreviousDisabled() {
        return this.index === 0;
    }
    get isNextDisabled() {
        return this.index === this.list.length - 1;
    }
    handleFirst() {
        const evt = new CustomEvent('paginationclick', {
            detail: {
                id: this.first.vtcId,
                view: 'single'
            }
        });
        this.dispatchEvent(evt);
    }

    handlePrevious() {
        const evt = new CustomEvent('paginationclick', {
            detail: {
                id: this.previous.vtcId,
                view: 'single'
            }
        });
        this.dispatchEvent(evt);
    }
    handleNext() {
        const evt = new CustomEvent('paginationclick', {
            detail: {
                id: this.next.vtcId,
                view: 'single'
            }
        });
        this.dispatchEvent(evt);
    }
    handleLast() {
        const evt = new CustomEvent('paginationclick', {
            detail: {
                id: this.last.vtcId,
                view: 'single'
            }
        });
        this.dispatchEvent(evt);
    }

    handleReturnToList() {
        const evt = new CustomEvent('paginationclick', {
            detail: {
                id: null,
                view: 'list'
            }
        });
        this.dispatchEvent(evt);
    }

    getRecordById = (id, arr) => {
        // have to convert object to avoid proxy error
        arr = JSON.parse(JSON.stringify(arr));
        if (id && arr) {
            const result = arr.filter((item) => {
                if (id === item.vtcId) return item;
                return false; // Add a return statement for cases when the condition is not met
            });
            if (result.length > 0) {
                return result[0];
            }

            const logger = this.template.querySelector('c-logger');
            logger.error('No matches found. ');
            logger.saveLog();
        } else {
            const logger = this.template.querySelector('c-logger');
            logger.error('Please provide a valid list of iterable objects and an id. ');
            logger.saveLog();
        }
    };

    get paginationGvtcIde() {
        return `${this.index + 1} of ${this.list.length}`;
    }
}
