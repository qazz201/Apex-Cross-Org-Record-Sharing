import {LightningElement, api} from 'lwc';
import {isEmptyArray, debounce} from 'c/commons';

//Labels
import copySelectedRecords from '@salesforce/label/c.SourceOrg_Lbl_CopySelectedRecords';
import selectRows from '@salesforce/label/c.SourceOrg_Lbl_SelectRows';
import selectColumns from '@salesforce/label/c.SourceOrg_Lbl_SelectColumns';

//Constants
const DEFAULT_VISIBLE_RECORDS_DIAPASON = [1, 2, 5, 10, 20, 35, 50, 70, 100];
const DEFAULT_VISIBLE_RECORDS = '20';
const DEFAULT_VISIBLE_COLUMNS_DIAPASON = [1, 2, 3, 4, 5, 8, 10, 15, 20, 25, 30, 35, 50, 70, 100];
const DEFAULT_VISIBLE_COLUMNS = '8';

//Events
const VISIBLE_RECORDS_CHANGE = 'visiblerecordschange';
const VISIBLE_COLUMNS_CHANGE = 'visiblecolumnschange';
const COPY_RECORD = 'recordcopy';
const SEARCH_RECORD = 'recordsearch';

export default class DatatableHeaderPanel extends LightningElement {
    @api allowRecordsCopyAction = false;
    @api allowSearch = false;

    _visibleRecordsCount = DEFAULT_VISIBLE_RECORDS;
    _visibleColumnsCount = DEFAULT_VISIBLE_COLUMNS;

    debounceEventDispatcher = debounce(this.eventDispatcher.bind(this), 450);

    labels = {
        copySelectedRecords,
        selectRows,
        selectColumns,
    };
    minCharCountSearch = 3;
    searchQuery = '';

    @api set visibleRecordsCount(value) {
        this._visibleRecordsCount = `${value}`;
    }

    @api set visibleColumnsCount(value) {
        this._visibleColumnsCount = `${value}`;
    }

    @api clearSearchInput() {
        console.log('CLEAR INPUTTT')
        this.searchQuery = '';
    }

    handleVisibleRecordsChange(event) {
        this.eventDispatcher(VISIBLE_RECORDS_CHANGE, event.detail);
    }

    handleVisibleColumnsChange(event) {
        this.eventDispatcher(VISIBLE_COLUMNS_CHANGE, event.detail);
    }

    handleCopyAction(event) {
        this.eventDispatcher(COPY_RECORD, event.detail);
    }

    handleSearchInputChange(event) {
        const {value} = event.detail;
        this.searchQuery = value;
        if (value?.length != 0 && value.length < this.minCharCountSearch) return;

        this.debounceEventDispatcher(SEARCH_RECORD, event.detail);
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

    get isDisableRecordsCopyAction() {
        return !this.allowRecordsCopyAction;
    }

    get visibleRecordsDiapasonOptions() {
        return this.createComboboxOptionsFromArray(DEFAULT_VISIBLE_RECORDS_DIAPASON);
    }

    get visibleColumnsDiapasonOptions() {
        return this.createComboboxOptionsFromArray(DEFAULT_VISIBLE_COLUMNS_DIAPASON);
    }
}