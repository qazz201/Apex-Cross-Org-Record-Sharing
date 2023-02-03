import {LightningElement, api} from 'lwc';

const CHANGE_EVENT = 'change';

export default class ObjectNamesList extends LightningElement {
    @api options = [];
    @api label = '';

    handleChange(event) {
        this.dispatchEvent(new CustomEvent(CHANGE_EVENT, {detail: event?.detail?.value}));
    }
}