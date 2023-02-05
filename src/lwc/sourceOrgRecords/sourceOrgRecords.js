import {LightningElement, api} from 'lwc';
import {isEmptyArray, isEmptyString} from "c/commons";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Apex
import getDatatableDataConfig from '@salesforce/apex/SourceOrgRecordsController.getDatatableDataConfig';

//Labels
import noDataToDisplay from '@salesforce/label/c.SourceOrg_Lbl_NoDataToDisplay';
import sourceOrgRecords from '@salesforce/label/c.SourceOrg_Lbl_Records';

//Constants
const DEFAULT_VISIBLE_RECORDS = 20;
const DEFAULT_VISIBLE_COLUMNS = 8;

export default class SourceOrgRecords extends LightningElement {
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
        this.getData(); //TODO: add throttling
    };

    getData() {
        if (isEmptyString(this.objectName)) return;
        this.columns = [];
        this.records = [];
        this.showSpinner = true;

        getDatatableDataConfig({
            objectName: this.objectName, //'Contact', //TODO: DELETE HARDCODE
            visibleRecords: this.visibleRecordsCount,
            visibleColumns: this.visibleColumnsCount,
        }).then(response => {
            const {columns, data} = response;
            this.columns = columns;
            this.records = data;
        }).catch(err => {
            console.error('SourceOrgRecords Error: ', err);
            this.showToastNotification('Error', err?.body?.message?.replaceAll(/[{}]/gi,''), 'error');
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

        console.log(JSON.stringify(event.detail));
        console.log(JSON.stringify(this.selectedRows));
    }

    handleVisibleRecordsChange(event) {
        console.log('AAAAA_', event.detail.value);
        this.visibleRecordsCount = event.detail.value;
        this.getData();
    }

    handleVisibleColumnsChange(event) {
        console.log(event.detail.value, 'COLUMNS')
        this.visibleColumnsCount = event.detail.value;
        this.getData()
    }

    showToastNotification(title = '', message = '', variant = 'info') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            })
        );
    }

    get objectName() {
        return this._objectName;
    }

    get areRecordsEmpty() {
        return !this.records?.length;
    }
}