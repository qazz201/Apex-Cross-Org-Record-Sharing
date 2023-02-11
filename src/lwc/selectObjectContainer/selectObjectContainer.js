import {LightningElement, api} from 'lwc';
import {isEmptyArray} from "c/commons";
import {showToastNotification, WARNING_VARIANT, WARNING_TITLE, ERROR_TITLE, ERROR_VARIANT} from "c/toastMessage";

//Apex
import getSourceOrgCustomObjectNames
    from '@salesforce/apex/SourceOrgDataContainerController.getSourceOrgCustomObjectNames';
import getStandardObjectNames from '@salesforce/apex/SourceOrgDataContainerController.getStandardObjectNames';

const CHANGE_NAME_EVENT = 'changename';
const CUSTOM_OBJ = 'customObject';
const STANDARD_OBJ = 'standardObject';

export default class SelectObjectContainer extends LightningElement {
    @api standardObjectOptions = [];
    @api customObjectOptions = [];
    @api label = '';

    selectedObjectName = '';
    objects = {
        custom: CUSTOM_OBJ,
        standard: STANDARD_OBJ,
    }

    handleChangeObjectName(event) {
        const {detail, currentTarget} = event;
        this.dispatchEvent(new CustomEvent(CHANGE_NAME_EVENT, {detail}));
        this.selectedObjectName = detail?.value;

        const dataSetObjName = currentTarget.dataset?.objectName;
        if (dataSetObjName === this.objects.standard) {
            this.$customObjSelect?.resetSelection();
        } else if (dataSetObjName === this.objects.custom) {
            this.$standardObjSelect?.resetSelection();
        }
    }

    async handleGetStandardObjectNames() {
        console.log('GET STAND OBJ');
        try {
            if (!isEmptyArray(this.standardObjectOptions)) return;
            const objNames = await getStandardObjectNames();
            this.standardObjectOptions = this.createOptions(objNames);
        } catch (error) {
            this.handleGetObjectNamesError(error);
        }
    }

    async handleGetCustomObjectNames() {
        console.log('GET CCCOOBJ');
        try {
            if (!isEmptyArray(this.customObjectOptions)) return;
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

    get $customObjSelect() {
        return this.template.querySelector('.custom-object-select');
    }

    get $standardObjSelect() {
        return this.template.querySelector('.standard-object-select');
    }
}