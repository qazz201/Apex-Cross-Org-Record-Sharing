import {LightningElement,api} from 'lwc';

export default class MessageContainer extends LightningElement {
    @api message = '';
    @api urlLink = '';
}