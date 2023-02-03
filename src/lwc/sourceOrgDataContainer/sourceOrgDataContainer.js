import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

import {registerListener, unregisterListener} from 'c/pubsub';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {isEmptyArray} from 'c/commons';
//Apex
// import checkAuthorization from '@salesforce/apex/SourceOrgDataContainerController.checkAuthorization';
import getSourceOrgCustomObjectNames
    from '@salesforce/apex/SourceOrgDataContainerController.getSourceOrgCustomObjectNames';

const AUTHORIZE_EVENT = 'authorize';

export default class SourceOrgDataContainer extends LightningElement {
    @api showContainer = false;
    @wire(CurrentPageReference) pageRef; // Required by pubsub

    _options = [];
    selectedObjectName = '';
    showSpinner = false;

    @api
    set options(values) {
        console.log("NAMES__", values)
        if (isEmptyArray(values)) return;
        this._options = values.map(objectName => {
            return {label: objectName, value: objectName};
        })
    }

    connectedCallback() {
        registerListener(
            AUTHORIZE_EVENT,
            this.handleAuthorizationEvent,
            this
        );
        this.getCustomObjectNames();
    }

    disconnectedCallback() {
        unregisterListener(AUTHORIZE_EVENT, this.handleAuthorizationEvent, this);
    }

    getCustomObjectNames() {
        this.showSpinner = true;

        getSourceOrgCustomObjectNames().then((data) => {
            this.options = data;
            this.showContainer = true;
        }).catch(error => {
            console.error('SourceOrgDataContainer ERROR: ', error);
            return this.showToastNotification('Error', error?.body?.message, 'error');
        }).finally(() => this.showSpinner = false);
    }

    handleAuthorizationEvent(params = {}) {
        const {success} = params;
        if (success) this.showContainer = true;
    }

    handleSelectObjectName(event) {
        const {value} = event?.detail;
        this.selectedObjectName = value;
        console.log(value)
    }

    showToastNotification(title = '', message = '', variant = 'info') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    get options() {
        return this._options;
    }

    get showAuthorizationText() {
        return this.showContainer && !this.showSpinner;
    }
}