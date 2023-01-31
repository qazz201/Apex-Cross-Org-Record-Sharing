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
    _options = [];

    @wire(CurrentPageReference) pageRef; // Required by pubsub

    // @wire(getSourceOrgCustomObjectNames)
    // getCustomObjectNamesList({error, data}) {
    //     if (error) {
    //         console.log('err__- ', error)
    //         return this.showToastNotification('Error', error?.message, 'error');
    //     } else if (data) {
    //         this.showContainer = true;
    //         this.options = data;
    //     }
    // };

    connectedCallback() {
        registerListener(
            AUTHORIZE_EVENT,
            this.handleAuthorizationEvent,
            this
        );
        console.log('GET DATA___')
        getSourceOrgCustomObjectNames().then((data) => {
            this.options = data;
            this.showContainer = true;
        }).catch(err => {
            console.error(err);
            return this.showToastNotification('Error', error?.message, 'error');
        })
    }

    // createListOptionsFromObjectNames(objectNames = []) {
    //     if (isEmptyArray(objectNames)) return;
    //     this.options = objectNames.map(objectName => {
    //         return {label: objectName, value: objectName};
    //     })
    // }

    @api
    set options(values) {
        console.log("NAMES__", values)
        if (isEmptyArray(values)) return;
        this._options = values.map(objectName => {
            return {label: objectName, value: objectName};
        })
    }

    get options() {
        return this._options;
    }

    handleAuthorizationEvent(params = {}) {
        const {success} = params;
        if (success) this.showContainer = true;
    }

    showToastNotification(title = '', message = '', variant = 'info') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
    }
}