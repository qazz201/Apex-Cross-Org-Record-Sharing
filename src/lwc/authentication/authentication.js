import {LightningElement, api, wire} from 'lwc';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import {CurrentPageReference} from 'lightning/navigation';

import {
    showToastNotification,
    ERROR_TITLE,
    ERROR_VARIANT,
    SUCCESS_VARIANT
} from "c/toastMessage";
import {isEmptyString, isEmptyArray} from 'c/commons';
import {fireEvent} from 'c/pubsub';

//Apex
import tryToAuthorize from '@salesforce/apex/AuthenticationController.authorize';

//Labels
import authenticationSuccessful from '@salesforce/label/c.Auth_Lbl_AuthenticationSuccessful';

const AUTH_CODE = 'code';
const AUTH_EVENT = 'authenticate';
const AUTHORIZATION_PATH = 'services/oauth2/authorize';

export default class Authentication extends LightningElement {
    @wire(CurrentPageReference) pageRef; // Required by pubsub
    //authUrl = 'https://login.salesforce.com/services/oauth2/authorize?client_id=3MVG9vvlaB0y1YsLh_esB2JsdW0GXbrlIkGLkYDI51JVZ8s2zdsSOjnhh3ubBeI0qLO1La.MJiwD6uj88vUeX&response_type=code&redirect_uri=https://empathetic-shark-ve6ud3-dev-ed.trailblaze.lightning.force.com/lightning/n/TransferRecordsFromAnotherOrg';
    @api clientId = '';
    @api clientSecret = '';
    @api callbackUrl = 'https://empathetic-shark-ve6ud3-dev-ed.trailblaze.lightning.force.com/lightning/n/TransferRecordsFromAnotherOrg';
    @api environmentUrl = 'https://login.salesforce.com'; // production or sandbox

    // @api autoLaunchAuthorization = false;
    // /**
    //  * @description To silently get new auth code(if needed) and also check if user already authorized
    //  */ 
    // @api silentAuthorization = false;

    authCode = ''; //extracted from url
    authWindow;
    intervalIds = [];
    defaultAuthEventDetail = {success: false};
    labels = {authenticationSuccessful,};

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
            showToastNotification(ERROR_TITLE, error, ERROR_VARIANT);
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
            this.handleFailedAuthentication();
            return;
        }

        this.handleSuccessfulAuthentication();
    }

    handleSuccessfulAuthentication() {
        tryToAuthorize({
            authCode: this.authCode,
            clientId: this.clientId,
            clientSecret: this.clientSecret,
            callbackUrl: this.callbackUrl,
        }).then(() => {
            console.log('Connected app data saved!')
            const eventParams = {...this.defaultAuthEventDetail, success: true};

            fireEvent(this.pageRef, AUTH_EVENT, eventParams);
            this.dispatchAuthorizationEvent(eventParams);
            showToastNotification(this.labels?.authenticationSuccessful, {}, SUCCESS_VARIANT);
        }).catch(error => {
            this.handleFailedAuthentication(error);
        })
    }

    handleFailedAuthentication(error = {}) {
        console.error('Failed Authentication error: ', error);

        this.dispatchAuthorizationEvent(this.defaultAuthEventDetail);
        fireEvent(this.pageRef, AUTH_EVENT, this.defaultAuthEventDetail);
        error && showToastNotification(ERROR_TITLE, error, ERROR_VARIANT);
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
        this.dispatchEvent(new CustomEvent(AUTH_EVENT, {detail}));
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

    get authorizationUrl() {
        if (!this.canAuthUrlBeGenerated) {
            const errorMsg = `Please give the next information: Environment URL,Client Id,Callback URL.
             Your values are: Environment URL- ${this.environmentUrl}, Client Id- ${this.clientId}, Callback URL- ${this.callbackUrl}`;
            throw new Error(errorMsg);
            // todo: SHOW TOAST ERROR
        }

        this.validateEnvironmentUrl();
        return `${this.environmentUrl}${AUTHORIZATION_PATH}?client_id=${this.clientId}&response_type=code&redirect_uri=${this.callbackUrl}`;
    }

    get canAuthUrlBeGenerated() {
        return !isEmptyString(this.environmentUrl)
            & !isEmptyString(this.clientId)
            & !isEmptyString(this.callbackUrl);
    }
}