import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterListener} from 'c/pubsub';

//Labels
import authorizeOrChangeAuthorizationData from '@salesforce/label/c.Auth_Lbl_AuthorizeOrChangeAuthorizationData';

const AUTHORIZE_EVENT = 'authorize';
const AUTHORIZATION_FLOWAPI_NAME = 'RecordTransferAuthorizationFlow';

export default class AuthorizationContainer extends LightningElement {
    @api enableSilentMode = false;
    @wire(CurrentPageReference) pageRef; // Required by pubsub

    labels = {
        authorizeOrChangeAuthorizationData,
    };

    authorizationFlowApiName = AUTHORIZATION_FLOWAPI_NAME;

    connectedCallback() {
        registerListener(
            AUTHORIZE_EVENT,
            this.handleAuthorization,
            this
        );
    }

    disconnectedCallback() {
        unregisterListener(AUTHORIZE_EVENT, this.handleAuthorization, this);
    }

    @api runAuthorizationFlow() {
        this.$modalWindow?.openModal();
    }

    @api closeAuthorizationModal() {
        this.template.querySelector('c-modal-window')?.closeModal();
    }

    handleAuthorization(params = {}) {
        const {success} = params;
        console.log('AUTHORIZE_SUCCESS??_ ', success);
        console.log('PUBSUB CATCH EVENT??_ ', JSON.stringify(params));

        if (success === true) {
            this.closeAuthorizationModal();
        }
    }

    get $modalWindow() {
        return this.template.querySelector('c-modal-window');
    }
}