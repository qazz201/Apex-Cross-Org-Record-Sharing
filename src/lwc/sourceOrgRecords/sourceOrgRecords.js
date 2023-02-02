import {LightningElement, api} from 'lwc';
import {isEmptyString} from "c/commons";

export default class SourceOrgRecords extends LightningElement {
    @api objectName = '';

    data = [];
    
    columns = [
        {label: 'Label', fieldName: 'name'},
        {label: 'Website', fieldName: 'website', type: 'url'},
        {label: 'Phone', fieldName: 'phone', type: 'phone'},
        {label: 'Balance', fieldName: 'amount', type: 'currency'},
        {label: 'CloseAt', fieldName: 'closeAt', type: 'date'},
    ];

    connectedCallback() {
        this.data = this.generateData({amountOfRecords: 3});
    }

    getRecords() {
        if (isEmptyString(this.objectName)) return;
        //...
    }

    generateData({amountOfRecords}) {
        return [...Array(amountOfRecords)].map((_, index) => {
            return {
                name: `Name (${index})`,
                website: 'www.salesforce.com',
                amount: Math.floor(Math.random() * 100),
                phone: `${Math.floor(Math.random() * 9000000000) + 1000000000}`,
                closeAt: new Date(
                    Date.now() + 86400000 * Math.ceil(Math.random() * 20)
                ),
            };
        });
    }

    handleRowSelection(event) {
        const selectedRows = event.detail.selectedRows
        console.log(JSON.stringify(selectedRows));
    }
}