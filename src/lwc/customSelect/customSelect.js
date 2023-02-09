import {LightningElement, api} from 'lwc';

// import getPickListValues from '@salesforce/apex/PicklistController.getPickListValues';
// import getFieldLabel from '@salesforce/apex/PicklistController.getFieldLabel';

const CHANGED_EVENT = 'changed';
const FOCUSED_EVENT = 'focused';

export default class CustomSelect extends LightningElement {
    @api label = '';
    @api options = [];

    handleFocus() {
        console.log('FOCUSED');
        this.dispatchEvent(new CustomEvent(FOCUSED_EVENT, {}));
    }

    handleSelect(event) {
        const {value} = event.currentTarget;
        this.dispatchEvent(new CustomEvent(CHANGED_EVENT, {
            detail: {value}
        }));
    }

    //TODO: REMOVE??
    get isPicklistDisabled() {
        return false
        // return !this.options?.length
    }
}