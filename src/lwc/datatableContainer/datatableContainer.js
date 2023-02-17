import {LightningElement, api} from 'lwc';
import {isEmptyArray, isEmptyString} from "c/commons";
import {showToastNotification, ERROR_TITLE, ERROR_VARIANT, WARNING_TITLE, WARNING_VARIANT} from "c/toastMessage";

//Apex
import getDatatableDataConfig from '@salesforce/apex/DatatableContainerController.getDatatableDataConfig';

//Labels
import noDataToDisplay from '@salesforce/label/c.SourceOrg_Lbl_NoDataToDisplay';
import sourceOrgRecords from '@salesforce/label/c.SourceOrg_Lbl_Records';
import notSupported from '@salesforce/label/c.Api_Lbl_NotSupported';

//Constants
const DEFAULT_VISIBLE_RECORDS = 20;
const DEFAULT_VISIBLE_COLUMNS = 8;

//Events
const RECORD_COPY_EVENT = 'recordcopy';

export default class DatatableContainer extends LightningElement {
    @api records = [];
    @api columns = [];
    @api allowRecordsCopyAction = false;

    recordsOffset = 0;
    searchQuery = '';
    visibleRecordsCount = DEFAULT_VISIBLE_RECORDS;
    visibleColumnsCount = DEFAULT_VISIBLE_COLUMNS;
    showSpinner = false;
    allowLoadMore = false;

    selectedRows = [];
    _objectName = '';
    labels = {
        noDataToDisplay,
        sourceOrgRecords,
        notSupported,
    }

    @api set objectName(value) {
        if (isEmptyString(value)) return;
        this._objectName = value;
        this.searchQuery = '';
        this.$datatableHeaderPanel?.clearSearchInput();

        this.clearTableData();
        this.getData(); //TODO: add throttling
    };

    @api getSelectedRecordIds() {
        return this.selectedRows.map(record => record?.Id);
    }

    clearTableData() {
        this.columns = [];
        this.records = [];
        this.recordsOffset = 0;
        this.selectedRows = [];
        this.allowRecordsCopyAction = false;
    }

    getData() {
        if (isEmptyString(this.objectName)) return;
        this.showSpinner = true;
        this.deactivateLoadMoreButton(true);

        getDatatableDataConfig({
            objectName: this.objectName,
            visibleRecords: this.visibleRecordsCount,
            visibleColumns: this.visibleColumnsCount,
            offsetValue: this.recordsOffset,
            searchQuery: this.searchQuery,
        }).then(response => {
            if (!isEmptyString(this.searchQuery)) {
                this.parseSearchRecords(response);
                return;
            }

            this.parseGotRecords(response);
        }).catch(err => {
            this.handleErrorMessage(err);
            this.allowLoadMore = false;
        }).finally(() => {
            this.showSpinner = false;
            this.allowLoadMore && this.deactivateLoadMoreButton(false);
        });
    }

    parseGotRecords(response) {
        const {columns, data} = response;
        if (!data?.length) {
            this.allowLoadMore = false;
            return;
        }
        this.columns = columns;
        this.records = [...this.records, ...data];
        this.allowLoadMore = true;
    }

    parseSearchRecords(response) {
        const {columns, data} = response;
        this.columns = columns;
        this.records = data;
        this.allowLoadMore = false;
    }

    handleRowSelection(event) {
        const {selectedRows} = event?.detail;
        this.selectedRows = selectedRows;
        this.allowRecordsCopyAction = !isEmptyArray(selectedRows);
    }

    handleRecordSearch(event) {
        this.searchQuery = event.detail?.value;
        if (isEmptyString(this.searchQuery)) this.records = [];
        this.showSpinner = true;
        this.getData();
    }

    handleVisibleRecordsChange(event) {
        this.clearTableData();
        this.visibleRecordsCount = parseInt(event.detail.value);
        this.getData();
    }

    handleVisibleColumnsChange(event) {
        this.clearTableData();
        this.visibleColumnsCount = event.detail.value;
        this.getData();
    }

    handleCopy() {
        this.dispatchEvent(new CustomEvent(RECORD_COPY_EVENT, {details: {}}));
    }

    handleLoadMoreData() {
        this.recordsOffset += this.visibleRecordsCount;
        this.getData();
    }

    handleErrorMessage(error = {}) {
        console.error('SourceOrgRecords Error: ', error);

        const {message} = error?.body;
        let title = ERROR_TITLE;
        let variant = ERROR_VARIANT;

        if (message?.toLowerCase()?.includes(this.labels?.notSupported.toLowerCase())) {
            title = WARNING_TITLE;
            variant = WARNING_VARIANT;
        }

        showToastNotification(title, error, variant);
    }

    deactivateLoadMoreButton(isDisabled) {
        if (isDisabled) {
            this.$loadMoreDataBtn?.setAttribute('disabled', true);

        } else {
            this.$loadMoreDataBtn?.removeAttribute('disabled');
        }
    }

    get objectName() {
        return this._objectName;
    }

    get isSearchAvailable() {
        return !this.areRecordsExist && !this.searchQuery;
    }

    get areRecordsExist() {
        return this.records?.length;
    }

    get selectedRecordsCount() {
        return this.selectedRows.length;
    }

    get $loadMoreDataBtn() {
        return this.template.querySelector('.load-more-data');
    }

    get $datatableHeaderPanel() {
        return this.template.querySelector('c-datatable-header-panel');
    }
}