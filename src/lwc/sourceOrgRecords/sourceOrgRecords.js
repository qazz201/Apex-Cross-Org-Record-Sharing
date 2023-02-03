import {LightningElement, api} from 'lwc';
import {isEmptyString} from "c/commons";
import {ShowToastEvent} from 'lightning/platformShowToastEvent';

//Apex
import getDatatableDataConfig from '@salesforce/apex/SourceOrgRecordsController.getDatatableDataConfig';

export default class SourceOrgRecords extends LightningElement {
    @api visibleRecords;
    @api visibleColumns;
    @api records = [];
    @api columns = [];

    showSpinner = false;
    selectedRows = [];
    _objectName = '';


    @api set objectName(value) {
        if (isEmptyString(value)) return;

        this.getData(value);
        this._objectName = value;
    };

    connectedCallback() {
        //  this.data = this.generateData({amountOfRecords: 3});
        console.log('DATATABLE____')
        // await this.getData();
    }

    getData(objectName = '') {
        if (isEmptyString(objectName)) return;
        this.columns = [];
        this.records = [];
        this.showSpinner = true;

        getDatatableDataConfig({
            objectName,//: 'Contact',//TODO: DELETE HARDCODE
            visibleRecords: 3,
            visibleColumns: 10
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

    get doesCopyRecordsDisabled() {
        return !this.selectedRows?.length;
    }
}