import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

import {registerListener, unregisterListener} from 'c/pubsub';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {isEmptyArray} from 'c/commons';

//Apex
import getSourceOrgCustomObjectNames
    from '@salesforce/apex/SourceOrgDataContainerController.getSourceOrgCustomObjectNames';

//Labels
import authenticationRequired from '@salesforce/label/c.Auth_Lbl_AuthenticationRequired';
import pleaseAuthenticate from '@salesforce/label/c.Auth_Lbl_PleaseAuthenticate';
import selectCustomObject from '@salesforce/label/c.SourceOrg_Lbl_SelectCustomObject';

const AUTH_EVENT = 'authenticate';
const ERROR_VARIANT = 'error';
const ERROR_TITLE = 'Error';
const WARNING_VARIANT = 'warning';
const WARNING_TITLE = 'Warning';

export default class SourceOrgDataContainer extends LightningElement {
    @api showContainer = false;
    @wire(CurrentPageReference) pageRef; // Required by pubsub

    _options = [];
    selectedObjectName = '';
    showSpinner = false;

    labels = {
        authenticationRequired,
        pleaseAuthenticate,
        selectCustomObject,
    };

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
            AUTH_EVENT,
            this.handleAuthEvent,
            this
        );

        this.getCustomObjectNames();
    }

    disconnectedCallback() {
        unregisterListener(AUTH_EVENT, this.handleAuthEvent, this);
    }

    getCustomObjectNames() {
        this.showSpinner = true;

        getSourceOrgCustomObjectNames().then((data) => {
            this.options = data;
            this.showContainer = true;
        }).catch(error => {
            this.handleGetCustomObjectNamesError(error);
        }).finally(() => this.showSpinner = false);
    }

    handleAuthEvent(params = {}) {
        const {success} = params;
        if (success) this.showContainer = true;
    }

    handleSelectObjectName(event) {
        const {value} = event?.detail;
        this.selectedObjectName = value;
        console.log(value)
    }

    handleGetCustomObjectNamesError(error = {}) {
        console.error('SourceOrgDataContainer ERROR: ', error);

        const {message} = error?.body;
        if (message?.toLowerCase()?.includes(this.labels?.authenticationRequired.toLowerCase())) {
            this.showToastNotification(WARNING_TITLE, message, WARNING_VARIANT);
            return;
        }

        this.showToastNotification(ERROR_TITLE, message, ERROR_VARIANT);
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