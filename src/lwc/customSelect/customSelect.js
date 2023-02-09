import {LightningElement, api} from 'lwc';

// import getPickListValues from '@salesforce/apex/PicklistController.getPickListValues';
// import getFieldLabel from '@salesforce/apex/PicklistController.getFieldLabel';

const CHANGED_EVENT = 'changed';
const CLICKED_EVENT = 'clicked';

export default class CustomSelect extends LightningElement {
    @api label = '';
    @api options = [];

    handleClick() {
        console.log('CLICK');
        this.dispatchEvent(new CustomEvent(CLICKED_EVENT, {}));
    }

    handleSelect(event) {
        const {value} = event.currentTarget;
        this.dispatchEvent(new CustomEvent(CHANGED_EVENT, {
            detail: {value}
        }));
    }

    get isPicklistDisabled() {
        return false
        // return !this.options?.length
    }
}