import {LightningElement, api} from 'lwc';
import {isEmptyArray} from 'c/commons';

//Constants
const DEFAULT_VISIBLE_RECORDS_DIAPASON = [1, 2, 5, 10, 20, 35, 50, 70, 100];
const DEFAULT_VISIBLE_RECORDS = '20';
const DEFAULT_VISIBLE_COLUMNS_DIAPASON = [1, 2, 3, 4, 5, 8, 10, 15, 20, 25, 30, 35, 50, 70, 100];
const DEFAULT_VISIBLE_COLUMNS = '8';

//Events
const VISIBLE_RECORDS_CHANGE = 'visiblerecordschange';
const VISIBLE_COLUMNS_CHANGE = 'visiblecolumnschange';

export default class DatatableHeaderPanel extends LightningElement {
    @api forbidRecordsCopyAction = false;
    @api forbidSearch = false;

    _visibleRecordsCount = DEFAULT_VISIBLE_RECORDS;
    _visibleColumnsCount = DEFAULT_VISIBLE_COLUMNS;

    @api set visibleRecordsCount(value) {
        this._visibleRecordsCount = `${value}`;
    }

    @api set visibleColumnsCount(value) {
        this._visibleColumnsCount = `${value}`;
    }

    handleVisibleRecordsChange(event) {
        this.eventDispatcher(VISIBLE_RECORDS_CHANGE, event.detail);
    }

    handleVisibleColumnsChange(event) {
        this.eventDispatcher(VISIBLE_COLUMNS_CHANGE, event.detail);
    }

    eventDispatcher(eventName = '', detail = {}) {
        this.dispatchEvent(new CustomEvent(eventName, {detail}));
    }

    createComboboxOptionsFromArray(arrayValues = []) {
        if (isEmptyArray(arrayValues)) return [];
        return arrayValues?.map(count => {
            return {label: `${count}`, value: `${count}`};
        });
    }

    get visibleRecordsCount() {
        return this._visibleRecordsCount;
    }

    get visibleColumnsCount() {
        return this._visibleColumnsCount;
    }

    get visibleRecordsDiapasonOptions() {
        return this.createComboboxOptionsFromArray(DEFAULT_VISIBLE_RECORDS_DIAPASON);
    }

    get visibleColumnsDiapasonOptions() {
        return this.createComboboxOptionsFromArray(DEFAULT_VISIBLE_COLUMNS_DIAPASON);
    }
}