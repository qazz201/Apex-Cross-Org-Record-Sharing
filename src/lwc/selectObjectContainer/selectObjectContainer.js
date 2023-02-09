import {LightningElement, api} from 'lwc';
import {isEmptyArray} from "c/commons";
import {showToastNotification, WARNING_VARIANT, WARNING_TITLE, ERROR_TITLE, ERROR_VARIANT} from "c/toastMessage";

//Apex
import getSourceOrgCustomObjectNames
    from '@salesforce/apex/SourceOrgDataContainerController.getSourceOrgCustomObjectNames';
import getStandardObjectNames from '@salesforce/apex/SourceOrgDataContainerController.getStandardObjectNames';

const CHANGE_NAME_EVENT = 'changename';

export default class SelectObjectContainer extends LightningElement {
    @api standardObjectOptions = [];
    @api customObjectOptions = [];
    @api label = '';

    selectedObjectName = '';

    async handleGetStandardObjectNames() {
        if (!isEmptyArray(this.standardObjectOptions)) return;
        await this.getStandardObjectNames();
    }

    async handleGetCustomObjectNames() {
        if (!isEmptyArray(this.customObjectOptions)) return;
        await this.getCustomObjectNames();
    }

    handleChangeObjectName(event) {
        const {detail} = event;
        this.dispatchEvent(new CustomEvent(CHANGE_NAME_EVENT, {detail}));
        this.selectedObjectName = detail?.value;
    }

    async getStandardObjectNames() {
        console.log('GET STAND OBJ');
        try {
            const objNames = await getStandardObjectNames();
            this.standardObjectOptions = this.createOptions(objNames);
        } catch (error) {
            this.handleGetObjectNamesError(error);
        }
    }

    async getCustomObjectNames() {
        console.log('GET CCCOOBJ');
        try {
            const objNames = await getSourceOrgCustomObjectNames();
            this.customObjectOptions = this.createOptions(objNames);
        } catch (error) {
            this.handleGetObjectNamesError(error);
        }
    }

    handleGetObjectNamesError(error = {}) {
        console.error('SelectObjectContainer ERROR: ', error);

        const {message} = error?.body;
        let title = ERROR_TITLE;
        let variant = ERROR_VARIANT;

        if (message?.toLowerCase()?.includes(this.labels?.authenticationRequired.toLowerCase())) {//
            title = WARNING_TITLE;
            variant = WARNING_VARIANT;
        }
        showToastNotification(title, error, variant);
    }

    createOptions(values = []) {
        if (isEmptyArray(values)) return values;
        return values.map(objectName => {
            return {label: objectName, value: objectName};
        });
    }
}