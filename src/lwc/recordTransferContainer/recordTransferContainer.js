import {LightningElement, wire} from 'lwc';
import {CurrentPageReference} from 'lightning/navigation';

export default class RecordTransferContainer extends LightningElement {
    handleAuthorization(event) {
        const {success} = event.detail;
        console.log('AUTHORIZE_SUCCESS??_ ', success);
    } 
}