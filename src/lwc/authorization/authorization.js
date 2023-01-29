import {LightningElement, api, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';

import {isEmptyString, isEmptyArray} from 'c/commons';
import {fireEvent} from 'c/pubsub';

//Apex
import tryToAuthenticate from '@salesforce/apex/AuthorizationController.tryToAuthenticate';

const AUTH_CODE = 'code';
const AUTHORIZE_EVENT = 'authorize';
const AUTHORIZATION_PATH = 'services/oauth2/authorize';

export default class Authorization extends LightningElement {
    @wire(CurrentPageReference) pageRef; // Required by pubsub
    //authUrl = 'https://login.salesforce.com/services/oauth2/authorize?client_id=3MVG9vvlaB0y1YsLh_esB2JsdW0GXbrlIkGLkYDI51JVZ8s2zdsSOjnhh3ubBeI0qLO1La.MJiwD6uj88vUeX&response_type=code&redirect_uri=https://empathetic-shark-ve6ud3-dev-ed.trailblaze.lightning.force.com/lightning/n/TransferRecordsFromAnotherOrg';
    @api clientId = '';
    @api clientSecret = '';
    @api callbackUrl = 'https://empathetic-shark-ve6ud3-dev-ed.trailblaze.lightning.force.com/lightning/n/TransferRecordsFromAnotherOrg';
    @api environmentUrl = 'https://login.salesforce.com'; // production or sandbox

    // @api autoLaunchAuthorization = false;
    /**
     * @description To silently get new auth code(if needed) and also check if user already authorized
     */
    @api silentAuthorization = false;

    authCode = ''; //extracted from url
    authWindow;
    intervalIds = [];
    defaultAuthEventDetail = {success: false};

    disconnectedCallback() {
        if (isEmptyArray(this.intervalIds)) return;
        this.clearIntervals();
    }

    openAuthWindow() {
        try {
            console.log('RESULT AUTH URL ', this.authorizationUrl)
            this.authWindow = window.open(this.authorizationUrl, "MsgWindow", "width=500,height=500,left=500");
            this.trackWindowLocationChange();
            this.trackWindowClose();
        } catch (error) {
            console.error(error.stack);
            this.showToastNotification('Error', error.message, 'error');
        }
    }

    clearIntervals() {
        this.intervalIds.forEach(interval => clearInterval(interval));
        this.intervalIds = [];
    }

    handleAuthWindowClose = () => {
        console.log(this.authCode, 'AUTH CODE')
        this.clearIntervals();

        if (!this.authCode || isEmptyString(this.authCode)) {
            this.handleFailedAuthorization();
            return;
        }

        this.handleSuccessfulAuthorization();
    }

    handleSuccessfulAuthorization() {
        tryToAuthenticate({
            authCode: this.authCode,
            clientId: this.clientId,
            clientSecret: this.clientSecret,
            callbackUrl: this.callbackUrl,
        }).then(() => {
            console.log('Connected app data saved!')
            const eventParams = {...this.defaultAuthEventDetail, success: true};

            fireEvent(this.pageRef, AUTHORIZE_EVENT, eventParams);
            this.dispatchAuthorizationEvent(eventParams);
            this.showToastNotification('Authorization is successful', '', 'success');
        }).catch(exception => {
            console.log('ERROR__ ', exception);
            console.log('ERROR__ msg ', exception?.body?.message);
            this.showToastNotification('Error', exception?.body?.message, 'error');
        })
    }

    handleFailedAuthorization() {
        this.dispatchAuthorizationEvent(this.defaultAuthEventDetail);
        fireEvent(this.pageRef, AUTHORIZE_EVENT, this.defaultAuthEventDetail);
        //TODO: Show Error
    }

    handleChangeWindowLocation(urlSearchParams = '') {
        this.authWindow.close();
        this.getAuthCodeFromUrl(urlSearchParams);
        this.handleAuthWindowClose();
    }

    getAuthCodeFromUrl(searchLink = '') {
        const searchParams = new URLSearchParams(searchLink);
        if (!searchParams.has(AUTH_CODE)) return;

        this.authCode = searchParams.get(AUTH_CODE);
        return this.authCode;
    }

    dispatchAuthorizationEvent(detail = {}) {
        this.dispatchEvent(new CustomEvent(AUTHORIZE_EVENT, {detail}));
    }

    trackWindowLocationChange() {
        this.intervalIds.push(
            setInterval(() => {
                const searchParams = this.authWindow.location.search;
                if (searchParams) {
                    this.handleChangeWindowLocation(searchParams);
                }
            }, 100)
        );
    }

    trackWindowClose() {
        this.intervalIds.push(
            setInterval(() => {
                if (this.authWindow.closed) {
                    this.handleAuthWindowClose();
                }
            }, 1000)
        );
    }

    validateEnvironmentUrl() {
        if (this.environmentUrl.endsWith('/')) return;
        this.environmentUrl = `${this.environmentUrl}/`;
    }

    showToastNotification(title = '', message = '', variant = 'info') {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }));
    }

    get authorizationUrl() {
        if (!this.canAuthUrlBeGenerated) {
            const errorMsg = `Please give the next information: Environment URL,Client Id,Callback URL.
             Your values are: Environment URL- ${this.environmentUrl}, Client Id- ${this.clientId}, Callback URL- ${this.callbackUrl}`;
            throw new Error(errorMsg);
        }

        this.validateEnvironmentUrl();
        return `${this.environmentUrl}${AUTHORIZATION_PATH}?client_id=${this.clientId}&response_type=code&redirect_uri=${this.callbackUrl}`;
    }

    get canAuthUrlBeGenerated() {
        return !isEmptyString(this.environmentUrl)
            & !isEmptyString(this.clientId)
            & !isEmptyString(this.callbackUrl);
    }

    // Silent Authorization

}