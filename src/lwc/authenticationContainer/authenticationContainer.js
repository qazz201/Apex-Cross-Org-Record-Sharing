import {LightningElement, api, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterListener} from 'c/pubsub';

//Labels
import authenticateOrChangeAuthData from '@salesforce/label/c.Auth_Lbl_AuthenticateOrChangeAuthData';

const AUTH_EVENT = 'authenticate';
const AUTHORIZATION_FLOW_API_NAME = 'RecordTransferAuthorizationFlow';

export default class AuthenticationContainer extends LightningElement {
    @api enableSilentMode = false;
    @wire(CurrentPageReference) pageRef; // Required by pubsub

    labels = {
        authenticateOrChangeAuthData,
    };

    authorizationFlowApiName = AUTHORIZATION_FLOW_API_NAME;

    connectedCallback() {
        registerListener(
            AUTH_EVENT,
            this.handleAuthentication,
            this
        );
    }

    disconnectedCallback() {
        unregisterListener(AUTH_EVENT, this.handleAuthentication, this);
    }

    @api runAuthorizationFlow() {
        this.$modalWindow?.openModal();
    }

    @api closeAuthorizationModal() {
        this.template.querySelector('c-modal-window')?.closeModal();// todo: USE VARIABLE
    }

    handleAuthentication(params = {}) {
        const {success} = params;
        console.log('AUTHORIZE_SUCCESS??_ ', success);
        console.log('PUBSUB CATCH EVENT??_ ', JSON.stringify(params));

        success && this.closeAuthorizationModal();
        // if (success === true) {
        //     this.closeAuthorizationModal();
        // }
    }

    get $modalWindow() {
        return this.template.querySelector('c-modal-window');
    }
}