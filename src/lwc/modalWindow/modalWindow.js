import {LightningElement, api} from 'lwc';

export default class ModalWindow extends LightningElement {
    @api modalHeader = '';
    @api showModal = false;
    @api showFooter = false;
    @api showHeader = false;

    @api openModal() {
        this.showModal = true;
    }

    @api closeModal() {
        this.showModal = false;
    }
}