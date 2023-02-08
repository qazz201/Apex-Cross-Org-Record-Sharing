import {LightningElement, api} from 'lwc';

//Apex
import getSourceOrgCustomObjectNames
    from '@salesforce/apex/SourceOrgDataContainerController.getSourceOrgCustomObjectNames';
import getStandardObjectNames from '@salesforce/apex/SourceOrgDataContainerController.getStandardObjectNames';

import {isEmptyArray} from "c/commons";
import {showToastNotification} from "c/toastMessage";

// import {ShowToastEvent} from "lightning/platformShowToastEvent";

const CHANGE_EVENT = 'change';
const ERROR_VARIANT = 'error';
const ERROR_TITLE = 'Error';
const WARNING_VARIANT = 'warning';
const WARNING_TITLE = 'Warning';

export default class SelectObjectContainer extends LightningElement {
    @api standardObjectOptions = [];
    @api customObjectOptions = [];
    @api label = '';
    @api options = []; //TODO: delete later, not now

    selectedObjectName = '';

    handleGetStandardObjectNames() {
        if (!isEmptyArray(this.standardObjectOptions)) return;
        this.getStandardObjectNames();
    }

    handleGetCustomObjectNames() {
        if (!isEmptyArray(this.customObjectOptions)) return;
        this.getCustomObjectNames();
    }

    handleChange(event) {
        console.log('XXX_', event?.detail.value);
        this.dispatchEvent(new CustomEvent(CHANGE_EVENT, {detail: event?.detail?.value}));
    }

    handleChangeObjectName(event) {
        const {detail} = event;
        this.dispatchEvent(new CustomEvent(CHANGE_EVENT, {detail}));
        this.selectedObjectName = detail?.value;
    }

    getCustomObjectNames() {
        console.log('GET CCCOOBJ');
        // this.showSpinner = true;
        getSourceOrgCustomObjectNames().then((data) => {
            if (isEmptyArray(data)) return;
            this.customObjectOptions = data.map(objectName => {
                return {label: objectName, value: objectName};
            })

            // this.showContainer = true;
        }).catch(error => {
            this.handleGetCustomObjectNamesError(error);
        }).finally(() => this.showSpinner = false);
    }

    getStandardObjectNames() {
        console.log('GET STAND OBJ');
        // this.showSpinner = true;
        getStandardObjectNames().then((data) => {
            if (isEmptyArray(data)) return;
            this.standardObjectOptions = data.map(objectName => {
                return {label: objectName, value: objectName};
            })

            // this.showContainer = true;
        }).catch(error => {
            this.handleGetCustomObjectNamesError(error);
        }).finally(() => this.showSpinner = false);
    }

    //TODO: rewrite
    handleGetCustomObjectNamesError(error = {}) {
        console.error('SourceOrgDataContainer ERROR: ', error);

        const {message} = error?.body;
        if (message?.toLowerCase()?.includes(this.labels?.authenticationRequired.toLowerCase())) {
            showToastNotification(WARNING_TITLE, message, WARNING_VARIANT);
            return;
        }

        showToastNotification(ERROR_TITLE, message, ERROR_VARIANT);
    }
}