import {ShowToastEvent} from "lightning/platformShowToastEvent";

export function showToastNotification(title = '', message = '', variant = 'info') {
    message = message?.replaceAll(/[{}]/gi, '');
    dispatchEvent(
        new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'sticky',
        })
    );
}