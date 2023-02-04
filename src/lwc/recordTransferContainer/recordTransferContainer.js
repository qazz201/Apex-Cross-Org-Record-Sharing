import {LightningElement, wire} from 'lwc';
// import {CurrentPageReference} from 'lightning/navigation';
// import {registerListener, unregisterListener} from 'c/pubsub';

//Labels
import authenticateOrChangeAuthData from '@salesforce/label/c.Auth_Lbl_AuthenticateOrChangeAuthData';
import reauthenticate from '@salesforce/label/c.Auth_Lbl_Reauthenticate';

const AUTH_EVENT = 'authenticate';
const RUN_AUTH_FLOW_ACTION = 'runAuthFlow';
const RE_AUTHENTICATION_REQUIRED_ACTION = 'reAuthenticationRequired';

export default class RecordTransferContainer extends LightningElement {

    labels = {
        authenticateOrChangeAuthData,
        reauthenticate,
    };

    menuActions = {
        runAuthFlow: RUN_AUTH_FLOW_ACTION,
        reAuthenticationRequired: RE_AUTHENTICATION_REQUIRED_ACTION,
    };

    handleMenuOnselect(event) {
        const {value: actionName} = event.detail;
        console.log(actionName);

        if (actionName === this.menuActions.runAuthFlow) {
            this.$authenticationContainer?.runAuthorizationFlow();
        } else if (actionName === this.menuActions.reAuthenticationRequired) {
            console.log('Action: ', RE_AUTHENTICATION_REQUIRED_ACTION);
        }
    }

    get $authenticationContainer() {
        return this.template.querySelector('c-authentication-container');
    }
}