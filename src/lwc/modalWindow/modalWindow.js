import {LightningElement, api} from 'lwc';

const CLOSED_EVENT = 'closed';

export default class ModalWindow extends LightningElement {
    @api modalHeader = '';
    @api showModal = false;
    @api showFooter = false;
    @api showHeader = false;
    @api showSpinner = false;

    @api openModal() {
        this.showModal = true;
    }

    @api closeModal() {
        this.showModal = false;
    }

    handleModalClose() {
        this.showModal = false;
        this.dispatchEvent(new CustomEvent(CLOSED_EVENT, {detail: {}}))
    }
}