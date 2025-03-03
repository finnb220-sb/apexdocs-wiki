/**
 * @description reusable LWC that visualizes(charts) data with chartjs(2.9.4)
 * @see {https://www.chartjs.org/docs/2.9.4/} for documentation on Chart.JS 2.9.4
 * @author Booz Allen
 *
 * @example
 * // Define labels and dataset in JS file
 *
 * chartlabels = ['1/12/01', '04/26/1999', '05/12/1992'] // each label is a label for a datapoint defined below
 * chartDatasets = [
 *      {  label: 'Label of data to show in legend',
 *        data: [1, 3, 4], // data to render the label above "1/12/01" maps to "1" in this array
 *        backgroundColor: 'red',
 *        borderColor: 'green',
 *        fill: false
 *      }
 * ]
 *
 * //HTML
 * <pre>
 *     <!-- creating a line chart instance -->
 *     <c-base-chart chart-type="line" chart-datasets={chartDatasets} chart-labels={chartlabels}></c-base-chart>
 * </pre>
 *
 */

import { LightningElement, api, track } from 'lwc';
import chartjs from '@salesforce/resourceUrl/Chartjs';
import { loadScript } from 'lightning/platformResourceLoader';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

// default chart options
const defaultOptions = {
    legend: {
        display: true,
        position: 'bottom',
        align: 'center'
    },
    scales: {
        xAxes: [
            {
                offset: true,
                padding: 3
            }
        ]
    }
};

export default class BaseChart extends LightningElement {
    _chartType;
    _chartDatasets;
    _chartOptions;
    _chartLabels;
    isChartJSInitialized;

    /**
     * @description Sets the Chart Type property on the chart config object
     * @param value type, e.g. "line"
     */
    @api
    set chartType(value) {
        this.chartConfig = {
            ...this.chartConfig,
            type: value
        };
    }

    get chartType() {
        return this.chartType.type;
    }

    /**
     * @description Takes in a array of dataset objects to render a chart for, see documentation above for example
     * @param value datasets to render
     */
    @api
    set chartDatasets(value) {
        this.chartConfig = {
            ...this.chartConfig,
            data: {
                ...this.chartConfig.data,
                datasets: JSON.parse(JSON.stringify(value)) // not sure why I have to do this
            }
        };
    }

    get chartDatasets() {
        return this.chartConfig.data.datasets;
    }

    /**
     * @description sets additional options if needed, see chart.js 2.9.4 for valid options
     * @param value options metadata for a chart
     */
    @api
    set chartOptions(value) {
        if (value) {
            this.chartConfig = {
                ...this.chartConfig,
                options: value
            };
        }
    }

    get chartOptions() {
        return { ...this.chartConfig }?.options;
    }

    /**
     * @description Sets the lables for a dataset, the dataset.data and this dataset.labels arrays are rendered via their array order
     * @param value
     */
    @api
    set chartLabels(value) {
        this.chartConfig = {
            ...this.chartConfig,
            data: {
                ...this.chartConfig.data,
                labels: value
            }
        };
    }

    get chartLabels() {
        return { ...this.chartConfig }.data.labels;
    }

    // this object is what gets built up by the setters and is what ultimately gets passed into chart js
    @track
    chartConfig = {
        type: '',
        data: {
            labels: [],
            datasets: []
        },
        options: defaultOptions //  options setter above can modify this
    };

    renderedCallback() {
        if (this.isChartJSInitialized) {
            return;
        }

        // load chartjs from the static resource
        Promise.all([loadScript(this, chartjs)])
            .then(() => {
                this.isChartJSInitialized = true;
                const ctx = this.refs.chartComponent.getContext('2d');
                this.chart = new window.Chart(ctx, JSON.parse(JSON.stringify(this.chartConfig)));
            })
            .catch((error) => {
                console.error('error', error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error loading Chart',
                        message: error.message,
                        variant: 'error'
                    })
                );
            });
    }
}
