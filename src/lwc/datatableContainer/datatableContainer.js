import {LightningElement, api} from 'lwc';
import {isEmptyArray, isEmptyString} from "c/commons";

//Apex
import getDatatableDataConfig from '@salesforce/apex/DatatableContainerController.getDatatableDataConfig';

//Labels
import noDataToDisplay from '@salesforce/label/c.SourceOrg_Lbl_NoDataToDisplay';
import sourceOrgRecords from '@salesforce/label/c.SourceOrg_Lbl_Records';
import {showToastNotification, ERROR_TITLE, ERROR_VARIANT, WARNING_TITLE, WARNING_VARIANT} from "c/toastMessage";

//Constants
const DEFAULT_VISIBLE_RECORDS = 20;
const DEFAULT_VISIBLE_COLUMNS = 8;
const CAN_NOT_COPY_OBJ_ERROR = 'not supported for copy';

//Events
const RECORD_COPY_EVENT = 'recordcopy';

export default class DatatableContainer extends LightningElement {
    @api records = [];
    @api columns = [];
    @api allowRecordsCopyAction = false;

    recordsOffset = 0;
    visibleRecordsCount = DEFAULT_VISIBLE_RECORDS;
    visibleColumnsCount = DEFAULT_VISIBLE_COLUMNS;
    showSpinner = false;
    loadedDataExists = false;

    selectedRows = [];
    _objectName = '';
    labels = {
        noDataToDisplay,
        sourceOrgRecords
    }

    @api set objectName(value) {
        if (isEmptyString(value)) return;
        this._objectName = value;

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
        this.$loadMoreDataBtn?.setAttribute('disabled', true);

        getDatatableDataConfig({
            objectName: this.objectName,
            visibleRecords: this.visibleRecordsCount,
            visibleColumns: this.visibleColumnsCount,
            offsetValue: this.recordsOffset,
        }).then(response => {
            const {columns, data} = response;
            if (!data?.length) {
                this.loadedDataExists = false;
                return;
            }

            this.columns = columns;
            this.records = [...this.records, ...data];
            this.loadedDataExists = true;
        }).catch(err => {
            this.handleErrorMessage(err);
        }).finally(() => {
            this.showSpinner = false;
            this.loadedDataExists && this.$loadMoreDataBtn?.removeAttribute('disabled');
        });
    }

    handleRowSelection(event) {
        const {selectedRows} = event?.detail;
        this.selectedRows = selectedRows;
        this.allowRecordsCopyAction = !isEmptyArray(selectedRows);
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

        if (message?.toLowerCase()?.includes(CAN_NOT_COPY_OBJ_ERROR.toLowerCase())) {
            title = WARNING_TITLE;
            variant = WARNING_VARIANT;
        }

        showToastNotification(title, error, variant);
    }

    get objectName() {
        return this._objectName;
    }

    get areRecordsEmpty() {
        return !this.records?.length;
    }

    get selectedRecordsCount() {
        return this.selectedRows.length;
    }

    get $loadMoreDataBtn() {
        return this.template.querySelector('.load-more-data');
    }
}