// allowing for short circuiting logic e.g. this.trueBoolean && executeFunction() // executeFunction will only be called if this.trueBoolean is true
/* eslint no-unused-expressions: ["error", { "allowShortCircuit": true }] */

/**
 * @description dynamically creates a components in a 508-compliant, out-of-the-box, lightning/modal
 *
 * @example
 *
 * // @see {@link https://developer.salesforce.com/docs/component-library/bundle/lightning-modal/documentation} for further information.
 *
 * // import the modal
 * import BaseLightningModal from 'c/baseLightningModal';
 *
 * // create a new instance of the modal
 * // the modal takes a bodyComponentToRender object that contains the name of the component to render and the props to pass to the component
 * // the modal also takes an optional footerComponentToRender object that contains the name of the component to render and the props to pass to the component
 * // the modal also takes an optional headerComponentToRender object that contains the name of the component to render and the props to pass to the component
 * // the modal also takes an optional listeners object that contains an array of objects with a name and method property
 *
 *
 * BaseLightningModal.open({
 *     bodyComponentToRender: { // required, the component to render in the body of the modal, the name is the name of the component to render, and props are the component properties
 *          name: 'c/vccLabDetails',
 *          props: { // api properties to pass to the dynamically rendered component
 *              selectedLab: this.selectedLab
 *          }
 *     },
 *     footerComponentToRender: { // optional, allows you to render a footer component in the modal, the name is the name of the component to render, and props are the component properties
 *          name: 'c/paginationString',
 *          props: {
 *              selectedLab: this.selectedLab
 *           }
 *      },
 *
 *      headerComponentToRender: { // optional, allows you to render a header component in the modal, the name is the name of the component to render, and props are the component properties
 *          name: 'c/ehrModalHeader',
 *          props: { // api properties to pass to the dynamically rendered component
 *              icon: 'header icon'
 *              title: 'header title'
 *           }
 *      },
 *      listeners: { // optional, allows you to attach event listeners to the dynamically rendered component, expects an array of objects with a name and method property
 *          [
 *              {
 *                  name: 'onnavclick', // name of the event listener you want to attach to the rendered component
 *                  method: this.nextValueChange  // name of the callers class method to call when the event is caught
 *              }
 *          ]
 *      }
 *
 * })
 *
 */
import { api, wire } from 'lwc';
import LightningModal from 'lightning/modal';
import { subscribe, MessageContext, APPLICATION_SCOPE } from 'lightning/messageService';
import baseLightningModalComms from '@salesforce/messageChannel/baseLightningModalComms__c';

export default class BaseLightningModal extends LightningModal {
    _bodyComponentToRender;
    _footerComponentToRender;
    _headerComponentToRender;

    @wire(MessageContext)
    messageContext;

    subscription = null;
    messageChannel = baseLightningModalComms;

    /**
     * @description Dynamically create an lwc component in the footer of the lightning/modal
     * @param value
     * @throws {Error} if the value passed does not contain the required properties
     */
    @api
    set footerComponentToRender(value) {
        try {
            this._footerComponentToRender = value;
            import(value.name).then((cmp) => {
                this._footerComponentToRender = { ...this._footerComponentToRender, cmp: cmp.default };
            });
        } catch (error) {
            console.error(`Error importing component: ${error}`);
        }
    }

    get footerComponentToRender() {
        return this._footerComponentToRender;
    }

    /**
     * @description Dynamically creates an lwc component in the header of the modal
     * @param value
     * @throws {Error} if the value passed does not contain the required properties
     */
    @api
    set headerComponentToRender(value) {
        try {
            this._headerComponentToRender = value;
            import(value.name).then((cmp) => {
                this._headerComponentToRender = { ...this._headerComponentToRender, cmp: cmp.default };
            });
        } catch (error) {
            console.error(`Error importing component: ${error}`);
        }
    }

    /**
     * @description getter for a header component rendered
     */
    get headerComponentToRender() {
        return this._headerComponentToRender;
    }

    /**
     * @required
     * @description Dynamically creates an lwc component in the body of the modal, this property is required
     */

    @api
    set bodyComponentToRender(value) {
        try {
            import(value.name).then((cmp) => {
                this._bodyComponentToRender = { ...value, cmp: cmp.default };
            });
        } catch (error) {
            console.error(`Error importing component: ${error}`);
        }
    }

    /**
     * @description getter for a rendered body component
     */
    get bodyComponentToRender() {
        return this._bodyComponentToRender;
    }

    /**
     *
     * @description provides the modal access to call its generated components api methods without having to know the internals of the generated component
     * @param componentName String name of the component to call the method on,
     * @param methodName Name of the method to call on the component
     * @param args Array of arguments to pass to the method
     *
     * @example
     *
     * // call the setSelectedLab method on the generated "vccLabDetails" component
     *
     * const lab = { id: '123', name: 'lab name', collected: '2024-04-02' };
     * this.callMethod('generated-cmp', 'setSelectedLab', [lab]);  // calls the public api "setSelectedLab" method on the generated component with the lab object as an argument
     *
     */
    callMethod(componentName, methodName, args) {
        try {
            this.template.querySelector(`[data-id='${componentName}']`)[`${methodName}`](...args);
        } catch (error) {
            console.error(`Error calling method: ${error}`);
        }
    }

    /**
     * @description Enable API access to the dynamically generated components, this allows the invokers of the modal to interact with the generated components @api methods
     */
    connectedCallback() {
        this.enableAPIAccess();
    }

    /**
     * @description Subscribing to the BaseLightningModalComms channel enables this component to invoke public @api methods on generated components
     */

    enableAPIAccess() {
        if (!this.subscription && this.messageChannel) {
            this.subscription = subscribe(
                this.messageContext,
                this.messageChannel,
                (message) => {
                    this.handleMessage(message);
                },
                { scope: APPLICATION_SCOPE }
            );
        }
    }

    /**
     * @description Handle incoming messages from the message channels, expects a list of "operations" that are meant to be executed
     * @param message an object that contains a list of operations to execute
     *
     * @example
     *
     * // each entry in the operation array is an a method that will be executed on this component
     * // the first method executes a public method on the dynamically generated component
     * // the second in invoked the "updatePaginationString" method on this component, with the pagination string as an argument
     *
     * publish(this.messageContext, this.messageChannel, {
     *             operations: [
     *                 {   // call the setSelectedLab method on the generated "vccLabDetails" component
     *                     name: 'vccLabDetails',
     *                     methodName: 'setSelectedLab', // name of method to call
     *                     methodArgs: [this.selectedLab] // arguments to pass to the method
     *
     *                 },
     *                 {   // call the setPaginationString method on the generated "basePaginationString" component
     *                     name: 'basePaginationString',
     *                     methodName: 'setPaginationString
     *                     methodArgs: ['1 of 100']
     *                 }
     *             ]
     *
     *         })
     *
     */
    handleMessage(message) {
        if (message?.methodCalls?.length) {
            for (const methodCall of message.methodCalls) {
                switch (methodCall.componentName) {
                    case 'c/baseLightningModal':
                        this.runBaseLightningModalMethod(methodCall);
                        break;
                    default:
                        this.callMethod(methodCall.componentName, methodCall.methodName, methodCall.methodArgs);
                        break;
                }
            }
        }
    }

    /**
     * @description
     * <p>
     *     We need to do this as Salesforce doesn't allow us to call public methods
     * </p>
     * @param methodCall Object containing the method name and arguments to invoke on this component e.g. "handleClose()"
     */
    runBaseLightningModalMethod(methodCall) {
        try {
            this[`${methodCall.methodName}`](...methodCall.methodArgs);
        } catch (error) {
            console.error(`Error calling method: ${error}`);
        }
    }
    // TODO: configure the "result" functionality to return something when a parent closes this modal
    /**
     * @description Close the modal
     */
    handleClose() {
        this.close();
    }
}
