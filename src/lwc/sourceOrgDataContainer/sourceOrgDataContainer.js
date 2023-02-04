import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

import {registerListener, unregisterListener} from 'c/pubsub';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {isEmptyArray} from 'c/commons';

//Apex
import getSourceOrgCustomObjectNames
    from '@salesforce/apex/SourceOrgDataContainerController.getSourceOrgCustomObjectNames';

//Labels
import authorizationRequired from '@salesforce/label/c.Auth_Lbl_AuthorizationRequired';
import pleaseAuthorize from '@salesforce/label/c.Auth_Lbl_PleaseAuthorize';
import selectCustomObject from '@salesforce/label/c.SourceOrg_Lbl_SelectCustomObject';

const AUTHORIZE_EVENT = 'authorize';
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
        authorizationRequired,
        pleaseAuthorize,
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
            this.handleGetCustomObjectNamesError(error);
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

    handleGetCustomObjectNamesError(error = {}) {
        console.error('SourceOrgDataContainer ERROR: ', error);

        const {message} = error?.body;
        if (message?.toLowerCase()?.includes(this.labels?.authorizationRequired.toLowerCase())) {
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