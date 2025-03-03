import { LightningElement, api } from 'lwc';

export default class VccHealthDataGraphFrame extends LightningElement {
    startDate;
    stopDate;

    @api
    chartTitle;
    @api
    displayReferenceRange;
    @api
    title;
    @api
    iconName;
    showChart = true;

    _graphConfig;
    _measurementsToDisplay;

    _vitalTypeSelected;

    @api
    set vitalTypeSelected(value) {
        this._vitalTypeSelected = value;

        switch (value) {
            case 'RESPIRATION':
                this.label = 'Respiration Rate';
                break;
            case 'BLOOD PRESSURE':
                this.label = 'Blood Pressure';
                break;

            case 'WEIGHT':
                this.label = 'Weight';
                break;

            case 'TEMPERATURE':
                this.label = 'Temperature';
                break;

            case 'PULSE':
                this.label = 'Pulse';
                break;

            default:
            // do nothing for now :)
        }
    }

    get vitalTypeSelected() {
        return this._vitalTypeSelected;
    }

    // expects labels and datasets collections

    @api
    set graphConfig(value) {
        this._graphConfig = value;
    }

    get graphConfig() {
        return this._graphConfig;
    }

    @api
    set measurementsToDisplay(value) {
        this._measurementsToDisplay = value;
    }

    get measurementsToDisplay() {
        return this._measurementsToDisplay;
    }

    @api
    setSelectedRecord(value) {
        this._measurementsToDisplay = value;
    }

    /**
     * @description Handles the filtering of the currently viewed data by date range.
     * @param event
     */
    handleDateChange(event) {
        const { value } = event.detail;

        this.dispatchEvent(
            new CustomEvent('datechange', {
                detail: value
            })
        );
    }

    /**
     * @description shows or hides the current chart.
     */
    handleDisplayChart() {
        this.showChart = !this.showChart;
    }

    /**
     * @description clears the current user input filters
     */
    handleClearFilters() {
        this.dispatchEvent(CustomEvent('clearfilters'));
    }

    /**
     * @description Gets the reference values and puts then into an object so that we can display what are considered Low/Normal/High readings for the current vital.
     * @returns {{high, low, units}} Custom reference range object.
     */
    get referenceRange() {
        return {
            high: this._measurementsToDisplay[0].high,
            low: this._measurementsToDisplay[0].low,
            units: this.measurementsToDisplay[0].units
        };
    }

    _componentToRender;

    /**
     * @description When a user clicks on a cell on the vitals data table, this gets called to set dynamic vital chart that will get rendered.
     * @param value {String} name of the LWC to render.
     */
    @api
    set componentToRender(value) {
        try {
            import(value).then((cmp) => {
                this._componentToRender = cmp.default;
            });
        } catch (error) {
            console.error(`Error importing component: ${error}`);
        }
    }

    label;

    /**
     * @description getter for a rendered body component
     */
    get componentToRender() {
        return this._componentToRender;
    }

    /**
     * @description Returns true if the vital that the user clicks on is that of a blood pressure reading.
     * @returns {boolean} True if the user clicked on a blood pressure reading, else false.
     */
    get isBloodPressure() {
        return this.vitalTypeSelected.toLowerCase() === 'blood pressure';
    }
}
