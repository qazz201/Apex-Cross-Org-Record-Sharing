import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

import {registerListener, unregisterListener} from 'c/pubsub';
import {showToastNotification, ERROR_VARIANT, ERROR_TITLE, WARNING_VARIANT, WARNING_TITLE} from "c/toastMessage";
import {isEmptyArray} from 'c/commons';

//Apex
import checkIfUserAuthenticated from '@salesforce/apex/SourceOrgDataContainerController.checkIfUserAuthenticated';

//Labels
import authenticationRequired from '@salesforce/label/c.Auth_Lbl_AuthenticationRequired';
import pleaseAuthenticate from '@salesforce/label/c.Auth_Lbl_PleaseAuthenticate';
import selectCustomObject from '@salesforce/label/c.SourceOrg_Lbl_SelectCustomObject';

const AUTH_EVENT = 'authenticate';


export default class SourceOrgDataContainer extends LightningElement {
    @api showContainer = false;
    @wire(CurrentPageReference) pageRef; // Required by pubsub

    //_options = [];
    selectedObjectName = '';
    showSpinner = false;
    domDatatableContainer = '';

    labels = {
        authenticationRequired,
        pleaseAuthenticate,
        selectCustomObject,
    };

    async connectedCallback() {
        registerListener(
            AUTH_EVENT,
            this.handleAuthEvent,
            this
        );
        await this.checkIfUserAuthenticated();
    }

    renderedCallback() {
        if (this.domDatatableContainer) return;
        this.domDatatableContainer = this.template.querySelector('c-datatable-container');
    }

    disconnectedCallback() {
        unregisterListener(AUTH_EVENT, this.handleAuthEvent, this);
    }

    async checkIfUserAuthenticated() {
        try {
            this.showSpinner = true;
            const {userAuthenticated} = await checkIfUserAuthenticated();
            this.showContainer = userAuthenticated;
        } catch (error) {
            console.log(error.stack);
            showToastNotification(ERROR_TITLE, error.message, ERROR_VARIANT);
        }
        this.showSpinner = false;
    }

    handleCopyEvent() {
        console.log('AAAA')
        const recordIds = this.domDatatableContainer?.getSelectedRecordIds();
        console.log(JSON.stringify(recordIds))
    }

    handleSelectObjectName(event) {
        const {value} = event?.detail;
        this.selectedObjectName = value;
    }

    handleAuthEvent(params = {}) {
        const {success} = params;
        if (success) this.showContainer = true;
    }

    get showAuthorizationText() {
        return this.showContainer && !this.showSpinner;
    }
}