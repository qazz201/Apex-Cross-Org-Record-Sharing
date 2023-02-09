import {ShowToastEvent} from "lightning/platformShowToastEvent";

export const ERROR_VARIANT = 'error';
export const ERROR_TITLE = 'Error';
export const WARNING_VARIANT = 'warning';
export const WARNING_TITLE = 'Warning';
export const SUCCESS_VARIANT = 'success';
export const SUCCESS_TITLE = 'Success';

export function showToastNotification(title = '', error = {}, variant = 'info') {
    let message = error?.message ? error?.message : error?.body?.message;
    message = message?.replaceAll(/[{}]/gi, '');
    
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            // mode: 'sticky',
        })
    );
}