import {LightningElement, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';
import {registerListener, unregisterListener} from 'c/pubsub';

const AUTHORIZE_EVENT = 'authorize';

export default class RecordTransferContainer extends LightningElement {
    @wire(CurrentPageReference) pageRef; // Required by pubsub

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

    handleAuthorization(params = {}) {
        const {success} = params;
        console.log('AUTHORIZE_SUCCESS??_ ', success);
        console.log('PUBSUB CATCH EVENT??_ ', JSON.stringify(params));

        if (success === true) {
            this.$modalWindow?.closeModal();
        }
    }

    runAuthorization() {
        this.$modalWindow?.openModal();
    }

    get $modalWindow() {
        return this.template.querySelector('c-modal-window');
    }
}