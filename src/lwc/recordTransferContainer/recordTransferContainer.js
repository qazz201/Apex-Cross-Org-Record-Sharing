import {LightningElement, wire} from 'lwc';
// import {CurrentPageReference} from 'lightning/navigation';
// import {registerListener, unregisterListener} from 'c/pubsub';

//Labels
import authorizeOrChangeAuthorizationData from '@salesforce/label/c.Auth_Lbl_AuthorizeOrChangeAuthorizationData';
import reauthorize from '@salesforce/label/c.Auth_Lbl_Reauthorize';

const AUTHORIZE_EVENT = 'authorize';
const RUN_AUTH_FLOW_ACTION = 'runAuthFlow';
const REAUTHORIZATION_REQUIRED_ACTION = 'reauthorizationRequired';

export default class RecordTransferContainer extends LightningElement {

    labels = {
        authorizeOrChangeAuthorizationData,
        reauthorize,
    };

    menuActions = {
        runAuthFlow: RUN_AUTH_FLOW_ACTION,
        reauthorizationRequired: REAUTHORIZATION_REQUIRED_ACTION,
    };

    handleMenuOnselect(event) {
        const {value: actionName} = event.detail;
        console.log(actionName);

        if (actionName === this.menuActions.runAuthFlow) {
            this.$authorizationContainer?.runAuthorizationFlow();
        } else if (actionName === this.menuActions.reauthorizationRequired) {
            console.log('Action: ', REAUTHORIZATION_REQUIRED_ACTION);
        }
    }

    get $authorizationContainer() {
        return this.template.querySelector('c-authorization-container');
    }
}