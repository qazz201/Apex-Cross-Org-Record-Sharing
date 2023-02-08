import {LightningElement, api} from 'lwc';

// import getPickListValues from '@salesforce/apex/PicklistController.getPickListValues';
// import getFieldLabel from '@salesforce/apex/PicklistController.getFieldLabel';

const CHANGE_EVENT = 'change';
const CLICK_EVENT = 'click';

export default class CustomSelect extends LightningElement {
    @api label = '';
    @api options = [];

    handleClick() {
        console.log('CLICK');
        this.dispatchEvent(new CustomEvent(CLICK_EVENT, {}));
    }

    handleSelect(event) {
        const {value} = event.currentTarget;
        this.dispatchEvent(new CustomEvent(CHANGE_EVENT, {
            detail: {value}
        }));
    }

    get isPicklistDisabled() {
        return false
        // return !this.options?.length
    }
}