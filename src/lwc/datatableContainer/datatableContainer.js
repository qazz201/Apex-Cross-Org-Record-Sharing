import {LightningElement, api} from 'lwc';
import {isEmptyArray, isEmptyString} from "c/commons";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Apex
import getDatatableDataConfig from '@salesforce/apex/SourceOrgRecordsController.getDatatableDataConfig';

//Labels
import noDataToDisplay from '@salesforce/label/c.SourceOrg_Lbl_NoDataToDisplay';
import sourceOrgRecords from '@salesforce/label/c.SourceOrg_Lbl_Records';
import {showToastNotification, WARNING_TITLE, WARNING_VARIANT} from "c/toastMessage";

//Constants
const DEFAULT_VISIBLE_RECORDS = 20;
const DEFAULT_VISIBLE_COLUMNS = 8;
const CAN_NOT_COPY_OBJ_ERROR = 'not supported for copy';

//Events
// const RECORD_SELECTED_EVENT = 'recordselected';
const COPY_EVENT = 'copy';

export default class DatatableContainer extends LightningElement {
    @api records = [];
    @api columns = [];

    visibleRecordsCount = DEFAULT_VISIBLE_RECORDS;
    visibleColumnsCount = DEFAULT_VISIBLE_COLUMNS;
    showSpinner = false;
    forbidRecordsCopyAction = true;

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
            this.forbidRecordsCopyAction = true;
            return;
        }
        this.forbidRecordsCopyAction = false;

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
        let title = '';
        let variant = '';

        if (message?.toLowerCase()?.includes(CAN_NOT_COPY_OBJ_ERROR.toLowerCase())) {
            title = WARNING_TITLE;
            variant = WARNING_VARIANT;
        }

        showToastNotification(title, message, variant);
    }

    get objectName() {
        return this._objectName;
    }

    get areRecordsEmpty() {
        return !this.records?.length;
    }
}