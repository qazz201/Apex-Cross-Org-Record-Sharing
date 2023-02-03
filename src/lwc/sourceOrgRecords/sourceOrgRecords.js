import {LightningElement, api} from 'lwc';
import {isEmptyArray, isEmptyString} from "c/commons";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Apex
import getDatatableDataConfig from '@salesforce/apex/SourceOrgRecordsController.getDatatableDataConfig';

const VISIBLE_RECORDS_DIAPASON = [1, 2, 5, 10, 20, 50, 100];
const VISIBLE_RECORDS = '20';
const VISIBLE_COLUMNS_DIAPASON = [1, 2, 3, 4, 5, 10, 15, 20, 25];
const VISIBLE_COLUMNS = '10';

export default class SourceOrgRecords extends LightningElement {
    // @api visibleRecords;
    // @api visibleColumns;
    @api records = [];
    @api columns = [];

    visibleRecords = VISIBLE_RECORDS;
    visibleColumns = VISIBLE_COLUMNS;
    showSpinner = false;
    selectedRows = [];
    _objectName = '';

    @api set objectName(value) {
        if (isEmptyString(value)) return;
        this._objectName = value;
        this.getData();
    };

    connectedCallback() {
        //  this.data = this.generateData({amountOfRecords: 3});
        console.log('DATATABLE____')
        // await this.getData();
    }


    getData() {
        if (isEmptyString(this.objectName)) return;
        this.columns = [];
        this.records = [];
        this.showSpinner = true;

        getDatatableDataConfig({
            objectName: this.objectName,//: 'Contact',//TODO: DELETE HARDCODE
            visibleRecords: this.visibleRecords,
            visibleColumns: this.visibleColumns,
        }).then(response => {
            const {columns, data} = response;
            this.columns = columns;
            this.records = data;
        }).catch(err => {
            console.error('SourceOrgRecords Error: ', err);
            this.showToastNotification('Error', err?.body?.message, 'error');
        }).finally(() => this.showSpinner = false);
    }

    handleRowSelection(event) {
        this.selectedRows = event.detail.selectedRows
        console.log(JSON.stringify(event.detail));
        console.log(JSON.stringify(this.selectedRows));
    }

    handleVisibleRecordsChange(event) {
        console.log(event.detail.value)
        this.visibleRecords = event.detail.value;
        this.getData();
    }

    handleVisibleColumnsChange(event) {
        console.log(event.detail.value, 'COLUMNS')
        this.visibleColumns = event.detail.value;
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

    createComboboxOptionsFromArray(arrayValues = []) {
        if (isEmptyArray(arrayValues)) return [];
        return arrayValues?.map(count => {
            return {label: `${count}`, value: `${count}`};
        });
    }

    get objectName() {
        return this._objectName;
    }

    get areRecordsEmpty() {
        return !this.records?.length;
    }

    get doesCopyRecordsDisabled() {
        return !this.selectedRows?.length;
    }

    get visibleRecordsDiapasonOptions() {
        return this.createComboboxOptionsFromArray(VISIBLE_RECORDS_DIAPASON);
    }

    get visibleColumnsDiapasonOptions() {
        return this.createComboboxOptionsFromArray(VISIBLE_COLUMNS_DIAPASON);
    }
}