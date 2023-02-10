import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference, NavigationMixin} from 'lightning/navigation';

import {registerListener, unregisterListener} from 'c/pubsub';
import {
    showToastNotification,
    ERROR_VARIANT,
    ERROR_TITLE,
    WARNING_VARIANT,
    WARNING_TITLE,
    SUCCESS_VARIANT, SUCCESS_TITLE
} from "c/toastMessage";

//Apex
import checkIfUserAuthenticated from '@salesforce/apex/SourceOrgDataContainerController.checkIfUserAuthenticated';
import copyRecordsByIds from '@salesforce/apex/SourceOrgDataContainerController.copyRecordsByIds';

//Labels
import authenticationRequired from '@salesforce/label/c.Auth_Lbl_AuthenticationRequired';
import pleaseAuthenticate from '@salesforce/label/c.Auth_Lbl_PleaseAuthenticate';
import selectCustomObject from '@salesforce/label/c.SourceOrg_Lbl_SelectCustomObject';

const AUTH_EVENT = 'authenticate';

export default class SourceOrgDataContainer extends NavigationMixin(LightningElement) {
    @api showContainer = false;
    @wire(CurrentPageReference) pageRef; // Required by pubsub

    //_options = [];
    selectedObjectName = '';
    showSpinner = false;
    showModalSpinner = false;
    domDatatableContainer;
    allowRecordsCopyAction;
    savedRecordsData = [];

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
            this.handleError(error);
        }
        this.showSpinner = false;
    }

    async handleCopyRecords() {
        try {
            this.showModalSpinner = true;
            this.$modalWindow?.openModal();
            this.allowRecordsCopyAction = false;
            const recordIds = this.domDatatableContainer?.getSelectedRecordIds();

            this.savedRecordsData = await copyRecordsByIds({
                objectName: this.selectedObjectName,
                recordIds
            });

            this.showModalSpinner = false;
            console.log('RRRESSS__', JSON.stringify(this.savedRecordsData))

            showToastNotification(SUCCESS_TITLE, {}, SUCCESS_VARIANT);
            console.log(JSON.stringify(recordIds));
        } catch (error) {
            this.handleError(error);
        }

        this.allowRecordsCopyAction = true;
    }

    handleSelectObjectName(event) {
        const {value} = event?.detail;
        this.selectedObjectName = value;
    }

    handleAuthEvent(params = {}) {
        const {success} = params;
        // if (success) this.showContainer = true;
        this.showContainer = success;
    }

    handleSavedRecordNavigate(event) {
        event.preventDefault();
        const recordId = event.currentTarget.dataset?.recordId;
        if (!recordId) return;

        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId,
                objectApiName: this.selectedObjectName,
                actionName: 'view'
            }
        });
    }

    handleModalClose() {
        this.savedRecordsData = [];
    }

    handleError(error = {}) {
        console.error('SourceOrgDataContainer ERROR: ', error);

        const {message} = error?.body;
        let title = ERROR_TITLE;
        let variant = ERROR_VARIANT;

        if (message?.toLowerCase()?.includes(this.labels?.authenticationRequired.toLowerCase())) {//
            title = WARNING_TITLE;
            variant = WARNING_VARIANT;
        }
        showToastNotification(title, error, variant);
        this.$modalWindow?.closeModal();
        this.showModalSpinner = false;
    }

    get showAuthorizationText() {
        return this.showContainer && !this.showSpinner;
    }

    get $modalWindow() {
        return this.template.querySelector('c-modal-window');
    }
}