import {LightningElement, api} from 'lwc';

const CHANGED_EVENT = 'changed';
const FOCUSED_EVENT = 'focused';

export default class CustomSelect extends LightningElement {
    @api label = '';
    @api options = [];

    domSelect;

    renderedCallback() {
        if (this.domSelect) return;
        this.domSelect = this.template.querySelector('select');
    }

    @api resetSelection() {
        this.domSelect.selectedIndex = 0;
    }

    handleFocus() {
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