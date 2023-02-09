import {ShowToastEvent} from "lightning/platformShowToastEvent";

export const ERROR_VARIANT = 'error';
export const ERROR_TITLE = 'Error';
export const WARNING_VARIANT = 'warning';
export const WARNING_TITLE = 'Warning';

export function showToastNotification(title = '', message = '', variant = 'info') {
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