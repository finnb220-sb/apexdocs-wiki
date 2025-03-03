import { LightningElement, track, api } from "lwc";
import chartjs from "@salesforce/resourceUrl/Chartjs";
import patternomaly from "@salesforce/resourceUrl/patternomaly";
import { loadScript } from "lightning/platformResourceLoader";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class ChartTest extends LightningElement {
    _fulldata;

    @api set fulldata(value) {
        // console.log(h.proxyTool(value));
        // value.map((vital) => {
        //     if (vital.name == 'BLOOD PRESSURE') {
        //         console.log('vit', h.proxyTool(vital));
        //         systolic.push(vital.rawVal.split('/')[0]);
        //         dialostic.push(vital.rawVal.split('/')[1]);
        //         xValues.push(`${vital.isoDate} ${vital.time}`);
        //     }
        // })
    }

    get fulldata() {
        return this._fulldata;
    }

    @api systolic = [];
    @api diastolic = [];
    @api systolicColor = "";
    @api diastolicColor = "";
    @api xVals;

    @track chartConfig = {
        type: "bar",
        data: {
            labels: [],
            datasets: [
                {
                    label: "Systolic",
                    data: [],
                    backgroundColor: "red",
                    fill: true
                },
                {
                    label: "Diastolic",
                    data: [],
                    backgroundColor: "blue",
                    fill: true
                }
            ]
        },
        options: {
            scales: {
                yAxes: [
                    {
                        display: true,
                        ticks: {
                            suggestedMin: 40,
                            beginAtZero: false
                        }
                    }
                ]
            },
            legend: {
                display: true,
                position: "bottom",
                align: "center"
            }
        }
    };

    isChartJsInitialized;

    disconnectedCallback() {}

    renderedCallback() {
        if (this.isChartJsInitialized) {
            return;
        }

        this.chartConfig.data.datasets[0].data = this.systolic;
        this.chartConfig.data.datasets[1].data = this.diastolic;
        this.chartConfig.data.datasets[0].backgroundColor = this.systolicColor;
        this.chartConfig.data.datasets[1].backgroundColor = this.diastolicColor;
        this.chartConfig.data.labels = this.xVals;

        // load chartjs from the static resource
        Promise.all([loadScript(this, chartjs), loadScript(this, patternomaly)])
            .then(() => {
                this.isChartJsInitialized = true;
                const ctx = this.template.querySelector("canvas.lineChart").getContext("2d");
                console.log("ctx", ctx);
                this.chartConfig.data.datasets[0].backgroundColor = window.pattern.draw("line-diagonal-rl", this.systolicColor);
                this.chartConfig.data.datasets[1].backgroundColor = window.pattern.draw("line", this.diastolicColor);
                this.chart = new window.Chart(ctx, this.chartConfig);
            })
            .catch((error) => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: "Error loading Chart",
                        message: error.message,
                        variant: "error"
                    })
                );
            });
    }
}
