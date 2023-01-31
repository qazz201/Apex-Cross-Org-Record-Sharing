import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterListener} from 'c/pubsub';

//Apex
import checkAuthorization from '@salesforce/apex/SourceOrgDataContainerController.checkAuthorization';

const AUTHORIZE_EVENT = 'authorize';

export default class SourceOrgDataContainer extends LightningElement {
    @api showContainer = false;

    @wire(CurrentPageReference) pageRef; // Required by pubsub

    connectedCallback() {
        registerListener(
            AUTHORIZE_EVENT,
            this.handleAuthorizationEvent,
            this
        );

        if (this.showContainer === true) {
            return;
        }

        checkAuthorization().then((resp) => {
            if (resp === true) {
                this.showContainer = true;
            }
        }).catch(err => console.error(err))
    }

    handleAuthorizationEvent(params = {}) {
        const {success} = params;
        if (success) this.showContainer = true;
    }

    get options() {
        return [
            {label: 'New', value: 'new'},
            {label: 'In Progress', value: 'inProgress'},
            {label: 'Finished', value: 'finished'},
        ];
    }
}