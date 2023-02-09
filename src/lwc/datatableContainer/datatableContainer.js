import {LightningElement, api} from 'lwc';
import {isEmptyArray, isEmptyString} from "c/commons";

//Apex
import getDatatableDataConfig from '@salesforce/apex/SourceOrgRecordsController.getDatatableDataConfig';

//Labels
import noDataToDisplay from '@salesforce/label/c.SourceOrg_Lbl_NoDataToDisplay';
import sourceOrgRecords from '@salesforce/label/c.SourceOrg_Lbl_Records';
import {showToastNotification, ERROR_TITLE, ERROR_VARIANT, WARNING_TITLE, WARNING_VARIANT} from "c/toastMessage";

//Constants
const DEFAULT_VISIBLE_RECORDS = 20;
const DEFAULT_VISIBLE_COLUMNS = 8;
const CAN_NOT_COPY_OBJ_ERROR = 'not supported for copy';

//Events
const COPY_EVENT = 'copy';

export default class DatatableContainer extends LightningElement {
    @api records = [];
    @api columns = [];
    @api allowRecordsCopyAction = false;

    visibleRecordsCount = DEFAULT_VISIBLE_RECORDS;
    visibleColumnsCount = DEFAULT_VISIBLE_COLUMNS;
    showSpinner = false;

    selectedRows = [];
    _objectName = '';
    labels = {
        noDataToDisplay,
        sourceOrgRecords
    }

    @api set objectName(value) {
        if (isEmptyString(value)) return;
        this._objectName = value;
        this.columns = [];
        this.records = [];
        this.getData(); //TODO: add throttling
    };

    @api getSelectedRecordIds() {
        return this.selectedRows.map(record => record?.Id);
    }

    getData() {
        if (isEmptyString(this.objectName)) return;
        this.showSpinner = true;

        getDatatableDataConfig({
            objectName: this.objectName,
            visibleRecords: this.visibleRecordsCount,
            visibleColumns: this.visibleColumnsCount,
        }).then(response => {
            const {columns, data} = response;
            this.columns = columns;
            this.records = data;
        }).catch(err => {
            this.handleErrorMessage(err);
        }).finally(() => this.showSpinner = false);
    }

    handleRowSelection(event) {
        const {selectedRows} = event?.detail;
        this.selectedRows = selectedRows;

        if (isEmptyArray(selectedRows)) {
            this.allowRecordsCopyAction = false;
            return;
        }
        this.allowRecordsCopyAction = true;

        console.log(JSON.stringify(this.selectedRows));
    }

    handleVisibleRecordsChange(event) {
        this.visibleRecordsCount = event.detail.value;
        this.getData();
    }

    handleCopyEvent() {
        this.dispatchEvent(new CustomEvent(COPY_EVENT, {details: {}}));
    }

    handleVisibleColumnsChange(event) {
        this.visibleColumnsCount = event.detail.value;
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
}